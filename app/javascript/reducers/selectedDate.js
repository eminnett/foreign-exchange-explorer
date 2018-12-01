import { SELECT_DATE, SET_DEFAULT_DATE } from '../actions/selectedDate';

export default function selectedDate(state = '', action) {
  switch(action.type) {
    case SET_DEFAULT_DATE :
      return state || action.date
    case SELECT_DATE :
      return action.date;
    default :
      return state;
  }
}
