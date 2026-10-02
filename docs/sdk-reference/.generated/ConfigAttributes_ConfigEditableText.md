**`ConfigEditableText`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Plugin with this attribute will be displayed as text field and it will return string object

- `String DefaultText` *(property)* — Default text
- `Boolean IsPasswordField` *(property)* — Indicates whether field is password type
- `Int32 Lines` *(property)* — How many lines of text will Designer Studio display
- `Int32 MaxLength` *(property)* — Max lenght of text inside field
- `Boolean Multiline` *(property)* — Indicates whether field should be displayed as text field.
- `String NullText` *(property)* — Default text.
- `Boolean ReadOnly` *(property)* — Sets textbox mode to readonly
- `EvaluationMode TagEvaluationMode` *(property)* — Sets variable replacement mode: {123} or {WFD_ID}

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
