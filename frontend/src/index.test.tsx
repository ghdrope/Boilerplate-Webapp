/**
 * @jest-environment jsdom
 */

import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

describe('index.tsx bootstrap', () => {
  let container: HTMLElement;

  beforeEach(() => {
    // Create a div element with id 'root' to simulate the root element in the HTML
    container = document.createElement('div');
    container.id = 'root';
    // Append the container to the document body so React can render into it
    document.body.appendChild(container);
  });

  afterEach(() => {
    // Clean up by removing the container from the document body after each test
    document.body.removeChild(container);
  });

  it('renders App component without crashing', () => {
    // Create a React root on the container element
    const root = ReactDOM.createRoot(container);
    // Assert that rendering the <App /> component inside React.StrictMode does not throw any errors
    expect(() =>
      root.render(
        <React.StrictMode>
          <App />
        </React.StrictMode>
      )
    ).not.toThrow();
  });
});
