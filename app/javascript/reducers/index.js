import { combineReducers } from 'redux';
import { loadingBarReducer } from 'react-redux-loading';
import amount from './amount';
import baseCurrency from './baseCurrency';
import counterCurrency from './counterCurrency';
import currencies from './currencies';
import dates from './dates';
import exchangeRate from './exchangeRate';
import graphData from './graphData';
import selectedDate from './selectedDate';

export default combineReducers({
  amount,
  baseCurrency,
  counterCurrency,
  currencies,
  dates,
  exchangeRate,
  graphData,
  selectedDate,
  loadingBar: loadingBarReducer,
});
