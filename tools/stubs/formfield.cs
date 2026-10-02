using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.FormFieldPlugins;
using WebCon.WorkFlow.SDK.FormFieldPlugins.Model;

namespace __NAMESPACE__
{
    /// <summary>
    /// Form field extension — server-side hooks around a standard field's lifecycle.
    /// Override only what you need; the other hooks (OnBeforeElementSaveAsync,
    /// ValidateAsync, OnBeforeElementDeleteAsync) are listed in the reference.
    ///
    /// This is NOT how you draw UI — for that you want a JS custom control
    /// (templates/js-custom-control). See docs/plugin-types.md.
    /// Reference: docs/sdk-reference/plugin-types/form-field.md
    /// </summary>
    public class __CLASS__ : FormFieldExtension<__CLASS__Config>
    {
        public override async Task OnAfterElementSaveAsync(AfterSaveParams<FormFieldExtensionContext> args)
        {
            args.Context.PluginLogger.AppendInfo("__CLASS__ ran after save.");
            await Task.CompletedTask;
        }
    }
}
