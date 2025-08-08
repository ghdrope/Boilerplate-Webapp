/**
 * Integration test for HelloWorld component
 *
 * Ensures:
 * - The HelloWorld component is correctly rendered when used inside the Home component
 * - The integration between Home and HelloWorld works as expected
 */

import { render, screen } from '@testing-library/react';
import Home from '../Home';

describe('HelloWorld Component (Integration Test)', () => {
  it('renders HelloWorld inside Home component', () => {
    render(<Home />);
    const heading = screen.getByRole('heading', { name: /hello world!/i });
    expect(heading).toBeInTheDocument();
  });
});
