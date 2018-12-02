import React from "react";
import { connect } from 'react-redux';

class Results extends React.Component {

  readableDate (date) {
    const d = typeof date === 'string' ? new Date(date) : date;
    const dayLabels = ['Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday']
    const monthLabels = ['Januray', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December']
    const weekDay = dayLabels[d.getDay()];
    const day = this.ordinalNumber(d.getDate());
    const month = monthLabels[d.getMonth()];
    const year = d.getFullYear();

    return `${weekDay} the ${day} of ${month}, ${year}`
  }

  ordinalNumber (x) {
    var j = x % 10,
        k = x % 100;
    if (j == 1 && k != 11) {
      return x + "st";
    }
    if (j == 2 && k != 12) {
      return x + "nd";
    }
    if (j == 3 && k != 13) {
      return x + "rd";
    }
    return x + "th";
  }

  delimitedNumber (x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  render () {
    const baseAmount = this.delimitedNumber(this.props.amount);
    const exchangedAmount = this.delimitedNumber(
      (this.props.amount * this.props.exchangeRate).toFixed(2)
    );
    const baseMoney = `${this.props.baseCurrency.symbol}${baseAmount}\xa0` +
      `(${this.props.baseCurrency.code})`;
    const exchangedMoney = `${this.props.counterCurrency.symbol}` +
      `${exchangedAmount}\xa0(${this.props.counterCurrency.code})`;

    return (
      <div className='results'>
        {`On ${this.readableDate(this.props.date)},`}
        <span className='conditional-line-break'></span>
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
