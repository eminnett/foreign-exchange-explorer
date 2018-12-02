export const SET_GRAPH_DATA = 'SET_GRAPH_DATA';

export function setGraphData(graphData) {
  return {
    type: SET_GRAPH_DATA,
    graphData,
  };
};
