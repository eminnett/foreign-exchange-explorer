import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DateSelector from './DateSelector';
import CurrencyForm from './CurrencyForm';
import CurrencyExchange from './CurrencyExchange';

const FxExplorer = props => (
  <section>
    <div className="form-wrapper">
      <DateSelector />
      <CurrencyForm />
    </div>
    {props.showCurrencyExchange && <CurrencyExchange />}
  </section>
);

FxExplorer.propTypes = {
  showCurrencyExchange: PropTypes.bool.isRequired,
};

function mapStateToProps(state) {
  const currenciesChanged =
    state.baseCurrency !== state.exchangeRate.base_currency ||
    state.counterCurrency !== state.exchangeRate.counter_currency;
  const propertySet = property => {
    return typeof property !== 'undefined' && Object.keys(property).length > 0;
  };
  const showResults = propertySet(state.exchangeRate) && !currenciesChanged;
  const showGraph = propertySet(state.exchangeRate) && !currenciesChanged;

  return {
    showCurrencyExchange: showResults && showGraph && !currenciesChanged,
  };
}

export default connect(mapStateToProps)(FxExplorer);
