using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.Common.Model;
using WebCon.WorkFlow.SDK.DataSourcePlugins;
using WebCon.WorkFlow.SDK.DataSourcePlugins.Model;

namespace __NAMESPACE__
{
    /// <summary>
    /// Custom data source — supplies rows to pickers, reports and choice fields.
    /// Declare the columns once in GetColumnsAsync; GetDataAsync must return a DataTable
    /// with exactly those columns.
    /// Reference: docs/sdk-reference/plugin-types/data-source.md
    /// </summary>
    public class __CLASS__ : CustomDataSource<__CLASS__Config>
    {
        public override async Task<List<DataSourceColumn>> GetColumnsAsync()
        {
            await Task.CompletedTask;
            return new List<DataSourceColumn>
            {
                new DataSourceColumn { Name = "ID", DisplayName = "ID" },
                new DataSourceColumn { Name = "Name", DisplayName = "Name" },
            };
        }

        public override async Task<DataTable> GetDataAsync(SearchConditions searchConditions)
        {
            var table = new DataTable();
            table.Columns.Add("ID", typeof(int));
            table.Columns.Add("Name", typeof(string));
            table.Rows.Add(1, Configuration.Sample);

            await Task.CompletedTask;
            return table;
        }
    }
}
