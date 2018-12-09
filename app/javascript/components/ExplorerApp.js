import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { populateData } from '../actions/shared';
import LoadingBar from 'react-redux-loading';
import FxExplorer from './FxExplorer';

class ExplorerApp extends Component {
  componentDidMount() {
    if (this.props.loading) {
      this.props.dispatch(populateData());
    }
  }

  render() {
    return (
      <div className="App">
        <LoadingBar className="loading-bar" />
        {this.props.loading && <p>The FX Explorer will load momentarily.</p>}
        {!this.props.loading && <FxExplorer />}
      </div>
    );
  }
}

ExplorerApp.propTypes = {
  loading: PropTypes.bool.isRequired,
  dispatch: PropTypes.func.isRequired,
};

function mapStateToProps(state) {
  const noDates = Object.keys(state.dates).length === 0;
  const noCurrencies = Object.keys(state.currencies).length === 0;
  return {
    loading: noDates || noCurrencies,
  };
}

export default connect(mapStateToProps)(ExplorerApp);
