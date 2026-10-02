/**
 * Tells WEBCON whether the field counts as empty — this is what drives the
 * "field is required" check on the form.
 *
 * Return true when the value should be treated as empty.
 */
export default (model) => model == null || String(model).trim() === '';
