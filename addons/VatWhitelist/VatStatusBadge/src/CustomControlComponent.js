import React from 'react';
import PropTypes from 'prop-types';

import './CustomControl.css';

/**
 * VatStatusBadge — renders the VAT status the register returned, and the date it was
 * checked on.
 *
 * DISPLAY ONLY, and not by choice. A JS custom control sees only its own field: it cannot
 * read a sibling field and it cannot invoke an SDK action. So this cannot offer a "check
 * again" button — refreshing the status is FetchVatPayerData, attached to an ordinary form
 * button. That is also why the extension is not called "VatStatusBadge with refresh".
 *
 * It never calls onChange. The value belongs to the action; this only draws it.
 */
const VatStatusBadge = ({ model, sdkConfiguration }) => {
    const status = model == null ? '' : String(model).trim();

    let config = {};
    try {
        config = sdkConfiguration ? JSON.parse(sdkConfiguration) : {};
    } catch (e) {
        config = {};
    }

    // The register's vocabulary is Polish and verbatim (NFR-3). "Czynny" and "Zwolniony"
    // are both observed; the third value is unverified, so nothing here compares against a
    // hardcoded string for the negative case. Anything that is not an active payer is
    // "not active", by exclusion — which stays correct whatever the third value turns out
    // to be.
    const state = status === '' ? 'unknown' : status === 'Czynny' ? 'active' : 'inactive';

    const caption =
        state === 'unknown'
            ? 'Not checked'
            : state === 'active'
              ? 'Active VAT payer'
              : 'Not an active VAT payer';

    return (
        <div className={`vat-badge vat-badge--${state}`}>
            <span className="vat-badge__dot" aria-hidden="true" />
            <span className="vat-badge__status">{status || '—'}</span>
            <span className="vat-badge__caption">{caption}</span>
            {config.checkedOn ? (
                <span className="vat-badge__checked">checked {config.checkedOn}</span>
            ) : null}
        </div>
    );
};

VatStatusBadge.propTypes = {
    /** Current value of the host field — the register's statusVat, written by the action. */
    model: PropTypes.any,
    onChange: PropTypes.func,
    sdkConfiguration: PropTypes.string,
};

export default VatStatusBadge;
