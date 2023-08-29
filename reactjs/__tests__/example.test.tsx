import { render, screen } from '@testing-library/react'
import App from '../src/App'

describe('example', () => {
  it('example', () => {
    render(<App />)

    const text = screen.getByText(/React/)
    
    expect(text).toBeInTheDocument()
  })
})
