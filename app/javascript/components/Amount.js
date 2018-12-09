import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { setAmount } from '../actions/amount';

class Amount extends React.Component {
  handleChange = event => {
    this.props.dispatch(setAmount(event.target.value));
  };

  render() {
    return (
      <div className="amount-input">
        <div className="label">Amount to Convert:</div>
        <input
          value={this.props.amount}
          type="number"
          min="0.01"
          step="0.01"
          placeholder="How much to convert?"
          onChange={this.handleChange.bind(this)}
        />
      </div>
    );
  }
}

Amount.propTypes = {
  dispatch: PropTypes.func.isRequired,
  amount: PropTypes.string.isRequired,
};

function mapStateToProps(state) {
  return {
    amount: state.amount > 0 ? state.amount : '',
  };
}

export default connect(mapStateToProps)(Amount);
