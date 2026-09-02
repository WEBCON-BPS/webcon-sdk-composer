using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

namespace Webcon.Addon.VatWhitelist.Plugin
{
    /// <summary>
    /// Configuration for <see cref="FetchVatPayerDataAction"/>.
    ///
    /// Every property here is a form field picker, which works because this is an action:
    /// ActionContextInfo declares CurrentDocument. The same attributes on a business rule
    /// would render in Designer Studio and do nothing at runtime (Constitution VIII).
    ///
    /// FormFieldTypes on each picker is not decoration. process-setup.md says field types
    /// are a contract; this is where that contract is enforced, at configuration time in
    /// Designer Studio, rather than discovered at runtime in front of a user.
    ///
    /// There is no endpoint property and no credential property. The register address is
    /// fixed and public, and NFR-6 records that it takes no key -- so there is nothing here
    /// for Principle VII to protect.
    /// </summary>
    public class FetchVatPayerDataConfig : PluginConfiguration
    {
        [ConfigEditableFormFieldID(
            DisplayName = "NIP field",
            Description = "The field holding the contractor's NIP to check.",
            FormFieldTypes = FormFieldTypes.TextSingleLine,
            IsRequired = true)]
        public int NipFieldId { get; set; }

        [ConfigEditableFormFieldID(
            DisplayName = "Check date field",
            Description = "The date to check the register against. Leave the field empty on "
                        + "the form to use today in the Warsaw timezone. The action writes "
                        + "back the date it actually used.",
            FormFieldTypes = FormFieldTypes.DateTime)]
        public int CheckDateFieldId { get; set; }

        [ConfigEditableFormFieldID(
            DisplayName = "VAT status field",
            Description = "Receives statusVat exactly as the register returns it, in Polish "
                        + "(Czynny, Zwolniony, ...). Use a text field, not a choice field: "
                        + "the register's full set of values is not published.",
            FormFieldTypes = FormFieldTypes.TextSingleLine,
            IsRequired = true)]
        public int VatStatusFieldId { get; set; }

        [ConfigEditableFormFieldID(
            DisplayName = "Registered name field",
            Description = "Receives the contractor's name as registered with the Ministry.",
            FormFieldTypes = FormFieldTypes.TextSingleLine)]
        public int RegisteredNameFieldId { get; set; }

        [ConfigEditableFormFieldID(
            DisplayName = "Request ID field",
            Description = "Receives the register's own requestId. This is the reference an "
                        + "auditor can quote back to the Ministry (FR-6).",
            FormFieldTypes = FormFieldTypes.TextSingleLine)]
        public int RequestIdFieldId { get; set; }

        [ConfigEditableFormFieldID(
            DisplayName = "Request timestamp field",
            Description = "Receives requestDateTime verbatim, as text. The register issues "
                        + "dd-MM-yyyy HH:mm:ss in Warsaw local time; it is stored unparsed "
                        + "so it stays the Ministry's timestamp rather than our rendering "
                        + "of it. Use a text field, not a date field.",
            FormFieldTypes = FormFieldTypes.TextSingleLine)]
        public int RequestTimestampFieldId { get; set; }
    }
}
