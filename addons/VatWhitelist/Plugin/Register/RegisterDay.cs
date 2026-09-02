using System;

namespace Webcon.Addon.VatWhitelist.Plugin.Register
{
    /// <summary>
    /// "The register's day" is the Europe/Warsaw day, not the UTC day.
    ///
    /// Finding 6 in register-findings.md: the register stamps its answers in Warsaw local
    /// time. One measured response carried an HTTP Date header of 07:12:51 GMT and a
    /// requestDateTime of 09:12:39 in the body -- exactly +2h.
    ///
    /// A cache keyed on the UTC day is therefore wrong for two hours every night in summer
    /// and one in winter: at 00:30 Warsaw it is still yesterday in UTC, so a UTC-keyed cache
    /// serves a stale answer into a new register day, and the whole point of the cache --
    /// one contractor, one query per day, SC-002 -- silently stops holding on exactly the
    /// dates it matters.
    ///
    /// No SDK type here, so this is testable offline like <see cref="Nip"/>.
    /// </summary>
    public static class RegisterDay
    {
        /// <summary>The register's own date format for the ?date= parameter.</summary>
        public const string QueryFormat = "yyyy-MM-dd";

        private static readonly TimeZoneInfo Warsaw = ResolveWarsaw();

        /// <summary>
        /// The register day that <paramref name="instant"/> falls in, as yyyy-MM-dd.
        /// </summary>
        public static string For(DateTimeOffset instant)
        {
            return TimeZoneInfo.ConvertTime(instant, Warsaw).ToString(QueryFormat,
                System.Globalization.CultureInfo.InvariantCulture);
        }

        /// <summary>Today, in Warsaw.</summary>
        public static string Today()
        {
            return For(DateTimeOffset.UtcNow);
        }

        /// <summary>
        /// The IANA id works on .NET 6+; the Windows id is what .NET Framework 4.7.2 on the
        /// BPS Service host understands. One assembly targets netstandard2.0 and loads in
        /// both, so both have to be tried.
        ///
        /// If neither resolves -- a stripped container with no timezone database -- the
        /// exception is allowed to escape rather than falling back to UTC. A cache silently
        /// keyed on the wrong day is worse than a plugin that refuses to start, because the
        /// first is invisible and the second is not.
        /// </summary>
        private static TimeZoneInfo ResolveWarsaw()
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("Central European Standard Time");
            }
            catch (TimeZoneNotFoundException)
            {
                return TimeZoneInfo.FindSystemTimeZoneById("Europe/Warsaw");
            }
        }
    }
}
