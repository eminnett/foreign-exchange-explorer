import { RECEIVE_CURRENCIES } from '../actions/currencies';

export default function currencies(state = {}, action) {
  switch (action.type) {
    case RECEIVE_CURRENCIES:
      return {
        ...state,
        ...action.currencies,
      };
    default:
      return state;
  }
}
