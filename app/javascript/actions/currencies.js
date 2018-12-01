export const RECEIVE_CURRENCIES = 'RECEIVE_CURRENCIES';

export function receiveCurrencies(currencies) {
  return {
    type: RECEIVE_CURRENCIES,
    currencies,
  };
};
