using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// Configuration for <see cref="VatWhitelistRule"/>. Every property decorated with a
    /// ConfigEditable* attribute becomes a field an administrator fills in when they
    /// configure this plugin in Designer Studio.
    ///
    /// The full attribute set (text, bool, int, enum, dropdown, grid, item list,
    /// form field / data source / connection pickers) is documented in
    /// docs/sdk-reference/configuration-attributes.md.
    /// </summary>
    public class VatWhitelistRuleConfig : PluginConfiguration
    {
        [ConfigEditableText(DisplayName = "Sample setting",
            Description = "Replace this with the settings your plugin actually needs.")]
        public string Sample { get; set; }
    }
}
