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
