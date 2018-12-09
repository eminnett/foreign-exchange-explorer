import { SET_EXCHANGE_RATE } from '../actions/exchangeRate';

export default function exchangeRate(state = {}, action) {
  switch (action.type) {
    case SET_EXCHANGE_RATE:
      return action.exchangeRate;
    default:
      return state;
  }
}
