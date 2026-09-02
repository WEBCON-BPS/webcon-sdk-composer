using System.Net;
using Webcon.Addon.VatWhitelist.Plugin.Register;
using Xunit;

namespace VatWhitelist.Tests;

/// <summary>
/// T007..T012. Not one of these makes a network call (NFR-2): every response comes from
/// Fixtures/, and the client is constructed with a responder that would have to be asked
/// for one deliberately.
/// </summary>
public class RegisterTests
{
    private static string Fixture(string name) =>
        File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Fixtures", name));

    /// <summary>A client that answers from a string and counts how often it was asked.</summary>
    private static (VatRegisterClient client, Func<int> calls) ClientReturning(
        string body, HttpStatusCode status = HttpStatusCode.OK)
    {
        int calls = 0;
        var client = new VatRegisterClient((url, ct) =>
        {
            calls++;
            return Task.FromResult(new HttpResponseMessage(status)
            {
                Content = new StringContent(body, System.Text.Encoding.UTF8, "application/json")
            });
        });
        return (client, () => calls);
    }

    public RegisterTests() => VatRegisterClient.ResetCache();

    // ---- T007: tolerant deserialisation (NFR-4) ---------------------------------------

    [Fact]
    public void Parses_a_real_response_including_fields_we_do_not_model()
    {
        var parsed = VatRegisterJson.Parse<VatSearchResponse>(Fixture("active-payer.json"));

        Assert.NotNull(parsed!.Result.Subject);
        Assert.Equal("7740001454", parsed.Result.Subject.Nip);
        Assert.Equal("Czynny", parsed.Result.Subject.StatusVat);
        Assert.Contains("ORLEN", parsed.Result.Subject.Name);
        Assert.Equal("02-09-2026 09:12:39", parsed.Result.RequestDateTime);
    }

    /// <summary>
    /// NFR-4 stated as the thing that will actually happen: the Ministry adds a field.
    /// If this ever throws, the add-on breaks on a day nobody deployed anything.
    /// </summary>
    [Fact]
    public void Survives_a_field_the_register_has_not_invented_yet()
    {
        var withNewField = Fixture("active-payer.json")
            .Replace("\"statusVat\"", "\"thisFieldDoesNotExistYet\": {\"nested\": [1,2,3]}, \"statusVat\"");

        var parsed = VatRegisterJson.Parse<VatSearchResponse>(withNewField);

        Assert.Equal("Czynny", parsed!.Result.Subject.StatusVat);
    }

    // ---- T008: the flat error shape ----------------------------------------------------

    [Theory]
    [InlineData("error-wl115.json", "WL-115")]
    [InlineData("error-wl103.json", "WL-103")]
    public void Reads_a_flat_error_body(string fixture, string expected)
    {
        var error = VatRegisterJson.Parse<VatRegisterError>(Fixture(fixture));

        Assert.Equal(expected, error!.Code);
        Assert.False(string.IsNullOrWhiteSpace(error.Message));
    }

    /// <summary>
    /// The shape the published swagger example shows. A parser written from the official
    /// documentation reads this and gets nulls -- no code, no message -- and a caller that
    /// checks `code == null` then reports a transport failure for a plain bad request.
    ///
    /// This test pins that difference so nobody "fixes" the model to match the docs.
    /// </summary>
    [Fact]
    public void The_documented_wrapped_error_shape_yields_nothing()
    {
        const string swaggerShape = """
            {"exception":{"exceptionDetail":{"code":"WL-103","message":"Data nie moze byc data przyszla."}}}
            """;

        var error = VatRegisterJson.Parse<VatRegisterError>(swaggerShape);

        Assert.Null(error!.Code);
        Assert.Null(error.Message);
    }

    // ---- T012 / FR-4: not-found is an answer -------------------------------------------

    [Fact]
    public async Task Not_found_is_an_outcome_not_a_failure()
    {
        var (client, _) = ClientReturning(Fixture("not-found.json"));

        var result = await client.LookupAsync("1111111111", "2026-09-02", default);

        Assert.Equal(VatLookupOutcome.NotInRegister, result.Outcome);
        Assert.Null(result.Subject);
        Assert.Equal("4S3nZ-98e4843", result.RequestId);          // FR-6 evidence still arrives
        Assert.Null(result.ErrorCode);
    }

