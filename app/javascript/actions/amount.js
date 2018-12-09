export const SET_AMOUNT = 'SET_AMOUNT';

export function setAmount(amount) {
  return {
    type: SET_AMOUNT,
    amount,
  };
}
