import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import Amount from './Amount';
import CurrencySelector from './CurrencySelector';
import { setBaseCurrency } from '../actions/baseCurrency';
import { setCounterCurrency } from '../actions/counterCurrency';
import { populateExchangeRate, populateGraphData } from '../actions/shared';

class CurrencyForm extends React.Component {
  handleSubmission = event => {
    event.preventDefault();

    this.props.dispatch(
      populateExchangeRate(
        this.props.selectedDate,
        this.props.baseCurrency,
        this.props.counterCurrency,
      ),
    );
    this.props.dispatch(
      populateGraphData(this.props.baseCurrency, this.props.counterCurrency),
    );
  };

  currencySelectorProperties = () => {
    return [
      {
        id: 0,
        label: 'Convert from this currency:',
        action: setBaseCurrency,
        selection: this.props.baseCurrency,
        disabledOption: this.props.counterCurrency,
      },
      {
        id: 1,
        label: 'To this currency:',
        action: setCounterCurrency,
        selection: this.props.counterCurrency,
        disabledOption: this.props.baseCurrency,
      },
    ];
  };

  render() {
    return (
      <div className="inputs-wrapper">
        <Amount />
        {this.currencySelectorProperties().map(properties => (
          <div key={properties.id}>
            <div className="label">{properties.label}</div>
            <CurrencySelector
              action={properties.action}
              selection={properties.selection}
              disabledOption={properties.disabledOption}
            />
          </div>
        ))}
        <button
          type="button"
          onClick={this.handleSubmission.bind(this)}
          disabled={!this.props.enableSubmission}
        >
          Calculate
        </button>
      </div>
    );
  }
}

CurrencyForm.propTypes = {
  dispatch: PropTypes.func.isRequired,
  selectedDate: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.instanceOf(Date),
  ]),
  baseCurrency: PropTypes.string.isRequired,
  counterCurrency: PropTypes.string.isRequired,
  enableSubmission: PropTypes.bool.isRequired,
};

function mapStateToProps(state) {
  const amountPresent = parseInt(state.amount) > 0;
  const baseCurrencySet = state.baseCurrency !== '';
  const counterCurrencySet = state.counterCurrency !== '';
  const enableSubmission =
    amountPresent && baseCurrencySet && counterCurrencySet;

  return {
    enableSubmission,
    baseCurrency: baseCurrencySet ? state.baseCurrency : '',
    counterCurrency: counterCurrencySet ? state.counterCurrency : '',
    selectedDate: state.selectedDate,
  };
}

export default connect(mapStateToProps)(CurrencyForm);
