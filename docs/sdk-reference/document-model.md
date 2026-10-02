# Document Object Model (runtime)

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](./README.md)

The runtime object model a plugin uses to read and modify the current document — its fields, item
lists, attachments — and to perform document operations (move to next step, update, start a new
workflow). Reached from the plugin's execution context (e.g. `args.Context` on a Custom Action).

This page documents the **core** entry types. The full `Documents.Model.*` surface (all field
types, all cell types, all `*Config`/`*Info` descriptors, attachments collections) is in
[index-by-namespace.md](index-by-namespace.md) — search the `…Documents.Model…` namespaces.

## Managers (operations)

<!-- SDKREF:BEGIN Documents.DocumentsManager -->
**`DocumentsManager`** — `WebCon.WorkFlow.SDK.Documents`

Utility class for managing document instances

- `Task DeleteDocumentAsync(Int32 documentID, Boolean skipPermissionsCheck)` *(method)* — Deletes workflow element.
- `Task<ExistingDocumentData> GetDocumentByIdAsync(Int32 documentID, Boolean skipPermissionsCheck)` *(method)* — Getting existing workflow element
- `Task<ExistingDocumentData> GetDocumentByIdAsync(GetDocumentByIdParams args)` *(method)* — Getting existing workflow element
- `Task<ExistingDocumentData> GetDocumentByInstanceNumberAsync(String instanceNumber, Boolean skipPermissionsCheck)` *(method)* — Getting existing workflow element
- `Task<NewDocumentData> GetNewDocumentAsync(GetNewDocumentParams args)` *(method)* — Getting new workflow element to start new workflow.
- `Task<MoveDocumentToNextStepResult> MoveDocumentToNextStepAsync(MoveDocumentToNextStepParams args)` *(method)* — Method that moves given workflow element to next step
- `Task<StartNewWorkFlowResult> StartNewWorkFlowAsync(StartNewWorkFlowParams args)` *(method)* — Start of new workflow
- `Task<ValueTuple<Boolean, ExistingDocumentData>> TryGetDocumentByIdAsync(Int32 documentID, Boolean skipPermissionsCheck)` *(method)* — Try to get a existing workflow element
- `Task<ValueTuple<Boolean, ExistingDocumentData>> TryGetDocumentByInstanceNumberAsync(String instanceNumber, Boolean skipPermissionsCheck)` *(method)* — Try to get a existing workflow element
- `Task UpdateDocumentAsync(UpdateDocumentParams args)` *(method)* — Workflow element update without moving to next step.
<!-- SDKREF:END Documents.DocumentsManager -->

<!-- SDKREF:BEGIN Documents.DocumentAttachmentsManager -->
**`DocumentAttachmentsManager`** — `WebCon.WorkFlow.SDK.Documents`

Utility class for managing attachments

- `Task<Int32> AddAttachmentAsync(AddAttachmentParams args)` *(method)* — Adds attachment to workflow element
- `Task DeleteAttachmentAsync(DeleteAttachmentParams args)` *(method)* — Removes attachment
- `Task<AttachmentData> GetAttachmentAsync(Int32 attachmentId, Boolean skipPermissionsCheck)` *(method)* — Gets attachment with content
- `Task<AttachmentData> GetAttachmentAsync(GetAttachmentParams args)` *(method)* — Gets attachment with content
- `Task<List<AttachmentData>> GetAttachmentsAsync(GetAttachmentsParams args)` *(method)* — Gets list of attachments
- `Task<NewAttachmentData> GetNewAttachmentAsync(String name, Byte[] content)` *(method)* — Initializes new instance of NewAttachmentData class
- `Task UpdateAttachmentAsync(UpdateAttachmentParams args)` *(method)* — Attachment update
<!-- SDKREF:END Documents.DocumentAttachmentsManager -->

## Document data

<!-- SDKREF:BEGIN Documents.Model.CurrentDocumentData -->
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
<!-- SDKREF:END Documents.Model.CurrentDocumentData -->

