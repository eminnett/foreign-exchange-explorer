import { SET_AMOUNT } from '../actions/amount';

export default function amount(state = {}, action) {
  switch(action.type) {
    case SET_AMOUNT :
      return action.amount;
    default :
      return state;
  }
}
