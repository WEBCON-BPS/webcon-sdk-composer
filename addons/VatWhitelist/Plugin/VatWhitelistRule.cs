using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.BusinessRulePlugins;
using WebCon.WorkFlow.SDK.BusinessRulePlugins.Model;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// Custom business rule — returns a value that Designer Studio can use anywhere a
    /// business rule is allowed (defaults, visibility, conditions).
    /// Reference: docs/sdk-reference/plugin-types/business-rule.md
    /// </summary>
    public class VatWhitelistRule : CustomBusinessRule<VatWhitelistRuleConfig>
    {
        public override async Task<EvaluationResult> EvaluateAsync(CustomBusinessRuleParams args)
        {
            args.Context.PluginLogger.AppendInfo("VatWhitelistRule evaluated.");

            // EvaluationResult has one factory per rule type — CreateBoolResult,
            // CreateDecimalResult, CreateDateTimeResult, CreatUserListResult.

            await Task.CompletedTask;
            return EvaluationResult.CreateStringResult(Configuration.Sample);
        }
    }
}
