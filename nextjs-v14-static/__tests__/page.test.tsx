import '@testing-library/jest-dom'
import { render, screen } from '@testing-library/react'
import Home from '../app/page'

describe('Home', () => {
  it('renders the Home page', () => {
    render(<Home />)

    const text = screen.getByText('app/page.tsx')

    expect(text).toBeInTheDocument()
  })
})
