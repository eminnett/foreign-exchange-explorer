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
        <div className='form-wrapper'>
          <DateSelector />
          <div className='inputs-wrapper'>
            <Amount />
            <div className='label'>
              Convert from this currency:
            </div>
            <CurrencySelector
              action={setBaseCurrency}
              selection={this.props.baseCurrency}
              disabledOption={this.props.counterCurrency}
              placeholder={'Please select currency'}
            />
            <div className='label'>
              To this currency:
            </div>
            <CurrencySelector
              action={setCounterCurrency}
              selection={this.props.counterCurrency}
              disabledOption={this.props.baseCurrency}
              placeholder={'Please select currency'}
            />
            <button
              type='button'
              onClick={this.handleSubmission.bind(this)}
              disabled={!this.props.enableSubmission}
            >Calculate</button>
          </div>
        </div>
        <div className='results-wrapper'>
          { this.props.showResults && <Results /> }
          { this.props.showGraph && <RateGraph /> }
        </div>
      </section>
    );
  }
}

function mapStateToProps (state) {
  const baseCurrencySet =  state.baseCurrency;
  const counterCurrencySet = state.counterCurrency;
  const enableSubmission = state.amount > 0 && baseCurrencySet && counterCurrencySet;
  const currenciesChanged =
    state.baseCurrency !== state.exchangeRate.base_currency ||
    state.counterCurrency !== state.exchangeRate.counter_currency;
  return {
    baseCurrency: (baseCurrencySet ? state.baseCurrency : ''),
    counterCurrency: (counterCurrencySet ? state.counterCurrency : ''),
    enableSubmission,
    showResults: (typeof state.exchangeRate !== 'undefined' &&
      Object.keys(state.graphData).length > 0) && !currenciesChanged,
    showGraph: (typeof state.graphData !== 'undefined' &&
      Object.keys(state.graphData).length > 0) && !currenciesChanged,
    selectedDate: state.selectedDate
  };
}

export default connect(mapStateToProps)(FxExplorer);
