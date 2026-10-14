/**
 * Tells WEBCON whether the field counts as empty — this is what drives the
 * "field is required" check on the form.
 *
 * Return true when the value should be treated as empty. `model` may be an object, so
 * `String(model)` would be "[object Object]" and never empty — use readModelValue.
 */
import readModelValue from './readModelValue';

export default (model) => readModelValue(model).trim() === '';
