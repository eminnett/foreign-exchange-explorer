export const findCurrencyByCode = function(currencies, code) {
  return Object.values(currencies).filter(c => c.code === code)[0];
};
