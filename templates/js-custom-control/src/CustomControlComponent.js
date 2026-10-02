import React from 'react';
import PropTypes from 'prop-types';

import './CustomControl.css';

/**
 * Starter JS custom control.
 *
 * WEBCON mounts this component in place of a form field's standard control and
 * hands it four props (see propTypes below). Writing a value back to the field
 * is done with `onChange(newValue)` — never by touching the DOM directly.
 *
 * Run `npm start` to open the JS Custom Control Workbench: it renders this
 * component with mock props you can edit live, and logs every onChange.
 */
const CustomControlComponent = ({ fieldConfiguration, model, onChange, sdkConfiguration }) => {
    const readOnly =
        fieldConfiguration.isDisabled ||
        (fieldConfiguration.editMode !== 'Edit' && !fieldConfiguration.isAdmin);

    // sdkConfiguration is the JSON string typed into Designer Studio next to the
    // field. Parse defensively — a config typo must not blank out the form.
    let config = {};
    try {
        config = sdkConfiguration ? JSON.parse(sdkConfiguration) : {};
    } catch (e) {
        config = {};
    }

    const label = config.label || fieldConfiguration.displayName;

    return (
        <div className="addon-template">
            <label className="addon-template__label" htmlFor="addon-template-input">
                {label}
                {fieldConfiguration.isRequired ? ' *' : ''}
            </label>
            <input
                id="addon-template-input"
                className="addon-template__input"
                type="text"
                value={model == null ? '' : String(model)}
                disabled={readOnly}
                onChange={(e) => onChange(e.target.value)}
            />
            {fieldConfiguration.description ? (
                <p className="addon-template__hint">{fieldConfiguration.description}</p>
            ) : null}
        </div>
    );
};

CustomControlComponent.propTypes = {
    /** Field metadata supplied by the form. */
    fieldConfiguration: PropTypes.shape({
        displayName: PropTypes.string.isRequired,
        description: PropTypes.string.isRequired,
        isRequired: PropTypes.bool.isRequired,
        editMode: PropTypes.oneOf(['Edit', 'ReadOnly', 'ReadOnlyHtml']).isRequired,
        isNew: PropTypes.bool.isRequired,
        isAdmin: PropTypes.bool.isRequired,
        isDisabled: PropTypes.bool.isRequired,
    }).isRequired,
    /** Current value of the host field. */
    model: PropTypes.any,
    /** Call with the new value to write it back to the field. */
    onChange: PropTypes.func.isRequired,
    /** Raw JSON string from the field's SDK configuration box in Designer Studio. */
    sdkConfiguration: PropTypes.string,
};

export default CustomControlComponent;
