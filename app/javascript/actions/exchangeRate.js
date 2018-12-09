export const SET_EXCHANGE_RATE = 'SET_EXCHANGE_RATE';

export function setEchangeRate(exchangeRate) {
  return {
    type: SET_EXCHANGE_RATE,
    exchangeRate,
  };
}
