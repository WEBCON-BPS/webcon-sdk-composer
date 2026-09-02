/**
 * Tells WEBCON whether the host field counts as empty, which is what drives the
 * "field is required" check.
 *
 * The status is written by FetchVatPayerData, never by this control, so in practice the
 * field is empty exactly when no check has been made yet.
 */
export default (model) => model == null || String(model).trim() === '';
