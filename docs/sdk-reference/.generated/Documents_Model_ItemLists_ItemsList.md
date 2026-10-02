**`ItemsList`** — `WebCon.WorkFlow.SDK.Documents.Model.ItemLists`

Holds one row from item list

- `Task RecalculateAsync()` *(method)* — Method calculating the values ​​of calculated columns
- `ReadOnlyEntitiesCollection<ColumnInfo> BooleanColumns` *(property)* — List of bolean column s
- `ReadOnlyEntitiesCollection<ColumnInfo> CalculatedColumns` *(property)* — List of calculated columns
- `ReadOnlyEntitiesCollection<ChooseColumnInfo> ChooseColumns` *(property)* — List of choose columns
- `ReadOnlyEntitiesCollection<ColumnInfo> Columns` *(property)* — List of columns
- `ReadOnlyEntitiesCollection<ColumnInfo> DateTimeColumns` *(property)* — List of date columns
- `ReadOnlyEntitiesCollection<DecimalColumnInfo> DecimalColumns` *(property)* — List of decimal columns
- `ReadOnlyEntitiesCollection<AttachmentsColumnInfo> LocalAttachmentsColumns` *(property)* — List of attachment columns
- `ReadOnlyEntitiesCollection<PickerColumnInfo> PickerColumns` *(property)* — List of picker columns
- `ReadOnlyEntitiesCollection<AttachmentsColumnInfo> RelativeAttachmentsColumns` *(property)* — List of relative attachment columns
- `ItemRowDataCollection Rows` *(property)* — All rows collection
- `ReadOnlyEntitiesCollection<ColumnInfo> SqlColumns` *(property)* — List of sql columns
- `ReadOnlyEntitiesCollection<TextColumnInfo> TextColumns` *(property)* — List of text columns
- `ReadOnlyEntitiesCollection<ChooseColumnInfo> TreeColumns` *(property)* — List of tree columns

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
