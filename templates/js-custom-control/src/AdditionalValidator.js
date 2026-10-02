/**
 * Field-level validation beyond "is it empty". Runs on save / path transition.
 *
 * Return { isValid: true } to pass, or { isValid: false, message: '...' } to
 * block the save and show the message under the field.
 */
export default () => ({ isValid: true });
