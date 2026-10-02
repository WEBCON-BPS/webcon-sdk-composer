# WEBCON BPS JS API — reference for Form Field Extensions

> **Source**: official *JS API documentation* (developer.webcon.com, BPS 2026) —
> <https://developer.webcon.com/2026/resources/JS%20API%20documentation.pdf>.
> Hand-cleaned into markdown so agents in this repo can read it. If anything here looks off,
> the upstream document is the source of truth.
>
> **Scope**: this is the **front-end** API for **External form field** / Form Field Extension
> controls — an embedded web app (iframe) running on a WEBCON **Modern form**. It is unrelated to
> the .NET SDK (Custom Action etc.);

## Calling convention

Most reads are **callback-based**, not promise-based: you pass a `callback` that receives the
result. The one exception is `callUdaApi`, which returns a `Promise`. Item-list rows are
**numbered starting at 1**.

## Setup

Before using the API:

1. Define two globals:
   - `__WEBCON_PORTAL_ADDRESS__` — address of the server hosting the portal.
   - `__WEBCON_EXTERNAL_CONTROL_ID__` — id of the External form field where the page is placed.
2. Include `webcon.min.js` (use the **iife** build — present in this folder under `iife/`).

```js
window.__WEBCON_PORTAL_ADDRESS__ = 'https://portal.example.com';
window.__WEBCON_EXTERNAL_CONTROL_ID__ = 123;
// then load webcon.min.js (iife) — exposes the global `webcon`
```

---

## Form appearance & behavior

### Control height

`webcon.window.setHeight(height)` — set the External form field height.

```js
webcon.window.setHeight(500);
// or
webcon.window.setHeight('500px');
```

### Show / hide form fields

`webcon.fields.showField(fieldName)` / `webcon.fields.hideField(fieldName)`

```js
webcon.fields.hideField('AttText9');
webcon.fields.showField('AttText9');
```

### Show / hide an item-list column

`webcon.fields.showSubelementColumn(subelementsControlId, columnName)`
`webcon.fields.hideSubelementColumn(subelementsControlId, columnName)`

```js
webcon.fields.showSubelementColumn(30, 'DET_Att1');
webcon.fields.hideSubelementColumn(30, 'DET_Att1');
```

### Other show/hide helpers

```js
webcon.fields.showSubelementControl(subelementsControlId);
webcon.fields.hideSubelementControl(subelementsControlId);
webcon.fields.showTabPanel(id);
webcon.fields.hideTabPanel(id);
webcon.fields.showTab(id);
webcon.fields.hideTab(id);
webcon.fields.selectTab(id);
webcon.fields.hideGroup(id);
webcon.fields.showGroup(id);
webcon.fields.expandGroup(id);
webcon.fields.collapseGroup(id);
webcon.fields.showChart(id);
webcon.fields.hideChart(id);
webcon.fields.showSqlGrid(id);
webcon.fields.showSqlRow(id);
webcon.fields.hideSqlGrid(id);
webcon.fields.hideSqlRow(id);
webcon.document.hideComment();
webcon.document.showComment();
webcon.document.showSecurities();
webcon.document.showOcrTrainButtons();
webcon.document.hideOcrTrainButtons();
```

### Check for an attachment

`webcon.document.checkIfAttExists(regex, callback)` — checks whether an attachment whose name
matches the regular expression is attached to the instance. The callback receives `true` / `false`.

```js
function logInfo(value) {
  console.log(value);
}

// by exact name
webcon.document.checkIfAttExists('^DocumentName[.]docx$', logInfo);

// inline callback
webcon.document.checkIfAttExists('^DocumentName[.]docx$', function (value) {
  console.log(value);
});

// any .pdf attachment → true
webcon.document.checkIfAttExists('[.]pdf$', function (value) {
  console.log(value);
});
```

### Enable / disable controls

`webcon.fields.enableControl(fieldName)` / `webcon.fields.disableControl(fieldName)`

```js
webcon.fields.enableControl('AttText9');
webcon.fields.disableControl('AttText9');

webcon.document.enableRootPanel();
webcon.document.disableRootPanel();
```

### Field visibility check

`webcon.fields.isFormFieldVisible(fieldName, id, callback)` — callback receives `true` / `false`.

```js
webcon.fields.isFormFieldVisible('AttText9', 85, function (value) {
  console.log(value);
});
```

### Styles

`webcon.fields.setControlStyle(fieldName, style)` and `webcon.fields.setLabelStyle(fieldName, style)`
— set the same options available in Designer Studio.

```js
webcon.fields.setLabelStyle('AttText9', 'background-color: yellow');
webcon.fields.setControlStyle('AttText9', 'background-color: green');
```

---

## Events

### Has-value validation

`webcon.events.onHasValueValidation(callback)` — the callback must return `true` (control has a
value) or `false`.

```js
window.webcon.events.onHasValueValidation(function () {
  var hasValue = true; // logic defining whether the control has a value
  return hasValue;
});
```

### Fields refresh

`webcon.events.onFieldsRefresh(callback)` — registers an event triggered **after form field values
are updated**. Use this to re-read data and re-render.

```js
webcon.events.onFieldsRefresh(callbackFunction);
```

---

## Workflow instance data & form metadata

### Form info

`webcon.document.getFormInfo(callback)` — callback receives JSON with information about the current
form.

