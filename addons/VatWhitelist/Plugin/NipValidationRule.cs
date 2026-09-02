using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.BusinessRulePlugins;
using WebCon.WorkFlow.SDK.BusinessRulePlugins.Model;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// FR-1 and FR-2. One plugin class, registered twice:
    ///
    ///   Nip.IsValid   Boolean rule, Mode = IsValid  -> true / false
    ///   Nip.Validate  Text rule,    Mode = Reason   -> VALID | EMPTY | LENGTH |
    ///                                                  NONDIGIT | CHECKSUM
    ///
    /// Two registrations rather than two classes because the checksum is the same
    /// checksum. Copying this file to change one return statement is how the two copies
    /// drift, and a NIP that one registration accepts and the other explains away is worse
    /// than either answer alone.
    ///
    /// Two registrations rather than one because the platform allows exactly one typed
    /// value per evaluation and gives a rule no side channel -- see NipRuleMode.
    ///
    /// The rule holds no logic of its own. It reads a string out of the configuration,
    /// hands it to <see cref="Nip"/>, and wraps the answer. That is the whole of what a
    /// business rule can do: CustomBusinessRuleContextInfo carries no document
    /// (Constitution VIII), so there is nothing here to read from or write to beyond the
    /// value the platform substituted before this ran.
    /// </summary>
    public class NipValidationRule : CustomBusinessRule<NipValidationRuleConfig>
    {
        public override async Task<EvaluationResult> EvaluateAsync(CustomBusinessRuleParams args)
        {
            string reason = Nip.Validate(Configuration.Nip);

            args.Context.PluginLogger.AppendInfo(
                "NIP validation (" + Configuration.Mode + "): " + reason);

            await Task.CompletedTask;

            return Configuration.Mode == NipRuleMode.Reason
                ? EvaluationResult.CreateStringResult(reason)
                : EvaluationResult.CreateBoolResult(reason == Nip.Valid);
        }
    }
}
