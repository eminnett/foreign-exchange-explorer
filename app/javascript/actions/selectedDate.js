export const SELECT_DATE = 'SELECT_DATE';
export const SET_DEFAULT_DATE = 'SET_DEFAULT_DATE';

export function selectDate(date) {
  return {
    type: SELECT_DATE,
    date,
  };
}

export function setDefaultDate(date) {
  return {
    type: SET_DEFAULT_DATE,
    date,
  };
}
