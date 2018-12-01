import React from "react";
import { connect } from 'react-redux';
import DayPicker from 'react-day-picker';
import 'react-day-picker/lib/style.css';
import { selectDate } from '../actions/selectedDate';
import { formatDate } from '../utils/exchange_rates_api'

class DateSelector extends React.Component {
  handleSelection = (day, { selected }) => {
    const selection = selected ? undefined : day;
    this.props.dispatch(selectDate(selection));
  };

  render () {
    const dates = this.props.dates;
    const firstDay = new Date(dates[0]);
    const lastDay = new Date(dates[Object.keys(dates).reverse()[0]]);
    const firstMonth = new Date(firstDay.getFullYear(), firstDay.getMonth());
    const lastMonth = new Date(lastDay.getFullYear(), lastDay.getMonth());
    const selection = this.props.selectedDate;
    const disabledDays = [firstMonth,
      { after: firstMonth , before: firstDay },
      {
        after: lastDay,
        before: new Date(lastDay.getFullYear(), lastDay.getMonth()+1, 1)
      }
    ];
    let dt = new Date(firstDay);
    while(dt < lastDay) {
      let dtString = formatDate(dt);
      if (!Object.values(dates).includes(dtString)) {
        disabledDays.push(new Date(dt));
      }
      dt.setDate(dt.getDate() + 1);
    }

    return (
      <DayPicker
        fromMonth={firstMonth}
        toMonth={lastMonth}
        initialMonth={lastMonth}
        disabledDays={disabledDays}
        selectedDays={selection}
        onDayClick={this.handleSelection.bind(this)}
      />
    );
  }
}

function mapStateToProps (state) {
  const selectedDate = state.selectedDate ?
    (typeof state.selectedDate === 'string' ?
      new Date(state.selectedDate) : state.selectedDate) :
    undefined;
  return {dates: state.dates, selectedDate};
}

export default connect(mapStateToProps)(DateSelector);
