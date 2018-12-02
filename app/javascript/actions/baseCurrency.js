export const SET_BASE_CURRENCY = 'SET_BASE_CURRENCY';

export function setBaseCurrency(baseCurrency) {
  return {
    type: SET_BASE_CURRENCY,
    baseCurrency,
  };
};
