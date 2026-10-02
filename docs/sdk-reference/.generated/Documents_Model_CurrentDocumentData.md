**`CurrentDocumentData`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class represents workflow object data in the context of which plugin is running

- `Task UpdateDocumentCompanyAsync(Int32 newCompanyID)` *(method)* — Document company change.
- `Task UpdateDocumentSubTypeAsync(Nullable<Int32> newDocumentSubTypeID)` *(method)* — Document subtype change.
- `Task UpdateDocumentTypeAsync(Int32 newDocumentTypeID)` *(method)* — Document type change.
- `Task UpdateInstanceNumberAsync(InstanceNumberFormat numberFormat, InstanceNumberPartitioning numberPartitioning)` *(method)* — Updating instance number

Inherited from `ExistingDocumentData`:

- `Task SetParentDocumentIDAsync(Nullable<Int32>)` *(method, inherited from ExistingDocumentData)* — Set parent workflow ID
- `Nullable<Int32> ParentDocumentID` *(property, inherited from ExistingDocumentData)* — Parent workflow ID

Inherited from `DocumentData`:

- `UserInfo CreatedBy` *(property, inherited from DocumentData)* — Gets creator of workflow object
- `DateTime CreationTime` *(property, inherited from DocumentData)* — Gets creation time of workflow object
- `Int32 ID` *(property, inherited from DocumentData)* — Gets object ID
- `String InstanceNumber` *(property, inherited from DocumentData)* — Gets workflow object instance number
- `Boolean IsFinish` *(property, inherited from DocumentData)* — Gets information whether the object is Finish
- `Boolean IsNew` *(property, inherited from DocumentData)* — Gets information whether the object is new
- `DateTime LastModificationTime` *(property, inherited from DocumentData)* — Gets last edit date of workflow object
- `Int32 Version` *(property, inherited from DocumentData)* — Gets workflow object version

Inherited from `NewDocumentData`:

- `Object GetFieldValue(Int32 fieldID, EntityValueFormat format)` *(method, inherited from NewDocumentData)* — Gets formatted value based on id
- `Task SetFieldValueAsync(Int32 fieldID, Object value, CultureInfo culture)` *(method, inherited from NewDocumentData)* — Sets field value with specified culture
- `AttachmentsCollection Attachments` *(property, inherited from NewDocumentData)* — Attachments collection
- `ReadOnlyEntitiesCollection<AuthenticationField> AuthenticationFields` *(property, inherited from NewDocumentData)* — Gets collection of AuthenticationField form fields only
- `ReadOnlyEntitiesCollection<BooleanField> BooleanFields` *(property, inherited from NewDocumentData)* — Gets collection of BooleanField form fields only
- `ReadOnlyEntitiesCollection<ChooseField> ChooseFields` *(property, inherited from NewDocumentData)* — Gets collection of ChooseField form fields only
- `CommentStorage Comment` *(property, inherited from NewDocumentData)* — Gets comments
- `ReadOnlyEntitiesCollection<CommentField> CommentFields` *(property, inherited from NewDocumentData)* — Gets collection of CommentField form fields only
- `Int32 CompanyID` *(property, inherited from NewDocumentData)* — Gets company id
- `ReadOnlyEntitiesCollection<DateTimeField> DateTimeFields` *(property, inherited from NewDocumentData)* — Gets collection of DateTimeField form fields only
- `ReadOnlyEntitiesCollection<DecimalField> DecimalFields` *(property, inherited from NewDocumentData)* — Gets collection of DecimalField form fields only
- `Int32 DocumentTypeID` *(property, inherited from NewDocumentData)* — Gets document type id
- `ReadOnlyCollection<TaskData> ExistingTasks` *(property, inherited from NewDocumentData)* — Gets existing tasks collection
- `ReadOnlyEntitiesCollection<BaseField> Fields` *(property, inherited from NewDocumentData)* — Gets collection that contains all form fields
- `ReadOnlyEntitiesCollection<HyperlinkField> HyperlinkFields` *(property, inherited from NewDocumentData)* — Gets collection of HyperlinkField form fields only
- `ReadOnlyEntitiesCollection<IntegerField> IntegerFields` *(property, inherited from NewDocumentData)* — Gets collection of IntegerField form fields only
- `ReadOnlyItemsCollection<ItemsList> ItemsLists` *(property, inherited from NewDocumentData)* — Gets list of items lists
- `ReadOnlyEntitiesCollection<MapField> MapFields` *(property, inherited from NewDocumentData)* — Gets collection of MapField form fields only
- `ReadOnlyEntitiesCollection<PeopleField> PeopleFields` *(property, inherited from NewDocumentData)* — Gets collection of PeopleField form fields only
- `ReadOnlyEntitiesCollection<PickerField> PickerFields` *(property, inherited from NewDocumentData)* — Gets collection of PickerField form fields only
- `Int32 ProcessID` *(property, inherited from NewDocumentData)* — Gets process id
- `ReadOnlyEntitiesCollection<SqlField> SqlFields` *(property, inherited from NewDocumentData)* — Gets collection of SqlField form fields only
- `Int32 StepID` *(property, inherited from NewDocumentData)* — Gets step id
- `Nullable<Int32> SubDocumentTypeID` *(property, inherited from NewDocumentData)* — Gets subdocument type id
- `ReadOnlyEntitiesCollection<SurveyChooseField> SurveyChooseFields` *(property, inherited from NewDocumentData)* — Gets collection of SurveyChooseField form fields only
- `ReadOnlyEntitiesCollection<SurveyScaleField> SurveyScaleFields` *(property, inherited from NewDocumentData)* — Gets collection of SurveyScaleField form fields only
- `ReadOnlyEntitiesCollection<TextField> TextFields` *(property, inherited from NewDocumentData)* — Gets collection of TextField form fields only
- `ReadOnlyEntitiesCollection<TreeField> TreeFields` *(property, inherited from NewDocumentData)* — Gets collection of TreeField form fields only
- `Int32 WorkFlowID` *(property, inherited from NewDocumentData)* — Gets workflow id
