export const RECEIVE_DATES = 'RECEIVE_DATES';

export function receiveDates(dates) {
  return {
    type: RECEIVE_DATES,
    dates,
  };
}
