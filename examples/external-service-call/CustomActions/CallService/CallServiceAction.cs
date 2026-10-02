using System;
using System.Net.Http;
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.ActionPlugins;
using WebCon.WorkFlow.SDK.ActionPlugins.Model;

namespace Webcon.Example.ExternalService.CustomActions.CallService
{
    /// <summary>
    /// Sample Custom Action: sends an HTTP GET to a configured URL and returns the result
    /// to the user. This is the canonical "call an external web service" pattern — the most
    /// common reason to write an SDK add-on.
    /// </summary>
    public class CallServiceAction : CustomAction<CallServiceConfig>
    {
        // A single, reused HttpClient (best practice — avoid socket exhaustion).
        private static readonly HttpClient HttpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        public override async Task RunAsync(RunCustomActionParams args)
        {
            var url = Configuration.ServiceUrl;

            if (string.IsNullOrWhiteSpace(url))
            {
                args.Message = "No Service URL configured.";
                args.HasErrors = true;
                return;
            }

            args.Context.PluginLogger.AppendInfo($"Calling external service: {url}");

            try
            {
                using (var response = await HttpClient.GetAsync(url))
                {
                    var status = (int)response.StatusCode;
                    var body = await response.Content.ReadAsStringAsync();
                    var preview = body.Length > 200 ? body.Substring(0, 200) + "…" : body;

                    args.Context.PluginLogger.AppendInfo(
                        $"Response {status} ({response.StatusCode}); {body.Length} chars.");

                    if (response.IsSuccessStatusCode)
                    {
                        args.Message = $"Service returned {status}. Preview: {preview}";
                    }
                    else
                    {
                        args.Message = $"Service returned {status} ({response.StatusCode}).";
                        args.HasErrors = true;
                    }
                }
            }
            catch (Exception ex)
            {
                args.Context.PluginLogger.AppendInfo($"Call failed: {ex}");
                args.Message = $"Call failed: {ex.Message}";
                args.HasErrors = true;
            }
        }
    }
}
