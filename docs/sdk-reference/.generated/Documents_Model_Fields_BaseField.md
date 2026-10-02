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
