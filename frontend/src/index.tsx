import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

/**
 * Entry point of the React application.
 *
 * Creates the React root and renders the App component inside
 * the HTML element with id "root". Wraps the App in React.StrictMode
 * for highlighting potential problems during development.
 */
const root = ReactDOM.createRoot(document.getElementById('root')!);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
