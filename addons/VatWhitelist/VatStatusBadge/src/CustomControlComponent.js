import React from 'react';
import PropTypes from 'prop-types';

import readModelValue from './readModelValue';
import './CustomControl.css';

/**
 * VatStatusBadge — one badge showing the VAT status, with everything else on hover.
 *
 * DISPLAY ONLY, and not by choice. A JS custom control sees only its own field: it cannot
 * read a sibling field and it cannot invoke an SDK action. So this cannot offer a "check
 * again" button — refreshing the status is FetchVatPayerData, attached to an ordinary form
 * button. That is also why the extension is not called "VatStatusBadge with refresh".
 *
 * That same one-field limit is why the field may carry a packed value,
 * `status|checkedOn|requestId`: the check date and the register's reference cannot reach
 * this control any other way. A bare status works too — everything after the first
 * separator is optional.
 *
 * It never calls onChange. The value belongs to the action; this only draws it.
 */

const DEFAULT_ACTIVE_VALUES = ['Czynny', 'Active'];

const VatStatusBadge = ({ model, sdkConfiguration }) => {
    // NOT String(model): WEBCON hands this control an object, and String() on it renders
    // the literal text "[object Object]".
    const raw = readModelValue(model);

    const [status = '', checkedOn = '', requestId = ''] = raw.split('|').map((p) => p.trim());

    let config = {};
    try {
        config = sdkConfiguration ? JSON.parse(sdkConfiguration) : {};
    } catch (e) {
        config = {};
    }

    // The register answers `Czynny`, and NFR-3 keeps its vocabulary Polish and verbatim.
    // But this control does not decide what fills its field: a process may normalise the
    // status into its own vocabulary before storing it, and one already does — the field on
    // the test instance holds `Active`. So the markers are configurable, defaulting to both
    // spellings, rather than a constant that is right on one instance and wrong on the next.
    const activeValues = Array.isArray(config.activeValues)
        ? config.activeValues
        : DEFAULT_ACTIVE_VALUES;

    const isActive = activeValues.some((v) => String(v).toLowerCase() === status.toLowerCase());

    // Three states, not two. An unrecognised status is `unknown`, not `inactive`: a badge
    // that has not understood the value must not assert that a contractor is not an active
    // VAT payer. register-findings.md finding 7 records that the register's third status
    // value is still unverified, so "anything I do not recognise is bad" is a claim we
    // cannot support — and it is the claim that stops a payment.
    const state = status === '' ? 'unknown' : isActive ? 'active' : 'inactive';

    // Everything the badge is not showing goes here, one fact per line, on hover. The badge
    // itself shows the status and nothing else: a caption beside it can only agree with the
    // status or contradict it, and contradicting it is worse than saying nothing.
    const tooltip = [
        status ? `VAT status: ${status}` : 'Not checked yet',
        checkedOn ? `Checked: ${checkedOn}` : null,
        requestId ? `Register request: ${requestId}` : null,
    ]
        .filter(Boolean)
        .join('\n');

    return (
        <span className={`vat-badge vat-badge--${state}`} title={tooltip}>
            <span className="vat-badge__dot" aria-hidden="true" />
            <span className="vat-badge__status">{status || 'Not checked'}</span>
        </span>
    );
};

VatStatusBadge.propTypes = {
    /** Current value of the host field — the VAT status, optionally packed with the check
     *  date and the register's request id as `status|checkedOn|requestId`. */
    model: PropTypes.any,
    onChange: PropTypes.func,
    sdkConfiguration: PropTypes.string,
};

export default VatStatusBadge;
