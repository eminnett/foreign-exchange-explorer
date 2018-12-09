export const SET_COUNTER_CURRENCY = 'SET_COUNTER_CURRENCY';

export function setCounterCurrency(counterCurrency) {
  return {
    type: SET_COUNTER_CURRENCY,
    counterCurrency,
  };
}
