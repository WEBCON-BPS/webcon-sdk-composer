using Webcon.Addon.VatWhitelist.Plugin;
using Xunit;

namespace VatWhitelist.Tests;

/// <summary>
/// FR-1 and FR-2. Everything here runs offline (NFR-2) because <see cref="Nip"/> touches
/// nothing but the string it was handed.
/// </summary>
public class NipTests
{
    // 7740001454 is a real, published NIP (PKN ORLEN), used because a made-up "valid" NIP
    // proves only that our own arithmetic agrees with itself.
    [Theory]
    [InlineData("7740001454")]
    [InlineData("1111111111")]   // valid check digit, and the register holds no such subject
    [InlineData("5252344078")]
    public void Accepts_a_correct_check_digit(string value)
    {
        Assert.Equal(Nip.Valid, Nip.Validate(value));
        Assert.True(Nip.IsValid(value));
    }

    [Theory]
    [InlineData("774-000-14-54")]
    [InlineData("774 000 14 54")]
    [InlineData("PL7740001454")]
    [InlineData("pl7740001454")]
    [InlineData("  7740001454  ")]
    [InlineData("774.000.14.54")]
    public void Ignores_separators_and_the_country_prefix(string value)
    {
        Assert.Equal(Nip.Valid, Nip.Validate(value));
    }

    [Theory]
    [InlineData("7740001455")]   // ORLEN's NIP, last digit altered
    [InlineData("1111111112")]
    [InlineData("7740001450")]
    public void Rejects_a_wrong_check_digit(string value)
    {
        Assert.Equal(Nip.Checksum, Nip.Validate(value));
        Assert.False(Nip.IsValid(value));
    }

    /// <summary>
    /// The weighted sum of 123456789 is 230, and 230 % 11 == 10. A remainder of 10 cannot be
    /// written as a single check digit, so no NIP has one and every tenth digit must be
    /// rejected. Comparing the remainder against the digit rejects them anyway -- correct by
    /// accident. This test is here so the branch that does it on purpose cannot be deleted
    /// as redundant.
    /// </summary>
    [Theory]
    [InlineData("1234567890")]
    [InlineData("1234567891")]
    [InlineData("1234567899")]
    public void Rejects_every_digit_when_the_remainder_is_ten(string value)
    {
        Assert.Equal(Nip.Checksum, Nip.Validate(value));
    }

    [Theory]
    [InlineData("774000145")]      // nine digits
    [InlineData("77400014540")]    // eleven
    [InlineData("1")]
    [InlineData("774-000-14-5")]
    public void Reports_LENGTH_when_there_are_not_ten_digits(string value)
    {
        Assert.Equal(Nip.Length, Nip.Validate(value));
    }

    [Theory]
    [InlineData("774000145X")]
    [InlineData("X740001454")]
    [InlineData("77400O1454")]     // letter O for zero -- the classic transcription error
    public void Reports_NONDIGIT_when_a_character_is_not_a_digit(string value)
    {
        Assert.Equal(Nip.NonDigit, Nip.Validate(value));
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("\t")]
    [InlineData(null)]
    public void Reports_EMPTY_without_throwing(string? value)
    {
        Assert.Equal(Nip.Empty, Nip.Validate(value!));
        Assert.False(Nip.IsValid(value!));
    }

    /// <summary>
    /// NFR-3: reason codes are language-neutral identifiers, not sentences. If someone
    /// localises them, a process that branches on the value breaks silently in one language.
    /// </summary>
    [Fact]
    public void Reason_codes_are_stable_identifiers()
    {
        Assert.Equal("VALID", Nip.Valid);
        Assert.Equal("EMPTY", Nip.Empty);
        Assert.Equal("LENGTH", Nip.Length);
        Assert.Equal("NONDIGIT", Nip.NonDigit);
        Assert.Equal("CHECKSUM", Nip.Checksum);
    }
}
