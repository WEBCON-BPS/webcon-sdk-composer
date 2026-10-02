using WebCon.WorkFlow.SDK.ConfigAttributes;
using WebCon.WorkFlow.SDK.Common;

namespace Webcon.Addon.Template.CustomActions.HelloWorld
{
    /// <summary>
    /// Configuration for <see cref="HelloWorldAction"/>.
    /// Properties decorated with ConfigEditable* attributes render as fields in
    /// Designer Studio when an administrator configures the action.
    /// </summary>
    public class HelloWorldConfig : PluginConfiguration
    {
        [ConfigEditableText(DisplayName = "Greeting target",
            Description = "Who to greet. Leave empty to greet WEBCON.")]
        public string GreetingTarget { get; set; }
    }
}
