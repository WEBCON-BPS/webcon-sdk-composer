**`FormFieldExtension<T1>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins`

Form fields's controls base class

- `Task OnAfterElementSaveAsync(AfterSaveParams<FormFieldExtensionContext>)` *(method)* — Method performed after saving item to database
- `Task OnBeforeElementDeleteAsync(BeforeDeleteParams<FormFieldExtensionContext>)` *(method)* — Method performed after removing item from database
- `Task OnBeforeElementSaveAsync(BeforeSaveParams<FormFieldExtensionContext>)` *(method)* — Method performed after saving item to database
- `String Test()` *(method)* — Information about element on form
- `Task ValidateAsync(ControlValidationParams<FormFieldExtensionContext>)` *(method)* — Method called on each item save that causes validation, e.g.
- `Task VerifySaveRestrictionsAsync(ControlSaveRestrictionsParams<FormFieldExtensionContext>)` *(method)* — Validation method called each time document is saved
- `Boolean HasCustomModel` *(property)* — A property that specifies whether the FormField has a custom model

Inherited from `PluginFieldBase<TConfig>`:

- `Task<Object> ConvertToDBTypeAsync(String)` *(method, inherited from PluginFieldBase<TConfig>)* — Method that converts a value to a format in the database
- `Boolean IsFieldEmpty(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Specifies whether the field is empty for validation and requirement purposes
- `Object OnDBValueGet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Method called after reading the value from the database and before passing it to the business logic
- `Object OnDBValueSet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — The method is called before saving the value to the database
- `BaseContext Context` *(property, inherited from PluginFieldBase<TConfig>)* — Plugin running context

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
