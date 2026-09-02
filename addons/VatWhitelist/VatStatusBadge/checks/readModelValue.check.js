// Run with:  node checks/readModelValue.check.js
//
// No test framework, no config, no dependency. This file exists because the bug it guards
// against shipped through 50 green C# tests, ESLint, a clean build and Verify plugins --
// every gate we had said yes, because none of them ever sees a `model`.
//
// The first case is the one that reached a real form.

import assert from 'node:assert/strict';
import readModelValue from '../src/readModelValue.js';

const cases = [
    // The shape that actually broke it. String(model) here is "[object Object]".
    ['object with value',        { value: 'Czynny' },              'Czynny'],
    ['object with Value',        { Value: 'Czynny' },              'Czynny'],
    ['object with text',         { text: 'Zwolniony' },            'Zwolniony'],
    ['object with displayValue', { displayValue: 'Czynny', id: 7 }, 'Czynny'],

    ['plain string',             'Czynny',                          'Czynny'],
    ['string needing a trim',    '  Czynny  ',                      'Czynny'],
    ['number',                   7,                                 '7'],
    ['single-element array',     [{ value: 'Czynny' }],             'Czynny'],
    ['nested one level',         { value: { text: 'Czynny' } },     'Czynny'],

    ['null',                     null,                              ''],
    ['undefined',                undefined,                         ''],
    ['empty string',             '',                                ''],
    ['whitespace only',          '   ',                             ''],
    ['empty array',              [],                                ''],
    ['object with empty value',  { value: '' },                     ''],
];

let failed = 0;
for (const [name, input, expected] of cases) {
    const actual = readModelValue(input);
    try {
        assert.equal(actual, expected);
        console.log(`ok    ${name}`);
    } catch {
        failed++;
        console.log(`FAIL  ${name}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
    }
}

// An unrecognised shape must stay VISIBLE rather than collapsing to ''. A reader who sees
// JSON on the form learns the shape; a reader who sees a dash learns nothing and assumes
// the field is simply empty.
const unknown = readModelValue({ somethingNobodyPredicted: 'Czynny' });
try {
    assert.notEqual(unknown, '');
    assert.ok(unknown.includes('Czynny'));
    console.log('ok    unrecognised shape stays visible');
} catch {
    failed++;
    console.log(`FAIL  unrecognised shape was swallowed: ${JSON.stringify(unknown)}`);
}

// The exact bug, stated as an assertion so it cannot come back.
try {
    assert.notEqual(readModelValue({ value: 'Czynny' }), '[object Object]');
    console.log('ok    never yields [object Object]');
} catch {
    failed++;
    console.log('FAIL  [object Object] is back');
}

// The packed shape the badge has to survive, as observed on a real form:
//   Active|2026-09-02T09:50:23|2hImZ-98e4cnn
// A JS control sees only its own field, so three facts have to travel in one value.
// readModelValue must hand that string to the badge intact, not mangled.
const packed = readModelValue({ value: 'Active|2026-09-02T09:50:23|2hImZ-98e4cnn' });
try {
    assert.equal(packed.split('|').length, 3);
    assert.equal(packed.split('|')[0], 'Active');
    assert.equal(packed.split('|')[2], '2hImZ-98e4cnn');
    console.log('ok    packed value survives extraction intact');
} catch {
    failed++;
    console.log(`FAIL  packed value was mangled: ${JSON.stringify(packed)}`);
}

console.log(failed === 0 ? `\nall ${cases.length + 3} checks passed` : `\n${failed} FAILED`);
process.exit(failed === 0 ? 0 : 1);
