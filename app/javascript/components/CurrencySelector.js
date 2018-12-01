import React from "react";
import { connect } from 'react-redux';

class CurrencySelector extends React.Component {

  handleChange = (event) => {
    this.props.dispatch(this.props.action(event.target.value));
  };

  render () {
    return (
      <select
        value={this.props.selection}
        onChange={this.handleChange.bind(this)}
      >
        <option
          value=''
          disabled={this.props.selectionMade}
        >{this.props.placeholder}</option>
        { Object.values(this.props.currencies).map((currency) => (
          <option
            key={currency.id}
            value={currency.code}
            disabled={currency.code === this.props.disabledOption}
          >
            {currency.code}
          </option>
        ))}
      </select>
    );
  }
}

function mapStateToProps(state, ownProps) {
  return {
    selectionMade: ownProps.selection !== '',
    currencies: state.currencies
  };
}

export default connect(mapStateToProps)(CurrencySelector);