```js
webcon.document.getFormInfo(function (info) {
  console.log(info);
});
```

### Context

`webcon.document.getContext(callback)` — callback receives JSON with Portal `language`, `userLogin`
and `userName`.

```js
webcon.document.getContext(function (info) {
  console.log(info);
});
```

### Field mode

`webcon.fields.getMode(fieldName, callback)` — callback receives the text `'Standard'` or
`'Custom'` depending on the field mode.

```js
webcon.fields.getMode('AttText9', function (info) {
  console.log(info);
});
```

### Get / set field values

`webcon.fields.setValue(fieldName, value)` / `webcon.fields.getValue(fieldName, callback)`

```js
webcon.fields.setValue('AttText9', textValue);
webcon.fields.getValue('AttText9', function (attValue) {
  console.log(attValue);
});
```

### Get / set typed field values

`webcon.fields.setTypedValue(fieldName, value)` / `webcon.fields.getTypedValue(fieldName, callback)`
— for typed fields like date or decimal.

```js
webcon.fields.setTypedValue('AttDateTime1', { value: new Date(2010, 0, 30, 13, 45) });
webcon.fields.setTypedValue('AttDecimal1', { value: 10.23 });
webcon.fields.getTypedValue('AttDateTime1', function (value) {
  console.log(value);
});
```

### Get / set item-list cell values

`webcon.fields.setSubValue(subelementsControlId, rowNumber, columnName, value, forceOnReadonly)`
`webcon.fields.getSubValue(subelementsControlId, rowNumber, columnName, callback)`

- Values can only be set in **rows that already exist**.
- Read-only columns can be modified by passing `true` to `forceOnReadonly`.
- Rows are numbered **starting at 1**.

```js
webcon.fields.setSubValue(30, 1, 'DET_Att1', 'value to set', true);
webcon.fields.getSubValue(30, 1, 'DET_Att1', function (value) {
  console.log(value);
});
```

### Get / set typed item-list values

`webcon.fields.setSubTypedValue(subelementsControlId, rowNumber, columnName, value)`
`webcon.fields.getSubTypedValue(subelementsControlId, rowNumber, columnName, callback)`
— rows numbered starting at 1.

```js
webcon.fields.setSubTypedValue(32, 1, 'DET_Value1', { value: 10.23 });
webcon.fields.getSubTypedValue(32, 1, 'DET_Value1', function (value) {
  console.log(value);
});
```

### Item-list row helpers

```js
// count rows
webcon.fields.subelementCountRows(30, function (value) {
  console.log(value);
});

// delete specific rows (1-based)
webcon.fields.deleteSubelementRows(30, [2, 3]);

// does the item list have any rows? (callback → true/false)
webcon.fields.subelementHasRows(subelemId, callback);

webcon.fields.subelementInitialization(subelemId);

// delete ALL item-list rows
webcon.fields.subelementDelete(subelemId);
```

---

## Field configuration

`webcon.document.getSelfConfiguration(callback)` — callback receives JSON with the **current form
field's** configuration (this is how a control reads its own mapping/options).

```js
webcon.document.getSelfConfiguration(function (configuration) {
  console.log(configuration);
});
```

`webcon.document.getControlConfiguration(fieldName, callback)` — configuration of another field.

---

## Triggering actions

`webcon.document.invokeMenuAction(actionButtonId)` — trigger an action configured to fire on a
**Menu button**, by its button id.

```js
webcon.document.invokeMenuAction(2);
```

---

## Data type conversion

### String ↔ Date

`webcon.document.stringToDate(strDate, callback)`

```js
webcon.document.stringToDate('10/10/2020', function (date) {
  console.log(date); // Sat Oct 10 2020 00:00:00 GMT+0200
});
```

`webcon.document.dateToString(dateObject, format, callback)` — takes a `Date` and passes a string
representation to the callback. `format` is a culture, e.g. `"pl"` / `"en"`.

```js
var date = new Date(2020, 0, 10);
webcon.document.dateToString(date, 'pl', function (value) {
  console.log(value); // 2020-01-10
});
webcon.document.dateToString(date, 'en', function (value) {
  console.log(value); // 1/10/2020
});
```

### Float ↔ String

`webcon.document.convertFloatToString(value, precision, callback)`

```js
webcon.document.convertFloatToString(10.1010, 2, function (value) {
  console.log(value); // 10,10
});
```

`webcon.document.convertStringToFloat(value, callback)`

```js
webcon.document.convertStringToFloat('10,1010', function (value) {
  console.log(value); // 10.101
});
```

### ID/Name pairs

`webcon.document.getPairName(idNameString, callback)` and
`webcon.document.getPairID(idNameString, callback)` — return only the name, or only the id, from an
`id#name` pair.

```js
webcon.document.getPairName('35#Name', function (value) {
  console.log(value); // Name
});
webcon.document.getPairID('35#Name', function (value) {
  console.log(value); // 35
});
```

---

## Calling a User Defined API (UDA)

`webcon.window.callUdaApi(url, data)` — call a User Defined API endpoint.

- The optional `data` parameter may include `body`, `headers`, and `method` (e.g. `'POST'`).
- The default method is `'GET'`.
- Returns a **Promise** with the result of the call.
- **Requests to external URLs are blocked** — calls must remain within the current portal.

```js
webcon.window.callUdaApi(url, data);
```
