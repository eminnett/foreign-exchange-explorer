import React from 'react';
import { connect } from 'react-redux';
import { formatDate } from '../utils/exchange_rates_api';
import { Line as LineChart } from 'react-chartjs-2';
// import Chart from 'chart.js';

class RateGraph extends React.Component {
  render() {
    return <LineChart data={this.props.data} options={this.props.options} />;
  }
}

function mapStateToProps(state) {
  let data = [];
  let labels = [];
  let pointRadii = [];
  let pointColours = [];
  let pointBorderWidths = [];
  Object.values(state.graphData).map(datum => {
    data.push((datum.value * state.amount).toFixed(2));
    labels.push(datum.date);

    // Populate point styling arrays so the selected date is highlighted.
    if (datum.date === formatDate(state.selectedDate)) {
      pointRadii.push(5);
      pointColours.push('rgba(255,255,255, 0.8)');
      pointBorderWidths.push(2);
    } else {
      pointRadii.push(2);
      pointColours.push('rgba(21,106,11, 0.6)');
      pointBorderWidths.push(1);
    }
  });

  const baseCurrency = Object.values(state.currencies).filter(
    c => c.code === state.baseCurrency,
  )[0];
  const counterCurrency = Object.values(state.currencies).filter(
    c => c.code === state.counterCurrency,
  )[0];

  const baseMoney = `${baseCurrency.symbol}${state.amount} (${
    baseCurrency.code
  })`;
  const exchangedCurrency = `${counterCurrency.symbol} (${
    counterCurrency.code
  })`;
  const label = `${baseMoney} in ${exchangedCurrency}`;

  return {
    selectedDate: state.selectedDate,
    data: {
      datasets: [
        {
          label,
          data,
          borderColor: '#156A0B',
          backgroundColor: 'rgba(21,106,11, 0.3)',
          lineTension: 0,
          pointRadius: pointRadii,
          pointBackgroundColor: pointColours,
          pointBorderWidth: pointBorderWidths,
        },
      ],
      labels,
    },
    options: {},
  };
}

export default connect(mapStateToProps)(RateGraph);
