import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DayPicker from 'react-day-picker';
import 'react-day-picker/lib/style.css';
import { changeDate } from '../actions/shared';
import { formatDate } from '../utils/exchange_rates_api';

class DateSelector extends React.Component {
  handleSelection = (day, modifiers = {}) => {
    if (modifiers.disabled) {
      return;
    }
    const selection = modifiers.selected ? undefined : day;
    this.props.dispatch(changeDate(selection));
  };

  render() {
    const dates = this.props.dates;
    const firstDay = new Date(dates[0]);
    const lastDay = new Date(dates[Object.keys(dates).reverse()[0]]);
    const firstMonth = new Date(firstDay.getFullYear(), firstDay.getMonth());
    const lastMonth = new Date(lastDay.getFullYear(), lastDay.getMonth());
    const selection = this.props.selectedDate;
    const disabledDays = [
      firstMonth,
      { after: firstMonth, before: firstDay },
      {
        after: lastDay,
        before: new Date(lastDay.getFullYear(), lastDay.getMonth() + 1, 1),
      },
    ];
    let dt = new Date(firstDay);
    while (dt < lastDay) {
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
        initialMonth={selection}
        disabledDays={disabledDays}
        selectedDays={selection}
        onDayClick={this.handleSelection.bind(this)}
      />
    );
  }
}

DateSelector.propTypes = {
  dispatch: PropTypes.func.isRequired,
  dates: PropTypes.object.isRequired,
  selectedDate: PropTypes.instanceOf(Date).isRequired,
};

function mapStateToProps(state) {
  const selectedDate = state.selectedDate
    ? typeof state.selectedDate === 'string'
      ? new Date(state.selectedDate)
      : state.selectedDate
    : undefined;
  return { dates: state.dates, selectedDate };
}

export default connect(mapStateToProps)(DateSelector);
