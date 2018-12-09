import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DateSelector from './DateSelector';
import Amount from './Amount';
import CurrencySelector from './CurrencySelector';
import Results from './Results';
import RateGraph from './RateGraph';
import { setBaseCurrency } from '../actions/baseCurrency';
import { setCounterCurrency } from '../actions/counterCurrency';
import { populateExchangeRate, populateGraphData } from '../actions/shared';

class FxExplorer extends React.Component {
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

  render() {
    const currencySelectorProperties = [
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

    return (
      <section>
        <div className="form-wrapper">
          <DateSelector />
          <div className="inputs-wrapper">
            <Amount />
            {currencySelectorProperties.map(properties => (
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
        </div>
        <div className="results-wrapper">
          {this.props.showResults && <Results />}
          {this.props.showGraph && <RateGraph />}
        </div>
      </section>
    );
  }
}

FxExplorer.propTypes = {
  dispatch: PropTypes.func.isRequired,
  selectedDate: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.instanceOf(Date),
  ]),
  baseCurrency: PropTypes.string.isRequired,
  counterCurrency: PropTypes.string.isRequired,
  enableSubmission: PropTypes.bool.isRequired,
  showResults: PropTypes.bool.isRequired,
  showGraph: PropTypes.bool.isRequired,
};

function mapStateToProps(state) {
  const baseCurrencySet = state.baseCurrency !== '';
  const counterCurrencySet = state.counterCurrency !== '';
  const enableSubmission =
    parseInt(state.amount) > 0 && baseCurrencySet && counterCurrencySet;
  const currenciesChanged =
    state.baseCurrency !== state.exchangeRate.base_currency ||
    state.counterCurrency !== state.exchangeRate.counter_currency;
  const propertySet = property => {
    return typeof property !== 'undefined' && Object.keys(property).length > 0;
  };
  return {
    baseCurrency: baseCurrencySet ? state.baseCurrency : '',
    counterCurrency: counterCurrencySet ? state.counterCurrency : '',
    enableSubmission,
    showResults: propertySet(state.exchangeRate) && !currenciesChanged,
    showGraph: propertySet(state.graphData) && !currenciesChanged,
    selectedDate: state.selectedDate,
  };
}

export default connect(mapStateToProps)(FxExplorer);
