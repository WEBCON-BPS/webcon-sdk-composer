/**
 * Turns whatever WEBCON hands a custom control as `model` into a display string.
 *
 * WHY THIS EXISTS. `model` is not reliably a string. For a single line of text field on a
 * real form it arrives as an object, and `String(model)` yields the literal text
 * "[object Object]". The shape is documented nowhere, and
 * templates/js-custom-control teaches the broken form in two places -- `String(model)` in
 * CustomControlComponent.js and `String(model).trim() === ''` in EmptyValueValidator.js.
 *
 * The failure is not cosmetic. A badge comparing "[object Object]" against "Czynny" tells
 * every user their contractor is not an active VAT payer, in a confident red, including
 * when the contractor is one. Nothing in 50 offline tests, ESLint, a clean build or
 * Verify plugins says a word about it, because the shape is decided in the browser.
 *
 * WHAT IT DOES. Accepts the shapes that are plausible and, when it recognises none,
 * falls back to JSON.stringify so an unknown shape stays VISIBLE on the form instead of
 * collapsing to an empty string. Showing a reader `{"id":7,"value":"Czynny"}` is ugly and
 * tells them what happened; showing them a dash tells them nothing and looks deliberate.
 */

const VALUE_KEYS = ['value', 'Value', 'text', 'Text', 'stringValue', 'displayValue'];

export default function readModelValue(model, depth = 0) {
    if (model === null || model === undefined) return '';

    if (typeof model === 'string') return model.trim();
    if (typeof model === 'number' || typeof model === 'boolean') return String(model);

    // Guard against a value that points back at itself; three levels is far more nesting
    // than any of these shapes needs.
    if (depth > 3) return '';

    // Some field types deliver a single-element collection rather than a scalar.
    if (Array.isArray(model)) {
        if (model.length === 0) return '';
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

        // A recognised key that holds nothing means the field IS empty. Falling through to
        // JSON.stringify here would return {"value":""} -- a non-empty string -- and
        // EmptyValueValidator would report an empty field as filled, which is the very bug
        // this file exists to remove, reintroduced one level down.
        //
        // Found by checks/readModelValue.check.js on its first run, not by reading it.
        if (sawKnownKey) return '';

        // Genuinely unrecognised. Do not swallow it -- put it on screen, so the next person
        // to look at this form learns the shape instead of guessing at it as we had to.
        try {
            return JSON.stringify(model);
        } catch (e) {
            return '[unreadable value]';
        }
    }

    return String(model).trim();
}
