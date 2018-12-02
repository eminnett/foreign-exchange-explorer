import { getDates, getCurrencies, getExchangeRate, getGraphData } from '../utils/exchange_rates_api';
import { receiveDates } from './dates';
import { receiveCurrencies } from './currencies';
import { setEchangeRate } from './exchangeRate';
import { setGraphData } from './graphData';
import { selectDate, setDefaultDate } from './selectedDate';
import { showLoading, hideLoading } from 'react-redux-loading';
import { formatDate } from '../utils/exchange_rates_api';

export function populateData() {
  return (dispatch) => {
    dispatch(showLoading())

    return new Promise(function(resolve, reject) {
      let receivedDates = false;
      let receivedCurrencies = false;
      getDates().then((dates) => {
        if (dates.length > 0) {
          const lastDate = dates[Object.keys(dates).reverse()[0]];
          dispatch(setDefaultDate(lastDate));
          dispatch(receiveDates(dates));
        }
        receivedDates = true;
        if (receivedCurrencies) {
          resolve();
        }
      });
      getCurrencies().then((currencies) => {
        dispatch(receiveCurrencies(currencies));
        receivedCurrencies = true;
        if (receivedDates) {
          resolve();
        }
      });
    }).then(() => {
      dispatch(hideLoading());
    });
  };
}

export function populateExchangeRate(date, baseCurrency, counterCurrency) {
  return (dispatch) => {
    return getExchangeRate(date, baseCurrency, counterCurrency)
      .then((exchangeRate) => {
        dispatch(setEchangeRate(exchangeRate));
      });
  };
}

export function populateGraphData(baseCurrency, counterCurrency) {
  return (dispatch) => {
    return getGraphData(baseCurrency, counterCurrency)
      .then((graphData) => {
        dispatch(setGraphData(graphData));
      });
  };
}

export function changeDate(date) {
  return (dispatch, getState) => {
    const exchangeRate = Object.values(getState().graphData)
      .filter(rate => rate.date === formatDate(date))[0];
    dispatch(selectDate(date));
    dispatch(setEchangeRate(exchangeRate));
  }
}
