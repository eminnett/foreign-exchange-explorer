import React from "react";
import { connect } from 'react-redux';
import { setAmount } from '../actions/amount';

class Amount extends React.Component {
  handleChange = (event) => {
    this.props.dispatch(setAmount(event.target.value));
  };

  render () {
    return (
      <div className='amount-inout'>
        Amount:
        <input
          value={this.props.amount}
          type='number'
          min='0'
          step='0.01'
          placeholder='Please choose how much to convert.'
          onChange={this.handleChange.bind(this)}
        />
      </div>
    );
  }
}

function mapStateToProps (state) {
  return {
    amount: state.amount
  };
}

export default connect(mapStateToProps)(Amount);
