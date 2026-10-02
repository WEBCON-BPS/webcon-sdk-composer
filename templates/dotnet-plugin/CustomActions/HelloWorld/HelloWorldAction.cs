using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.ActionPlugins;
using WebCon.WorkFlow.SDK.ActionPlugins.Model;

namespace Webcon.Addon.Template.CustomActions.HelloWorld
{
    /// <summary>
    /// Minimal "hello world" Custom Action.
    ///
    /// This is the entry point WEBCON BPS calls when the action fires. It demonstrates the
    /// three things every action does: read its configuration, log, and return a message to
    /// the user. Build it, Publish it with SDK Tools, and register the package in Designer
    /// Studio — it works unmodified. Then make it your own (constitution: fix the spec, not
    /// the code — regenerate via the Spec-Kit loop).
    /// </summary>
    public class HelloWorldAction : CustomAction<HelloWorldConfig>
    {
        public override async Task RunAsync(RunCustomActionParams args)
        {
            var target = string.IsNullOrWhiteSpace(Configuration.GreetingTarget)
                ? "WEBCON"
                : Configuration.GreetingTarget;

            // Write to the plugin log (visible in BPS SDK logs).
            args.Context.PluginLogger.AppendInfo($"HelloWorldAction executed for '{target}'.");

            // Return a message shown to the end user.
            args.Message = $"Hello, {target}! Your WEBCON BPS SDK add-on is alive.";

            await Task.CompletedTask;
        }
    }
}
