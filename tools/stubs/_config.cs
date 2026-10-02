using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

namespace __NAMESPACE__
{
    /// <summary>
    /// Configuration for <see cref="__CLASS__"/>. Every property decorated with a
    /// ConfigEditable* attribute becomes a field an administrator fills in when they
    /// configure this plugin in Designer Studio.
    ///
    /// The full attribute set (text, bool, int, enum, dropdown, grid, item list,
    /// form field / data source / connection pickers) is documented in
    /// docs/sdk-reference/configuration-attributes.md.
    /// </summary>
    public class __CLASS__Config : PluginConfiguration
    {
        [ConfigEditableText(DisplayName = "Sample setting",
            Description = "Replace this with the settings your plugin actually needs.")]
        public string Sample { get; set; }
    }
}
