import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from './App';

/**
 * Unit test for App component.
 *
 * Verifies if the App renders the Home component correctly.
 * Since Home renders HelloWorld, we expect "Hello World!" text to be present.
 */
describe('App Component (Unit Test)', () => {
  it('renders Home component with HelloWorld', () => {
    render(<App />);
    const heading = screen.getByRole('heading', { name: /hello world!/i });
    expect(heading).toBeInTheDocument;
  });
});
