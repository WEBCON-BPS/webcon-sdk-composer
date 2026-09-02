using System;
using System.Collections.Concurrent;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace Webcon.Addon.VatWhitelist.Plugin.Register
{
    public enum VatLookupOutcome
    {
        /// <summary>The register holds this NIP on this date.</summary>
        Found,

        /// <summary>
        /// The register answered, and holds no such subject. HTTP 200, subject null.
        /// FR-4: an answer, not a failure.
        /// </summary>
        NotInRegister,

        /// <summary>The register did not answer, or refused the query. This is the error.</summary>
        Failed
    }

    public sealed class VatLookupResult
    {
        public VatLookupOutcome Outcome { get; set; }
        public VatSubject Subject { get; set; }
        public string RequestId { get; set; }
        public string RequestDateTime { get; set; }
        public string ErrorCode { get; set; }
        public string ErrorMessage { get; set; }
        public bool FromCache { get; set; }
    }

    /// <summary>
    /// Reads the Ministry of Finance VAT whitelist.
    ///
    /// Two things here exist because of NFR-5, the 100-lookups-per-day budget, and both are
    /// worth more than they look.
    /// </summary>
    public sealed class VatRegisterClient
    {
        public const string BaseUrl = "https://wl-api.mf.gov.pl/api/search/nip/";

        /// <summary>
        /// One HttpClient for the process, not one per call.
        ///
        /// A new HttpClient per call leaves its socket in TIME_WAIT for minutes after
        /// disposal, so a busy Service host runs out of ephemeral ports and every outbound
        /// call starts failing -- including calls to other systems entirely. It is the
        /// single most common way this integration breaks, and it does not reproduce in
        /// testing because it needs load.
        /// </summary>
        private static readonly HttpClient SharedHttp = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        /// <summary>
        /// One register day's answers, keyed nip|yyyy-MM-dd, cleared when the Warsaw day
        /// rolls over so it cannot grow without bound in a service that runs for months.
        /// </summary>
        private static readonly ConcurrentDictionary<string, VatLookupResult> Cache =
            new ConcurrentDictionary<string, VatLookupResult>(StringComparer.Ordinal);

        private static string _cachedDay;
        private static readonly object DayLock = new object();

        private readonly Func<string, CancellationToken, Task<HttpResponseMessage>> _send;

        public VatRegisterClient()
            : this((url, ct) => SharedHttp.GetAsync(url, ct))
        {
        }

        /// <summary>
        /// Test seam. Offline tests (NFR-2) supply their own responder; nothing in the test
        /// suite is allowed to reach the network.
        /// </summary>
        public VatRegisterClient(Func<string, CancellationToken, Task<HttpResponseMessage>> send)
        {
            _send = send ?? throw new ArgumentNullException(nameof(send));
        }

        /// <summary>
        /// Looks up <paramref name="nip"/> as the register held it on
        /// <paramref name="registerDay"/> (yyyy-MM-dd, a Warsaw day -- see
        /// <see cref="RegisterDay"/>).
        ///
        /// Repeating the same NIP on the same register day costs one HTTP call, not two.
        /// That is SC-002 made true rather than asserted: the register's answer for a given
        /// NIP on a given day does not change, so a second query buys nothing and spends
        /// one percent of the daily budget.
        /// </summary>
        public async Task<VatLookupResult> LookupAsync(string nip, string registerDay,
                                                       CancellationToken cancellationToken)
        {
            EvictIfDayChanged(registerDay);

            string key = nip + "|" + registerDay;
            VatLookupResult cached;
            if (Cache.TryGetValue(key, out cached))
            {
                return new VatLookupResult
                {
                    Outcome = cached.Outcome,
                    Subject = cached.Subject,
                    RequestId = cached.RequestId,
                    RequestDateTime = cached.RequestDateTime,
                    ErrorCode = cached.ErrorCode,
                    ErrorMessage = cached.ErrorMessage,
                    FromCache = true
                };
            }

            VatLookupResult result = await FetchAsync(nip, registerDay, cancellationToken)
                .ConfigureAwait(false);

            // A failure is not cached. A timeout or a 500 says nothing about what the
            // register holds, and caching it would turn one bad minute into a bad day.
            // WL-115 and WL-103 are not cached either: they are about the query, not the
            // subject, and the caller can fix the query and retry immediately.
            if (result.Outcome != VatLookupOutcome.Failed)
                Cache.TryAdd(key, result);

            return result;
        }

        private async Task<VatLookupResult> FetchAsync(string nip, string registerDay,
                                                       CancellationToken cancellationToken)
        {
            string url = BaseUrl + Uri.EscapeDataString(nip) + "?date=" + Uri.EscapeDataString(registerDay);

            try
            {
                using (HttpResponseMessage response = await _send(url, cancellationToken).ConfigureAwait(false))
                {
                    string body = response.Content == null
                        ? null
                        : await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                    if (!response.IsSuccessStatusCode)
                        return FromErrorBody(body, (int)response.StatusCode);

                    VatSearchResponse parsed = VatRegisterJson.Parse<VatSearchResponse>(body);
                    if (parsed?.Result == null)
                        return Failure(null, "The register returned a body this add-on could not read.");

                    return new VatLookupResult
                    {
                        // HTTP 200 with a null subject. An answer, not a failure (FR-4).
                        Outcome = parsed.Result.Subject == null
                            ? VatLookupOutcome.NotInRegister
                            : VatLookupOutcome.Found,
                        Subject = parsed.Result.Subject,
                        RequestId = parsed.Result.RequestId,
                        RequestDateTime = parsed.Result.RequestDateTime
                    };
                }
            }
            catch (Exception ex)
            {
                return Failure(null, ex.Message);
            }
        }

        private static VatLookupResult FromErrorBody(string body, int statusCode)
        {
            VatRegisterError error = null;
            try
            {
                error = VatRegisterJson.Parse<VatRegisterError>(body);
            }
            catch
            {
                // Not the flat shape we know. Fall through and report the status instead of
                // pretending we understood it.
            }

            if (error != null && !string.IsNullOrEmpty(error.Code))
                return Failure(error.Code, error.Message);

            return Failure(null, "The register refused the query with HTTP " + statusCode + ".");
        }

        private static VatLookupResult Failure(string code, string message)
        {
            return new VatLookupResult
            {
                Outcome = VatLookupOutcome.Failed,
                ErrorCode = code,
                ErrorMessage = message
            };
        }

        private static void EvictIfDayChanged(string registerDay)
        {
            if (_cachedDay == registerDay) return;

            lock (DayLock)
            {
                if (_cachedDay == registerDay) return;
                Cache.Clear();
                _cachedDay = registerDay;
            }
        }

        /// <summary>Test-only: the cache is static, so tests must be able to reset it.</summary>
        public static void ResetCache()
        {
            lock (DayLock)
            {
                Cache.Clear();
                _cachedDay = null;
            }
        }
    }
}
