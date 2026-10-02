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