<!-- SDKREF:BEGIN Documents.Model.DocumentData -->
**`DocumentData`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class represents workflow object data

- `UserInfo CreatedBy` *(property)* — Gets creator of workflow object
- `DateTime CreationTime` *(property)* — Gets creation time of workflow object
- `Int32 ID` *(property)* — Gets object ID
- `String InstanceNumber` *(property)* — Gets workflow object instance number
- `Boolean IsFinish` *(property)* — Gets information whether the object is Finish
- `Boolean IsNew` *(property)* — Gets information whether the object is new
- `DateTime LastModificationTime` *(property)* — Gets last edit date of workflow object
- `Nullable<Int32> ParentDocumentID` *(property)* — Gets parent workflow object Id
- `Int32 Version` *(property)* — Gets workflow object version

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
<!-- SDKREF:END Documents.Model.DocumentData -->

<!-- SDKREF:BEGIN Documents.Model.Base.FormElement -->
**`FormElement`** — `WebCon.WorkFlow.SDK.Documents.Model.Base`

Form field base class

- `String Description` *(property)* — Gets form field attribute description
- `String DisplayName` *(property)* — Gets form field attribute display name
- `Int32 ID` *(property)* — Gets form field id
- `Boolean IsEditable` *(property)* — Gets if form field is editable
- `Boolean IsRequired` *(property)* — Gets if form field is required
- `Boolean IsVisible` *(property)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Base.FormElement -->

## Fields

`BaseField` is the root; each form-field kind has a typed subclass. Read/write the value through
the typed field. The most common ones:

<!-- SDKREF:BEGIN Documents.Model.Fields.BaseField -->
**`BaseField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Base class for form field types available in WEBCON BPS

- `Object GetValue()` *(method)* — Returns value of form field
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method)* — Sets form field value with specified culture
- `String ToString()` *(method)* — Returns string representation of this object
- `String DbColumnName` *(property)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.BaseField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.TextField -->
**`TextField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing Text form field

- `Task SetValueAsync(String)` *(method)* — Sets field value
- `TextFieldConfig Configuration` *(property)* — Gets form field configuration
- `String Value` *(property)* — Gets field value

Inherited from `BaseField`:

- `Object GetValue()` *(method, inherited from BaseField)* — Returns value of form field
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method, inherited from BaseField)* — Sets form field value with specified culture
- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.TextField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.IntegerField -->
**`IntegerField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing Integer form field

- `Task SetValueAsync(Nullable<Int32>)` *(method)* — Sets value of form field
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method)* — Sets form field value with specified culture
- `Nullable<Int32> Value` *(property)* — Gets value from form field

Inherited from `BaseField`:

- `Object GetValue()` *(method, inherited from BaseField)* — Returns value of form field
- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.IntegerField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.DecimalField -->
**`DecimalField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing decimal form field

- `Task SetAndRoundValueAsync(Decimal value)` *(method)* — Rounds value to decimal places limit and sets it to form field
- `Task SetValueAsync(Nullable<Decimal>)` *(method)* — Sets field value
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method)* — Sets form field value with specified culture
- `DecimalFieldConfig Configuration` *(property)* — Class represents configuration for decimal form field
- `Nullable<Decimal> Value` *(property)* — Gets field value

Inherited from `BaseField`:

- `Object GetValue()` *(method, inherited from BaseField)* — Returns value of form field
- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.DecimalField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.BooleanField -->
**`BooleanField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing boolean form field

- `Task SetValueAsync(Nullable<Boolean>)` *(method)* — Sets field value
- `Nullable<Boolean> Value` *(property)* — Gets field value

Inherited from `BaseField`:

- `Object GetValue()` *(method, inherited from BaseField)* — Returns value of form field
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method, inherited from BaseField)* — Sets form field value with specified culture
- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.BooleanField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.DateTimeField -->
**`DateTimeField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing DateTime form field

- `Task SetValueAsync(Nullable<DateTime>)` *(method)* — Sets field value
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method)* — Sets form field value with specified culture
- `Nullable<DateTime> Value` *(property)* — Gets field value

