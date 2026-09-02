using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// Configuration for <see cref="NipValidationRule"/>.
    ///
    /// There is deliberately no ConfigEditableFormFieldID here, and there never can be.
    /// A business rule has no document (plan.md, Decision 1), so a field picker would
    /// compile, render in Designer Studio, pass Verify plugins, and then do nothing at
    /// runtime -- the worst failure mode available, because every gate we have says yes.
    ///
    /// The supported channel is TagEvaluationMode: the administrator types {field-id} into
    /// a text property and the platform substitutes the value before the plugin runs.
    /// </summary>
    public class NipValidationRuleConfig : PluginConfiguration
    {
        [ConfigEditableText(
            DisplayName = "NIP",
            Description = "The NIP to validate. Use a tag such as {157} to take it from a "
                        + "form field; the value is substituted before this rule runs.",
            TagEvaluationMode = EvaluationMode.Default,
            IsRequired = true)]
        public string Nip { get; set; }
    }
}
