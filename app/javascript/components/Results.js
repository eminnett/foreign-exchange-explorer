import React from "react";
import { connect } from 'react-redux';

class Results extends React.Component {
  render () {
    const baseMoney = `${this.props.baseCurrency.symbol}${this.props.amount} ` +
      `(${this.props.baseCurrency.code})`;
    const exchangedMoney = `${this.props.counterCurrency.symbol}` +
      `${(this.props.amount * this.props.exchangeRate).toFixed(2)} ` +
      `(${this.props.counterCurrency.code})`;

    return (
      <div className='results'>
        {`On ${this.props.date},`}
        <br />
        {`${baseMoney} was worth ${exchangedMoney}.`}
      </div>
    );
  }
}

function mapStateToProps (state) {
  let date = state.selectedDate;
  date = typeof date === 'string' ? new Date(date) : date;
  return {
    date: date.toDateString(),
    amount: state.amount,
    exchangeRate: state.exchangeRate.value,
    baseCurrency: Object.values(state.currencies)
      .filter(c => c.code === state.baseCurrency)[0],
    counterCurrency: Object.values(state.currencies)
      .filter(c => c.code === state.counterCurrency)[0]
  };
}

export default connect(mapStateToProps)(Results);
