using WebCon.WorkFlow.SDK.ConfigAttributes;
using WebCon.WorkFlow.SDK.Common;

namespace Webcon.Example.ExternalService.CustomActions.CallService
{
    /// <summary>
    /// Configuration for <see cref="CallServiceAction"/>.
    /// </summary>
    public class CallServiceConfig : PluginConfiguration
    {
        [ConfigEditableText(DisplayName = "Service URL",
            Description = "HTTP(S) endpoint to call with a GET request.")]
        public string ServiceUrl { get; set; }
    }
}
