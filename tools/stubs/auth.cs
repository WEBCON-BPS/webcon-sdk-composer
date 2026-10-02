using System.Net.Http;
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.AutenticationPlugins;
using WebCon.WorkFlow.SDK.AutenticationPlugins.Model;

namespace __NAMESPACE__
{
    /// <summary>
    /// Custom REST authentication — hands BPS an HttpClient that is already authenticated,
    /// for APIs whose scheme WEBCON does not support out of the box.
    ///
    /// Do NOT hardcode secrets here: read them from the plugin configuration, which
    /// Designer Studio stores encrypted.
    /// Reference: docs/sdk-reference/plugin-types/authentication.md
    /// </summary>
    public class __CLASS__ : CustomRESTAuthentication<__CLASS__Config>
    {
        public override async Task<HttpClient> CreateAuthenticatedClientAsync(CustomRestAuthenticationParams args)
        {
            var client = new HttpClient();
            client.DefaultRequestHeaders.Add("X-Api-Key", Configuration.Sample);

            await Task.CompletedTask;
            return client;
        }
    }
}
