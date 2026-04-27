import './App.css'
import { Authenticator } from '@aws-amplify/ui-react'
import '@aws-amplify/ui-react/styles.css'

const App = () => {
  return (
    <Authenticator hideSignUp>
      {({ signOut, user }) => (
        <div className='App'>
          <main>
            {user && <h1>Hello {user.username}</h1>}
            <button onClick={signOut}>Sign out</button>

            <header className='App-header'>
              <p>
                Edit <code>src/App.tsx</code> and save to reload.
              </p>
              <a
                className='App-link'
                href='https://reactjs.org'
                target='_blank'
                rel='noopener noreferrer'
              >
                Learn React
              </a>
            </header>
          </main>
        </div>
      )}
    </Authenticator>
  )
}

export default App
