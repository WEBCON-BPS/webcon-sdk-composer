using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// What this registration of the rule answers.
    ///
    /// One evaluation carries one typed value -- BusinessRuleType is
    /// String=1, Decimal=2, Boolean=3, Date=4, UserList=5 -- and
    /// CustomBusinessRuleParams exposes only Context, so unlike an action's params there is
    /// no Message and no HasErrors to carry an explanation alongside a verdict.
    ///
    /// So "is it valid" and "why is it not" cannot travel together. They are two
    /// registrations of this one plugin, not two plugins.
    /// </summary>
    public enum NipRuleMode
    {
        /// <summary>FR-1. Boolean rule, registered as Nip.IsValid.</summary>
        IsValid = 0,

        /// <summary>FR-2. Text rule, registered as Nip.Validate. Returns a reason code.</summary>
        Reason = 1
    }

    /// <summary>
    /// Configuration for <see cref="NipValidationRule"/>.
    ///
    /// There is deliberately no ConfigEditableFormFieldID here, and there never can be
    /// (Constitution VIII). A business rule has no document, so a field picker would
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

        [ConfigEditableEnum(
            DisplayName = "Mode",
            Description = "IsValid returns true or false and must be registered as a "
                        + "Boolean rule. Reason returns a code (VALID, EMPTY, LENGTH, "
                        + "NONDIGIT, CHECKSUM) and must be registered as a text rule. "
                        + "The mode must match the rule type chosen in Designer Studio.",
            DefaultValue = (int)NipRuleMode.IsValid)]
        public NipRuleMode Mode { get; set; }
    }
}
