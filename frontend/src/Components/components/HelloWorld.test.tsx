import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import HelloWorld from './HelloWorld';

/**
 * Unit test for HelloWorld component.
 *
 * Checks if the component renders the expected text "Hello World!".
 */
describe('HelloWorld Component (Unit Test)', () => {
  it('renders the heading with "Hello World!" text', () => {
    render(<HelloWorld />);
    const heading = screen.getByRole('heading', { name: /hello world!/i });
    expect(heading).toBeInTheDocument();
  });
});
