import { formatDate } from '@@/utils/exchange_rates_api';

test('formatDate returns a string', () => {
  expect(typeof formatDate(new Date(2018, 11, 8))).toEqual('string');
});

test('formatDate returns the right format', () => {
  expect(formatDate(new Date(2018, 11, 8))).toEqual('2018-12-08');
});
