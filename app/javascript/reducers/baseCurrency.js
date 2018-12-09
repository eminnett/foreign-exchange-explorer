import { SET_BASE_CURRENCY } from '../actions/baseCurrency';

export default function baseCurrency(state = '', action) {
  switch (action.type) {
    case SET_BASE_CURRENCY:
      return action.baseCurrency;
    default:
      return state;
  }
}
