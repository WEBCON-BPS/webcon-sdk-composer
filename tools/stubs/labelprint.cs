using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.LabelPrintPlugins;
using WebCon.WorkFlow.SDK.LabelPrintPlugins.Model;

namespace __NAMESPACE__
{
    /// <summary>
    /// Custom label print template — returns the raw printer payload (e.g. ZPL) that
    /// replaces the standard barcode template.
    /// Reference: docs/sdk-reference/plugin-types/label-print.md
    /// </summary>
    public class __CLASS__ : CustomLabelPrint<__CLASS__Config>
    {
        protected override async Task<string> OnGetLabelCustomAsync(CustomLabelPrintParams args)
        {
            await Task.CompletedTask;
            return $"^XA^FO50,50^ADN,36,20^FD{Configuration.Sample}^FS^XZ";
        }
    }
}
