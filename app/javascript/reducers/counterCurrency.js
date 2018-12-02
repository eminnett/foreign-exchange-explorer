import { SET_COUNTER_CURRENCY } from '../actions/counterCurrency';

export default function counterCurrency(state = '', action) {
  switch(action.type) {
    case SET_COUNTER_CURRENCY :
      return action.counterCurrency;
    default :
      return state;
  }
}
