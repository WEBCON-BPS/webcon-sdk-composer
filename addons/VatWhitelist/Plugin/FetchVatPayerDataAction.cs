using System;
using System.Globalization;
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.ActionPlugins;
using WebCon.WorkFlow.SDK.ActionPlugins.Model;
using WebCon.WorkFlow.SDK.Documents.Model;
using Webcon.Addon.VatWhitelist.Plugin.Register;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// FR-3, FR-4, FR-5 and FR-6. Checks a NIP against the Ministry of Finance VAT
    /// whitelist and writes the answer, and the evidence that it was asked, onto the
    /// instance.
    ///
    /// This is an action rather than a business rule for two reasons settled in plan.md,
    /// Decision 1: a rule has no document to write FR-6's evidence to, and a rule is
    /// evaluated as often as the platform likes, which cannot be reconciled with a budget
    /// of 100 lookups a day (NFR-5). Attaching this action to step entry, a timer, or a
    /// field default reintroduces exactly that problem -- see process-setup.md.
    /// </summary>
    public class FetchVatPayerDataAction : CustomAction<FetchVatPayerDataConfig>
    {
        private readonly VatRegisterClient _client;

        public FetchVatPayerDataAction() : this(new VatRegisterClient())
        {
        }

        /// <summary>Test seam: offline tests supply a client that never reaches the network.</summary>
        public FetchVatPayerDataAction(VatRegisterClient client)
        {
            _client = client;
        }

        public override async Task RunAsync(RunCustomActionParams args)
        {
            CurrentDocumentData document = args.Context.CurrentDocument;

            string nip = AsText(document.GetFieldValue(Configuration.NipFieldId, EntityValueFormat.FullValue));

            // FR-1 guarding NFR-5. A typo is rejected here, for nothing, instead of being
            // sent to the register for one percent of the day's budget and a Polish
            // sentence back. The register does validate the check digit (WL-115) -- this is
            // not about what it can tell us, it is about what asking costs.
            string reason = Nip.Validate(nip);
            if (reason != Nip.Valid)
            {
                args.Message = "Not a valid NIP (" + reason + "). No lookup was made.";
                args.HasErrors = true;
                args.Context.PluginLogger.AppendInfo("Skipped lookup, NIP rejected locally: " + reason);
                return;
            }

            string registerDay = ResolveRegisterDay(document);

            VatLookupResult result = await _client
                .LookupAsync(nip, registerDay, args.Context.CancellationToken)
                .ConfigureAwait(false);

            if (result.Outcome == VatLookupOutcome.Failed)
            {
                // The register did not answer, or refused the query. The instance is left
                // untouched: a half-written answer is worse than no answer.
                args.Message = result.ErrorCode == null
                    ? "The VAT register could not be reached. " + result.ErrorMessage
                    : "The VAT register refused the query (" + result.ErrorCode + "): " + result.ErrorMessage;
                args.HasErrors = true;
                args.Context.PluginLogger.AppendInfo(args.Message);
                return;
            }

            await WriteAnswerAsync(document, result, registerDay).ConfigureAwait(false);

            if (result.Outcome == VatLookupOutcome.NotInRegister)
            {
                // FR-4. A successful check with a negative answer. HasErrors stays false so
                // this routes to whoever decides about the payment, not to whoever fixes
                // integrations.
                args.Message = "Checked on " + registerDay + ": this NIP is not in the VAT whitelist.";
            }
            else
            {
                args.Message = "Checked on " + registerDay + ": " + result.Subject.StatusVat
                             + " (" + result.Subject.Name + ").";
            }

            args.LogMessage = args.Message + (result.FromCache ? " [cached, no query spent]" : "");
            args.Context.PluginLogger.AppendInfo(args.LogMessage);
        }

        /// <summary>
        /// FR-5 and FR-6, written the same way whether the answer was positive or negative.
        ///
        /// Not in the register means the status is written as an empty value rather than
        /// left at whatever a previous check put there. A stale "Czynny" next to a fresh
        /// request ID is the one outcome here that could cost somebody real money.
        /// </summary>
        private async Task WriteAnswerAsync(CurrentDocumentData document, VatLookupResult result,
                                            string registerDay)
        {
            bool found = result.Outcome == VatLookupOutcome.Found;

            await SetAsync(document, Configuration.VatStatusFieldId,
                found ? result.Subject.StatusVat : string.Empty).ConfigureAwait(false);

            await SetAsync(document, Configuration.RegisteredNameFieldId,
                found ? result.Subject.Name : string.Empty).ConfigureAwait(false);

            await SetAsync(document, Configuration.RequestIdFieldId, result.RequestId).ConfigureAwait(false);

            // Verbatim. dd-MM-yyyy HH:mm:ss, Warsaw local, exactly as issued. Parsing this
            // into a DateTime and letting the field format it would replace the Ministry's
            // timestamp with our rendering of it, which is worth less as evidence.
            await SetAsync(document, Configuration.RequestTimestampFieldId,
                result.RequestDateTime).ConfigureAwait(false);

            if (Configuration.CheckDateFieldId > 0)
            {
                await document.SetFieldValueAsync(Configuration.CheckDateFieldId,
                    DateTime.ParseExact(registerDay, RegisterDay.QueryFormat, CultureInfo.InvariantCulture),
                    CultureInfo.InvariantCulture).ConfigureAwait(false);
            }
        }

        private static Task SetAsync(CurrentDocumentData document, int fieldId, string value)
        {
            if (fieldId <= 0) return Task.CompletedTask;   // optional field, not configured
            return document.SetFieldValueAsync(fieldId, value ?? string.Empty, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// The date the check is made against. Empty means today -- in Warsaw, because that
        /// is the day the register itself is keyed on (finding 6), not the day it is in UTC.
        /// </summary>
        private string ResolveRegisterDay(CurrentDocumentData document)
        {
            if (Configuration.CheckDateFieldId > 0)
            {
                object raw = document.GetFieldValue(Configuration.CheckDateFieldId, EntityValueFormat.FullValue);
                if (raw is DateTime chosen && chosen != default(DateTime))
                    return chosen.ToString(RegisterDay.QueryFormat, CultureInfo.InvariantCulture);
            }

            return RegisterDay.Today();
        }

        private static string AsText(object value)
        {
            return value == null ? string.Empty : value.ToString();
        }
    }
}
