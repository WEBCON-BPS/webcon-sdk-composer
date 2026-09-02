using System.Text.Json;
using Xunit;

namespace VatWhitelist.Tests;

/// <summary>
/// The fixtures are evidence, not test data someone typed. These tests fail if a later edit
/// tidies away the specific things they were recorded to preserve.
///
/// No deserialisation model exists yet (T007). These read the JSON directly, so the fixtures
/// are guarded from the moment they land rather than from whenever the model catches up.
/// </summary>
public class FixtureTests
{
    private static JsonElement Load(string name)
    {
        var path = Path.Combine(AppContext.BaseDirectory, "Fixtures", name);
        return JsonDocument.Parse(File.ReadAllText(path)).RootElement;
    }

    /// <summary>
    /// NFR-4. Both fields are absent from the published field list and present in live
    /// responses. Delete them from the fixture and the tolerant-deserialisation test in T007
    /// proves nothing while still passing, which is the worst kind of green.
    /// </summary>
    [Theory]
    [InlineData("exemptionSmeDate")]
    [InlineData("hasVirtualAccounts")]
    public void Active_payer_keeps_the_undocumented_fields(string field)
    {
        var subject = Load("active-payer.json").GetProperty("result").GetProperty("subject");
        Assert.True(subject.TryGetProperty(field, out _),
            $"'{field}' was removed from the fixture. It is what NFR-4 is tested against.");
    }

    /// <summary>
    /// Finding 6. dd-MM-yyyy HH:mm:ss, Europe/Warsaw. Not ISO, not UTC. Normalising this in
    /// the fixture would hide the exact bug the Warsaw-day cache exists to avoid.
    /// </summary>
    [Theory]
    [InlineData("active-payer.json")]
    [InlineData("not-found.json")]
    public void RequestDateTime_is_in_the_registers_own_format(string fixture)
    {
        var value = Load(fixture).GetProperty("result").GetProperty("requestDateTime").GetString();
        Assert.Matches(@"^\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}$", value);
    }

    /// <summary>
    /// Finding 3. HTTP 200 with a null subject -- neither an error nor a result. FR-4 exists
    /// because of this shape, so the shape has to stay in the fixture.
    /// </summary>
    [Fact]
    public void Not_found_is_a_null_subject_not_an_error()
    {
        var result = Load("not-found.json").GetProperty("result");

        Assert.Equal(JsonValueKind.Null, result.GetProperty("subject").ValueKind);
        Assert.False(result.TryGetProperty("code", out _));
        Assert.NotNull(result.GetProperty("requestId").GetString());
    }

    /// <summary>
    /// Finding 4. Errors are flat at the top level of the body. The published swagger
    /// example shows {"exception":{...}}, so code written from the documentation looks for a
    /// wrapper that is not there and reads null.
    /// </summary>
    [Theory]
    [InlineData("error-wl115.json", "WL-115")]
    [InlineData("error-wl103.json", "WL-103")]
    public void Errors_are_flat_and_not_wrapped(string fixture, string expectedCode)
    {
        var root = Load(fixture);

        Assert.Equal(expectedCode, root.GetProperty("code").GetString());
        Assert.False(root.TryGetProperty("exception", out _),
            "If this ever passes with an 'exception' wrapper, the register changed shape.");
    }

    /// <summary>NFR-3: the register's own vocabulary stays Polish and verbatim.</summary>
    [Fact]
    public void Register_vocabulary_is_kept_verbatim_in_polish()
    {
        var subject = Load("active-payer.json").GetProperty("result").GetProperty("subject");
        Assert.Equal("Czynny", subject.GetProperty("statusVat").GetString());

        // Round-tripped through the file as UTF-8; if the encoding is ever mangled on the
        // way in or out, this is where it shows.
        Assert.Contains("SPÓŁKA", subject.GetProperty("name").GetString());
        Assert.Contains("Nieprawidłowy", Load("error-wl115.json").GetProperty("message").GetString());
    }
}