Inherited from `BaseField`:

- `Object GetValue()` *(method, inherited from BaseField)* — Returns value of form field
- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.DateTimeField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.ChooseField -->
**`ChooseField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing choose form field

- `Object GetValue()` *(method)* — Gets form field value
- `Task<ChooseValue> ResolveAsync(String id)` *(method)* — Creates instance of value object if id exist in data source
- `Task<ChooseValue> SetByIDAsync(String id)` *(method)* — Validates if id exists in data source and sets form field value
- `Task SetValueAsync(ChooseValue)` *(method)* — Sets field value
- `ChooseFieldConfig Configuration` *(property)* — Choose form field configuration
- `ChooseValue Value` *(property)* — Gets field value

Inherited from `BaseField`:

- `Task SetValueAsync(Object value, CultureInfo culture)` *(method, inherited from BaseField)* — Sets form field value with specified culture
- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.ChooseField -->

<!-- SDKREF:BEGIN Documents.Model.Fields.PickerField -->
**`PickerField`** — `WebCon.WorkFlow.SDK.Documents.Model.Fields`

Class representing Picker form field

- `Object GetValue()` *(method)* — Gets value from form field
- `Task<PickerValue> ResolveAsync(String id)` *(method)* — Checks if id exist in data source and creates object based on it
- `Task SetSingleValueAndTargetFieldsAsync(PickerValue value)` *(method)* — Sets form field value
- `Task<PickerValue> SetSingleValueAndTargetFieldsByIDAsync(String id)` *(method)* — Sets form field value using id
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method)* — Sets form field value with specified culture
- `PickerFieldConfig Configuration` *(property)* — Gets configuration from form field
- `PickerValuesCollection Values` *(property)* — Gets value from form field

Inherited from `BaseField`:

- `String ToString()` *(method, inherited from BaseField)* — Returns string representation of this object
- `String DbColumnName` *(property, inherited from BaseField)* — Gets field database column name
- `FormFieldTypes FormFieldType` *(property, inherited from BaseField)* — Gets field type

Inherited from `FormElement`:

- `String Description` *(property, inherited from FormElement)* — Gets form field attribute description
- `String DisplayName` *(property, inherited from FormElement)* — Gets form field attribute display name
- `Int32 ID` *(property, inherited from FormElement)* — Gets form field id
- `Boolean IsEditable` *(property, inherited from FormElement)* — Gets if form field is editable
- `Boolean IsRequired` *(property, inherited from FormElement)* — Gets if form field is required
- `Boolean IsVisible` *(property, inherited from FormElement)* — Gets if form field is visible
<!-- SDKREF:END Documents.Model.Fields.PickerField -->

> Other field types (people, hyperlink, map, survey, SQL, tree, comment, authentication) follow
> the same `BaseField` pattern — see the index.

## Item lists (sub-tables)

<!-- SDKREF:BEGIN Documents.Model.ItemLists.ItemsList -->
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
<!-- SDKREF:END Documents.Model.ItemLists.ItemsList -->

<!-- SDKREF:BEGIN Documents.Model.ItemLists.ItemRowData -->
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
<!-- SDKREF:END Documents.Model.ItemLists.ItemRowData -->

<!-- SDKREF:BEGIN Documents.Model.ItemLists.BaseCell -->
**`BaseCell`** — `WebCon.WorkFlow.SDK.Documents.Model.ItemLists`

Represent single not typed cell of item list

- `Object GetValue()` *(method)* — Returns cell value
- `Task SetValueAsync(Object value, CultureInfo culture)` *(method)* — Sets cell value with specified culture
- `ColumnInfo Column` *(property)* — Column of this cell
- `String DbColumnName` *(property)* — Databae column name
- `Int32 ID` *(property)* — Cell Id
- `Boolean IsEditable` *(property)* — Can change value?
- `Boolean IsRequired` *(property)* — Is Required to fill
<!-- SDKREF:END Documents.Model.ItemLists.BaseCell -->

> Cells mirror field types (`TextCell`, `DecimalCell`, `ChooseCell`, …) — see the index.

## Document operations (params / results)

<!-- SDKREF:BEGIN Documents.Model.MoveDocumentToNextStepParams -->
**`MoveDocumentToNextStepParams`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing parameters for moving document to next step (e.g. in WEB API)

- `Boolean AdministrativelyFinishTasks` *(property)* — True when all user tasks should be administratively finished; otherwise, false
- `List<UserInfo> AssignedPersons` *(property)* — People assigned to task.
- `List<UserInfo> AssignedPersonsCC` *(property)* — People assigned to task in mode: To knowdlege.
- `ExistingDocumentData Document` *(property)* — WorkFlow document
- `Boolean ForceCheckout` *(property)* — Force checkout
- `UserInfo OverridenModifier` *(property)* — Overridden person who modified workflow instance
- `Nullable<Int32> PathID` *(property)* — Path ID that should be used after step end.
- `Boolean SkipPermissionsCheck` *(property)* — Should system skip checking permissions of currently logged user for moving document through next steps
<!-- SDKREF:END Documents.Model.MoveDocumentToNextStepParams -->

<!-- SDKREF:BEGIN Documents.Model.MoveDocumentToNextStepResult -->
**`MoveDocumentToNextStepResult`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing result of moving document to next step (e.g. in WEB API)

- `MoveToNextStepStatus UpdateStatus` *(property)* — Status of operation
<!-- SDKREF:END Documents.Model.MoveDocumentToNextStepResult -->

<!-- SDKREF:BEGIN Documents.Model.UpdateDocumentParams -->
**`UpdateDocumentParams`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing parameters passed to UpdateDocument method

- `List<UserInfo> AssignedPersonsCC` *(property)* — People assigned to task in mode: To knowdlege.
- `ExistingDocumentData Document` *(property)* — WorkFlow document
- `Boolean ForceCheckout` *(property)* — Force checkout
- `UserInfo OverridenModifier` *(property)* — Overriden person who modified workflow instance
- `Boolean SkipPermissionsCheck` *(property)* — Should system skip checking permissions of currently logged user for starting new workflows
<!-- SDKREF:END Documents.Model.UpdateDocumentParams -->

<!-- SDKREF:BEGIN Documents.Model.StartNewWorkFlowParams -->
**`StartNewWorkFlowParams`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing arguments passed to StartNewWorkFlow method

- `List<UserInfo> AssignedPersons` *(property)* — People assigned to task.
- `List<UserInfo> AssignedPersonsCC` *(property)* — People assigned to task in mode: CC.
- `NewDocumentData DocumentToStart` *(property)* — WorkFlow document
- `UserInfo OverridenModifier` *(property)* — Overridden person who modified workflow instance
- `Nullable<Int32> PathID` *(property)* — Path ID to select after start step exit.
- `Boolean SkipPermissionsCheck` *(property)* — Should system skip checking permissions of currently logged user for starting new workflows
<!-- SDKREF:END Documents.Model.StartNewWorkFlowParams -->

<!-- SDKREF:BEGIN Documents.Model.TaskData -->
**`TaskData`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class represents task data

- `Boolean IsSubstitutionTask` *(property)* — True when task a substitution; otherwise false
- `TaskData OriginalTask` *(property)* — Gets original task data (when task is a substitution)
- `AssignType TaskType` *(property)* — Gets task type

Inherited from `NewTaskData`:

- `NewTaskPermissions CCTaskEditable` *(property, inherited from NewTaskData)* — Defines whether the CC task should have edit permission
- `Boolean IsCCTask` *(property, inherited from NewTaskData)* — True, when task is assigned as CC; otherwise, false
- `NewTaskPermissions Substitutions` *(property, inherited from NewTaskData)* — Defines whether substitutions should be allowed
- `UserInfo User` *(property, inherited from NewTaskData)* — Gets user assigned to task
<!-- SDKREF:END Documents.Model.TaskData -->



