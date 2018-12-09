import React, { Component } from 'react';
import { connect } from 'react-redux';
import { populateData } from '../actions/shared';
import LoadingBar from 'react-redux-loading';
import FxExplorer from './FxExplorer';

class ExplorerApp extends React.Component {
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

function mapStateToProps(state) {
  const noDates = Object.keys(state.dates).length === 0;
  const noCurrencies = Object.keys(state.currencies).length === 0;
  return {
    loading: noDates || noCurrencies,
  };
}

export default connect(mapStateToProps)(ExplorerApp);
