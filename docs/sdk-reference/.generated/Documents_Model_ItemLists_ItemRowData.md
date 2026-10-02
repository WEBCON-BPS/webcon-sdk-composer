**`ItemRowData`** — `WebCon.WorkFlow.SDK.Documents.Model.ItemLists`

Represents single row

- `Object GetCellValue(Int32, EntityValueFormat)` *(method)* — Returns value of given field
- `Task SetCellValueAsync(Int32, Object, CultureInfo)` *(method)* — Sets field value with specified culture
- `Task SetCellValueAsync(String, Object)` *(method)* — Sets column value
- `ReadOnlyEntitiesCollection<BooleanCell> BooleanCells` *(property)* — Returns collection of bolean type cells
- `ReadOnlyEntitiesCollection<CalculatedCell> CalculatedCells` *(property)* — Returns collection of Calculated type cells
- `ReadOnlyEntitiesCollection<BaseCell> Cells` *(property)* — Returns collection of base type cells
- `ReadOnlyEntitiesCollection<ChooseCell> ChooseCells` *(property)* — Returns collection of Choose type cells
- `ReadOnlyEntitiesCollection<DateTimeCell> DateTimeCells` *(property)* — Returns collection of DateTime type cells
- `ReadOnlyEntitiesCollection<DecimalCell> DecimalCells` *(property)* — Returns collection of Decimal type cells
- `Int32 ID` *(property)* — Id
- `ReadOnlyEntitiesCollection<LocalAttachmentsCell> LocalAttachmentsCells` *(property)* — Returns collection of LocalAttachments type cells
- `ReadOnlyEntitiesCollection<PickerCell> PickerCells` *(property)* — Returns collection of Picker type cells
- `ReadOnlyEntitiesCollection<RelativeAttachmentsCell> RelativeAttachmentsCells` *(property)* — Returns collection of RelativeAttachments type cells
- `ReadOnlyEntitiesCollection<SqlCell> SqlCells` *(property)* — Returns collection of Sql type cells
- `ReadOnlyEntitiesCollection<TextCell> TextCells` *(property)* — Returns collection of Text type cells
- `ReadOnlyEntitiesCollection<TreeCell> TreeCells` *(property)* — Returns collection of Tree type cells
