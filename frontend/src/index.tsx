import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

import './index.css';

/**
 * Entry point of the React application.
 *
 * - Initializes the React 18 root using ReactDOM.createRoot.
 * - Renders the main App component into the HTML element with id "root".
 * - Wraps the App in React.StrictMode to help identify potential problems in development mode.
 * - Imports global CSS styles for consistent rendering.
 */
const root = ReactDOM.createRoot(document.getElementById('root')!);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
