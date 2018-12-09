import React from 'react';
import ExplorerApp from './ExplorerApp';
import { createStore } from 'redux';
import { persistStore, persistReducer } from 'redux-persist';
import { PersistGate } from 'redux-persist/integration/react';
import storage from 'redux-persist/lib/storage';
import { Provider } from 'react-redux';
import reducer from '../reducers';
import middleware from '../middleware';

const persistConfig = { key: 'root', storage };
const persistedReducer = persistReducer(persistConfig, reducer);
const store = createStore(persistedReducer, middleware);
const persistor = persistStore(store);

class AppWrapper extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <PersistGate loading={null} persistor={persistor}>
          <ExplorerApp />
        </PersistGate>
      </Provider>
    );
  }
}

export default AppWrapper;
