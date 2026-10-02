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
