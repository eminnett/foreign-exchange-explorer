const api = "/api/v1/"

const headers = { 'Accept': 'application/json' }

export const formatDate = function(date) {
  date = typeof date === 'string' ? new Date(date) : date;
  return date.toISOString().split('T')[0]
}

export const getDates = (dates) =>
  fetch(`${api}/dates`, { headers })
    .then(res => res.json())

export const getCurrencies = (currencies) =>
  fetch(`${api}/currencies`, { headers })
    .then(res => res.json())

export const getExchangeRate = (date, baseCurrency, counterCurrency) =>
  fetch(`${api}/exchange-rates/${baseCurrency}/${counterCurrency}/` +
    `?on=${formatDate(date)}`, { headers })
    .then(res => res.json())

export const getGraphData = (baseCurrency, counterCurrency) =>
  fetch(`${api}/exchange-rates/${baseCurrency}/${counterCurrency}/`, { headers })
    .then(res => res.json())

// export const getAll = () =>
//   fetch(`${api}/books`, { headers })
//     .then(res => res.json())
//     .then(data => data.books)
//
// export const update = (book, shelf) =>
//   fetch(`${api}/books/${book.id}`, {
//     method: 'PUT',
//     headers: {
//       ...headers,
//       'Content-Type': 'application/json'
//     },
//     body: JSON.stringify({ shelf })
//   }).then(res => res.json())
//
// export const search = (query) =>
//   fetch(`${api}/search`, {
//     method: 'POST',
//     headers: {
//       ...headers,
//       'Content-Type': 'application/json'
//     },
//     body: JSON.stringify({ query })
//   }).then(res => res.json())
//     .then(data => data.books)
