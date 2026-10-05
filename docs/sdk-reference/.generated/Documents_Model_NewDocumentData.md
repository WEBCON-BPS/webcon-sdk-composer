**`NewDocumentData`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing paremeters for new document

- `Object GetFieldValue(Int32 fieldID, EntityValueFormat format)` *(method)* — Gets formatted value based on id
- `Task SetFieldValueAsync(Int32 fieldID, Object value, CultureInfo culture)` *(method)* — Sets field value with specified culture
- `AttachmentsCollection Attachments` *(property)* — Attachments collection
- `ReadOnlyEntitiesCollection<AuthenticationField> AuthenticationFields` *(property)* — Gets collection of AuthenticationField form fields only
- `ReadOnlyEntitiesCollection<BooleanField> BooleanFields` *(property)* — Gets collection of BooleanField form fields only
- `ReadOnlyEntitiesCollection<ChooseField> ChooseFields` *(property)* — Gets collection of ChooseField form fields only
- `CommentStorage Comment` *(property)* — Gets comments
- `ReadOnlyEntitiesCollection<CommentField> CommentFields` *(property)* — Gets collection of CommentField form fields only
- `Int32 CompanyID` *(property)* — Gets company id
- `ReadOnlyEntitiesCollection<DateTimeField> DateTimeFields` *(property)* — Gets collection of DateTimeField form fields only
- `ReadOnlyEntitiesCollection<DecimalField> DecimalFields` *(property)* — Gets collection of DecimalField form fields only
- `Int32 DocumentTypeID` *(property)* — Gets document type id
- `ReadOnlyCollection<TaskData> ExistingTasks` *(property)* — Gets existing tasks collection
- `ReadOnlyEntitiesCollection<BaseField> Fields` *(property)* — Gets collection that contains all form fields
- `ReadOnlyEntitiesCollection<HyperlinkField> HyperlinkFields` *(property)* — Gets collection of HyperlinkField form fields only
- `ReadOnlyEntitiesCollection<IntegerField> IntegerFields` *(property)* — Gets collection of IntegerField form fields only
- `ReadOnlyItemsCollection<ItemsList> ItemsLists` *(property)* — Gets list of items lists
- `ReadOnlyEntitiesCollection<MapField> MapFields` *(property)* — Gets collection of MapField form fields only
- `ReadOnlyEntitiesCollection<PeopleField> PeopleFields` *(property)* — Gets collection of PeopleField form fields only
- `ReadOnlyEntitiesCollection<PickerField> PickerFields` *(property)* — Gets collection of PickerField form fields only
- `Int32 ProcessID` *(property)* — Gets process id
- `ReadOnlyEntitiesCollection<SqlField> SqlFields` *(property)* — Gets collection of SqlField form fields only
- `Int32 StepID` *(property)* — Gets step id
- `Nullable<Int32> SubDocumentTypeID` *(property)* — Gets subdocument type id
- `ReadOnlyEntitiesCollection<SurveyChooseField> SurveyChooseFields` *(property)* — Gets collection of SurveyChooseField form fields only
- `ReadOnlyEntitiesCollection<SurveyScaleField> SurveyScaleFields` *(property)* — Gets collection of SurveyScaleField form fields only
- `ReadOnlyEntitiesCollection<TextField> TextFields` *(property)* — Gets collection of TextField form fields only
- `ReadOnlyEntitiesCollection<TreeField> TreeFields` *(property)* — Gets collection of TreeField form fields only
- `Int32 WorkFlowID` *(property)* — Gets workflow id
