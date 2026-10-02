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
