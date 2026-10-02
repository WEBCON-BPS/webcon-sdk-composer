**`FormFieldExtension<TConfig, TValue>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins`

Logic part of plugin that allows to change behavior of standard field.

- `Task<TValue> ConvertToControlTypeAsync(Object)` *(method)* — A method that converts the value to the format of the form field control
- `Task<Object> ConvertToDBTypeAsync()` *(method)* — Method that converts a value to a format in the database
- `Task OnAfterElementSaveAsync(AfterSaveParams<FormFieldValueExtensionContext<>>)` *(method)* — Method performed after saving item to database
- `Void OnBeforeElementDelete(BeforeDeleteParams<FormFieldValueExtensionContext<>>)` *(method)* — Method performed after removing item from database
- `Task OnBeforeElementDeleteAsync(BeforeDeleteParams<FormFieldValueExtensionContext<>>)` *(method)* — Validation method called each time document is saved
- `Task OnBeforeElementSaveAsync(BeforeSaveParams<FormFieldValueExtensionContext<>>)` *(method)* — Method performed after saving item to database
- `String Test()` *(method)* — Information about element on form
- `Task ValidateAsync(ControlValidationParams<FormFieldValueExtensionContext<>>)` *(method)* — Method called on each item save that causes validation, e.g.
- `Task VerifySaveRestrictionsAsync(ControlSaveRestrictionsParams<FormFieldValueExtensionContext<>>)` *(method)* — Validation method called each time document is saved
- `Boolean HasCustomModel` *(property)* — A property that specifies whether the FormField has a custom model

Inherited from `PluginFieldBase<TConfig>`:

- `Boolean IsFieldEmpty(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Specifies whether the field is empty for validation and requirement purposes
- `Object OnDBValueGet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Method called after reading the value from the database and before passing it to the business logic
- `Object OnDBValueSet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — The method is called before saving the value to the database
- `BaseContext Context` *(property, inherited from PluginFieldBase<TConfig>)* — Plugin running context

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
