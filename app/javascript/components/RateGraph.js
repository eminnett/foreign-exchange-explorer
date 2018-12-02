import React from "react";
import { connect } from 'react-redux';
import { Line as LineChart} from 'react-chartjs-2';
import Chart from 'chart.js';

class RateGraph extends React.Component {
  render () {
    return (
      <LineChart
        data={this.props.data}
        options={this.props.options}
      />
    );
  }
}

function mapStateToProps (state) {
  const currencySymbol = Object.values(state.currencies)
    .filter(c => c.code === state.counterCurrency)[0].symbol;
  let data = [];
  let labels = [];
  Object.values(state.graphData).map((datum) => {
    data.push((datum.value * state.amount).toFixed(2));
    labels.push(datum.date);
  })
  const min = Math.min(Object.values(data)) * 0.9;
  const max = Math.max(Object.values(data)) * 1.1;

  const baseCurrency = Object.values(state.currencies)
    .filter(c => c.code === state.baseCurrency)[0];
  const counterCurrency = Object.values(state.currencies)
    .filter(c => c.code === state.counterCurrency)[0];

  const baseMoney = `${baseCurrency.symbol}${state.amount} (${baseCurrency.code})`;
  const exchangedCurrency = `${counterCurrency.symbol} (${counterCurrency.code})`;
  const label = `${baseMoney} in ${exchangedCurrency}`;

  return {
    selectedDate: state.selectedDate,
    data: {
      datasets: [{label, data, borderColor: '#156A0B', backgroundColor: 'rgba(21,106,11, 0.3)'}],
      labels
    },
    options: {
    }
  };
}

export default connect(mapStateToProps)(RateGraph);
