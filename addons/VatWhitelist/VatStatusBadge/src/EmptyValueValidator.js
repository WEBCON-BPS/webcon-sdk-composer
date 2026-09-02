import readModelValue from './readModelValue';

/**
 * Tells WEBCON whether the host field counts as empty, which is what drives the
 * "field is required" check.
 *
 * The template ships this as:
 *
 *     export default (model) => model == null || String(model).trim() === '';
 *
 * which is wrong for the same reason the component was wrong, and wrong more quietly.
 * When `model` is an object, String(model) is "[object Object]" -- never the empty string
 * -- so this returns false for every value including a genuinely empty one, and a required
 * field backed by a custom control can be saved blank. Nothing reports it; the check simply
 * never fires.
 */
export default (model) => readModelValue(model) === '';
