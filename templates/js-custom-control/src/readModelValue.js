/**
 * Turns whatever WEBCON hands a custom control as `model` into a string.
 *
 * `model` is not reliably a string. For a single line of text field on a real form it
 * arrives as an object, and `String(model)` yields the literal text "[object Object]".
 * The workbench passes a plain string, so the bug never shows there — only on a real form.
 * Found in the WEBCON DAY 2026 run: a status control compared "[object Object]" with the
 * expected value, failed, and showed the wrong state for every document.
 *
 * Accepts the plausible shapes; when it recognises none it falls back to JSON.stringify,
 * so an unknown shape stays visible on the form instead of collapsing to an empty string.
 * Strings are returned as they are, not trimmed: the control edits this value, and trimming
 * on every render would eat the space the user just typed.
 */

const VALUE_KEYS = ['value', 'Value', 'text', 'Text', 'stringValue', 'displayValue'];

export default function readModelValue(model, depth = 0) {
    if (model === null || model === undefined) return '';
    if (typeof model === 'string') return model;
    if (typeof model === 'number' || typeof model === 'boolean') return String(model);

    // Guard against a value that points back at itself.
    if (depth > 3) return '';

    // Some field types deliver a single-element collection rather than a scalar.
    if (Array.isArray(model)) {
        if (model.length === 1) return readModelValue(model[0], depth + 1);
        return model.map((item) => readModelValue(item, depth + 1)).filter(Boolean).join(', ');
    }

    if (typeof model === 'object') {
        let sawKnownKey = false;
        for (const key of VALUE_KEYS) {
            if (Object.prototype.hasOwnProperty.call(model, key)) {
                sawKnownKey = true;
                const extracted = readModelValue(model[key], depth + 1);
                if (extracted !== '') return extracted;
            }
        }

        // A known key holding nothing means the field IS empty. Falling through to
        // JSON.stringify would return '{"value":""}' and EmptyValueValidator would call an
        // empty field filled.
        if (sawKnownKey) return '';

        try {
            return JSON.stringify(model);
        } catch (e) {
            return '[unreadable value]';
        }
    }

    return String(model);
}
