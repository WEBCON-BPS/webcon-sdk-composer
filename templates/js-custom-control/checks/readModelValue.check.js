// Run with:  npm test   (or: node checks/readModelValue.check.js)
//
// No framework, no dependency. The workbench passes `model` as a plain string, so the shapes
// a real form sends are checked here instead.

import assert from 'node:assert/strict';
import readModelValue from '../src/readModelValue.js';

const cases = [
    // The shape that reached a real form. String(model) here is "[object Object]".
    ['object with value', { value: 'Active' }, 'Active'],
    ['object with Value', { Value: 'Active' }, 'Active'],
    ['object with text', { text: 'Active' }, 'Active'],
    ['object with displayValue', { displayValue: 'Active', id: 7 }, 'Active'],
    ['nested one level', { value: { text: 'Active' } }, 'Active'],
    ['single-element array', [{ value: 'Active' }], 'Active'],
    ['plain string', 'Active', 'Active'],
    ['trailing space kept for editing', 'two ', 'two '],
    ['number', 7, '7'],
    ['null', null, ''],
    ['undefined', undefined, ''],
    ['empty array', [], ''],
    ['object with empty value', { value: '' }, ''],
];

for (const [name, input, expected] of cases) {
    assert.equal(readModelValue(input), expected, name);
}

// An unrecognised shape must stay visible, not collapse to ''.
const unknown = readModelValue({ somethingNobodyPredicted: 'Active' });
assert.ok(unknown.includes('Active'), 'unrecognised shape stays visible');

console.log(`all ${cases.length + 1} checks passed`);
