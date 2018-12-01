import React from "react";
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
  handleSubmission = (event) => {
    event.preventDefault();

    this.props.dispatch(
      populateExchangeRate(
        this.props.selectedDate,
        this.props.baseCurrency,
        this.props.counterCurrency
      )
    );
    this.props.dispatch(
      populateGraphData(this.props.baseCurrency, this.props.counterCurrency)
    );
  };

  render () {
    return (
      <section>
        <DateSelector />
        <Amount />
        <CurrencySelector
          action={setBaseCurrency}
          selection={this.props.baseCurrency}
          disabledOption={this.props.counterCurrency}
          placeholder={'Please select currency to convert from'}
        />
        <CurrencySelector
          action={setCounterCurrency}
          selection={this.props.counterCurrency}
          disabledOption={this.props.baseCurrency}
          placeholder={'Please select currency to convert to'}
        />
        <button
          type='button'
          onClick={this.handleSubmission.bind(this)}
          disabled={this.props.disableSubmission}
        >Calculate</button>
        { this.props.showResults && <Results /> }
        { this.props.showGraph && <RateGraph /> }
      </section>
    );
  }
}

function mapStateToProps (state) {
  const baseCurrencySet = typeof state.baseCurrency === 'string';
  const counterCurrencySet = typeof state.counterCurrency === 'string';
  const disableSubmission =
    !(state.amount && state.selectedDate && baseCurrencySet && counterCurrencySet);
  const currenciesChanged =
    state.baseCurrency !== state.exchangeRate.base_currency ||
    state.counterCurrency !== state.exchangeRate.counter_currency;
  return {
    baseCurrency: (baseCurrencySet ? state.baseCurrency : ''),
    counterCurrency: (counterCurrencySet ? state.counterCurrency : ''),
    disableSubmission,
    showResults: (typeof state.exchangeRate !== 'undefined' &&
      Object.keys(state.graphData).length > 0) && !currenciesChanged,
    showGraph: (typeof state.graphData !== 'undefined' &&
      Object.keys(state.graphData).length > 0) && !currenciesChanged,
    selectedDate: state.selectedDate
  };
}

export default connect(mapStateToProps)(FxExplorer);
