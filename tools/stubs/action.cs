using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.ActionPlugins;
using WebCon.WorkFlow.SDK.ActionPlugins.Model;

namespace __NAMESPACE__
{
    /// <summary>
    /// Custom action — runs on a path transition, a menu button, step entry/exit or a timer.
    /// Reference: docs/sdk-reference/plugin-types/custom-action.md
    /// </summary>
    public class __CLASS__ : CustomAction<__CLASS__Config>
    {
        public override async Task RunAsync(RunCustomActionParams args)
        {
            args.Context.PluginLogger.AppendInfo("__CLASS__ executed.");

            // args.Message is shown to the user; set args.HasErrors to block the transition.
            args.Message = $"__CLASS__ ran with '{Configuration.Sample}'.";

            await Task.CompletedTask;
        }
    }
}
