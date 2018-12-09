import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

class CurrencySelector extends React.Component {
  handleChange = event => {
    this.props.dispatch(this.props.action(event.target.value));
  };

  render() {
    return (
      <div className="select-wrapper">
        <select
          defaultValue={this.props.selection}
          onBlur={this.handleChange.bind(this)}
        >
          <option value="" disabled={this.props.selectionMade}>
            {this.props.placeholder}
          </option>
          {Object.values(this.props.currencies).map(currency => (
            <option
              key={currency.id}
              value={currency.code}
              disabled={currency.code === this.props.disabledOption}
            >
              {currency.code}
            </option>
          ))}
        </select>
      </div>
    );
  }
}

CurrencySelector.propTypes = {
  dispatch: PropTypes.func.isRequired,
  action: PropTypes.func.isRequired,
  selection: PropTypes.string,
  selectionMade: PropTypes.bool.isRequired,
  placeholder: PropTypes.string.isRequired,
  currencies: PropTypes.object.isRequired,
  disabledOption: PropTypes.string,
};

function mapStateToProps(state, ownProps) {
  return {
    selectionMade: ownProps.selection !== '',
    currencies: state.currencies,
  };
}

export default connect(mapStateToProps)(CurrencySelector);
