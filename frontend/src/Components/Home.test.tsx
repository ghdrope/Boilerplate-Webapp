import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Home from './Home';

/**
 * Unit test for Home component.
 *
 * Checks if the Home component renders HelloWorld component correctly
 * by looking for the heading text from HelloWorld.
 */
describe('Home Component (Unit Test)', () => {
  it('renders HelloWorld component inside main', () => {
    render(<Home />);
    const heading = screen.getByRole('heading', { name: /hello world!/i });
    expect(heading).toBeInTheDocument();
  });
});
