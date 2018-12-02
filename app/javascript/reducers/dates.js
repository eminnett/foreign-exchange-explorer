import { RECEIVE_DATES } from '../actions/dates';

export default function dates(state = {}, action) {
  switch(action.type) {
    case RECEIVE_DATES :
      return {
        ...state,
        ...action.dates
      };
    default :
      return state;
  }
}
