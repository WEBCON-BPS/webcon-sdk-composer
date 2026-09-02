using System;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// Structural validation of a Polish NIP: ten digits with a mod-11 check digit.
    /// FR-1 and FR-2.
    ///
    /// This file deliberately references no SDK type. It is the part of the add-on most
    /// worth testing and the part that least needs a BPS environment, and keeping those two
    /// facts aligned is what makes NFR-2 -- every test runs offline -- cheap rather than
    /// aspirational.
    ///
    /// It is a pre-filter, not the authority. The register applies its own validation and
    /// rejects a bad check digit with HTTP 400 / WL-115 (register-findings.md, finding 2).
    /// The reason to check here anyway is NFR-5: a typo that reaches the register costs one
    /// of a hundred daily queries and comes back as a Polish sentence, where this costs
    /// nothing and comes back as a reason code.
    /// </summary>
    public static class Nip
    {
        /// <summary>Reason codes. Language-neutral by NFR-3, so a process can branch on
        /// them without parsing a sentence in any language.</summary>
        public const string Valid = "VALID";
        public const string Empty = "EMPTY";
        public const string Length = "LENGTH";
        public const string NonDigit = "NONDIGIT";
        public const string Checksum = "CHECKSUM";

        private static readonly int[] Weights = { 6, 5, 7, 2, 3, 4, 5, 6, 7 };

        /// <summary>
        /// Returns <see cref="Valid"/>, or the reason the value is not a NIP.
        /// </summary>
        public static string Validate(string value)
        {
            string digits = Normalize(value);

            if (digits.Length == 0) return Empty;
            if (digits.Length != 10) return Length;

            int sum = 0;
            for (int i = 0; i < 9; i++)
            {
                int d = digits[i] - '0';
                if (d < 0 || d > 9) return NonDigit;
                sum += d * Weights[i];
            }

            int last = digits[9] - '0';
            if (last < 0 || last > 9) return NonDigit;

            int remainder = sum % 11;

            // A remainder of 10 cannot be written as a single check digit, so no NIP has
            // one. Comparing it against digits[9] would reject every such value anyway --
            // correct by accident. Rejecting it here is correct on purpose, and says so.
            if (remainder == 10) return Checksum;

            return remainder == last ? Valid : Checksum;
        }

        /// <summary>FR-1. The Boolean half of the same question.</summary>
        public static bool IsValid(string value)
        {
            return Validate(value) == Valid;
        }

        /// <summary>
        /// Separators and an optional PL prefix are presentation, not identity:
        /// 774-000-14-54, PL7740001454 and 7740001454 are the same taxpayer.
        /// Anything not stripped here is left in place, so Validate reports NONDIGIT
        /// rather than quietly discarding it.
        /// </summary>
        private static string Normalize(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return string.Empty;

            string s = value.Trim();
            if (s.Length > 2 && (s[0] == 'P' || s[0] == 'p') && (s[1] == 'L' || s[1] == 'l'))
                s = s.Substring(2);

            var sb = new System.Text.StringBuilder(s.Length);
            foreach (char c in s)
            {
                if (c == '-' || c == ' ' || c == '.' || c == '\t') continue;
                sb.Append(c);
            }

            return sb.ToString();
        }
    }
}
