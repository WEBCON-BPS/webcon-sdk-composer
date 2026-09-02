using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.BusinessRulePlugins;
using WebCon.WorkFlow.SDK.BusinessRulePlugins.Model;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// FR-1: is this value a structurally valid NIP?
    ///
    /// Registered in the manifest as <c>Nip.IsValid</c>, a Boolean rule.
    ///
    /// The rule holds no logic of its own. It reads a string out of the configuration,
    /// hands it to <see cref="Nip"/>, and wraps the answer in an EvaluationResult. That is
    /// all a business rule is able to do: CustomBusinessRuleContextInfo carries no document
    /// (plan.md, Decision 1), so there is nothing here to read from or write to beyond the
    /// value the platform substituted before this ran.
    /// </summary>
    public class NipValidationRule : CustomBusinessRule<NipValidationRuleConfig>
    {
        public override async Task<EvaluationResult> EvaluateAsync(CustomBusinessRuleParams args)
        {
            string reason = Nip.Validate(Configuration.Nip);

            args.Context.PluginLogger.AppendInfo("NIP validation: " + reason);

            await Task.CompletedTask;
            return EvaluationResult.CreateBoolResult(reason == Nip.Valid);
        }
    }
}
