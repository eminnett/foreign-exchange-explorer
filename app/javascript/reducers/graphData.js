import { SET_GRAPH_DATA } from '../actions/graphData';

export default function graphData(state = {}, action) {
  switch (action.type) {
    case SET_GRAPH_DATA:
      return action.graphData;
    default:
      return state;
  }
}