    [Fact]
    public async Task A_refused_query_is_a_failure_carrying_the_code()
    {
        var (client, _) = ClientReturning(Fixture("error-wl103.json"), HttpStatusCode.BadRequest);

        var result = await client.LookupAsync("7740001454", "2027-01-01", default);

        Assert.Equal(VatLookupOutcome.Failed, result.Outcome);
        Assert.Equal("WL-103", result.ErrorCode);
    }

    [Fact]
    public async Task A_found_subject_carries_the_registers_own_evidence()
    {
        var (client, _) = ClientReturning(Fixture("active-payer.json"));

        var result = await client.LookupAsync("7740001454", "2026-09-02", default);

        Assert.Equal(VatLookupOutcome.Found, result.Outcome);
        Assert.Equal("Czynny", result.Subject!.StatusVat);

        // T013: verbatim, unparsed. If this ever round-trips through DateTime it stops
        // being the Ministry's timestamp and becomes our rendering of it.
        Assert.Equal("02-09-2026 09:12:39", result.RequestDateTime);
    }

    // ---- T010: the cache, and the budget it protects ------------------------------------

    [Fact]
    public async Task Same_nip_same_register_day_costs_one_query()
    {
        var (client, calls) = ClientReturning(Fixture("active-payer.json"));

        await client.LookupAsync("7740001454", "2026-09-02", default);
        var second = await client.LookupAsync("7740001454", "2026-09-02", default);

        Assert.Equal(1, calls());          // SC-002
        Assert.True(second.FromCache);
        Assert.Equal("Czynny", second.Subject!.StatusVat);
    }

    [Fact]
    public async Task A_new_register_day_is_a_new_query()
    {
        var (client, calls) = ClientReturning(Fixture("active-payer.json"));

        await client.LookupAsync("7740001454", "2026-09-02", default);
        await client.LookupAsync("7740001454", "2026-09-03", default);

        Assert.Equal(2, calls());
    }

    /// <summary>
    /// A failure says nothing about what the register holds. Caching one would turn a bad
    /// minute into a bad day, and the caller cannot tell the difference.
    /// </summary>
    [Fact]
    public async Task A_failure_is_not_cached()
    {
        var (client, calls) = ClientReturning(Fixture("error-wl103.json"), HttpStatusCode.BadRequest);

        await client.LookupAsync("7740001454", "2026-09-02", default);
        await client.LookupAsync("7740001454", "2026-09-02", default);

        Assert.Equal(2, calls());
    }
}

/// <summary>
/// Finding 6, as a test. The register's day is the Warsaw day.
/// </summary>
public class RegisterDayTests
{
    [Fact]
    public void Half_an_hour_after_midnight_in_Warsaw_is_already_the_new_register_day()
    {
        // 2026-09-01 22:30 UTC == 2026-09-02 00:30 Warsaw (CEST, +2).
        var justAfterMidnight = new DateTimeOffset(2026, 9, 1, 22, 30, 0, TimeSpan.Zero);

        Assert.Equal("2026-09-02", RegisterDay.For(justAfterMidnight));
    }

    [Fact]
    public void Half_an_hour_before_midnight_in_Warsaw_is_still_the_old_one()
    {
        // 2026-09-01 21:30 UTC == 2026-09-01 23:30 Warsaw.
        var justBefore = new DateTimeOffset(2026, 9, 1, 21, 30, 0, TimeSpan.Zero);

        Assert.Equal("2026-09-01", RegisterDay.For(justBefore));
    }

    /// <summary>
    /// The whole point, in one assertion: for two hours every summer night the UTC day and
    /// the register's day disagree, and a cache keyed on the wrong one serves yesterday's
    /// answer into today.
    /// </summary>
    [Fact]
    public void The_utc_day_and_the_register_day_disagree_for_two_hours_every_summer_night()
    {
        var instant = new DateTimeOffset(2026, 9, 1, 22, 30, 0, TimeSpan.Zero);

        Assert.Equal("2026-09-01", instant.UtcDateTime.ToString("yyyy-MM-dd"));
        Assert.Equal("2026-09-02", RegisterDay.For(instant));
    }

    /// <summary>Winter is +1, not +2. The offset is not a constant.</summary>
    [Fact]
    public void In_winter_the_offset_is_one_hour()
    {
        var winterEvening = new DateTimeOffset(2026, 1, 15, 23, 30, 0, TimeSpan.Zero);

        Assert.Equal("2026-01-16", RegisterDay.For(winterEvening));
    }
}
