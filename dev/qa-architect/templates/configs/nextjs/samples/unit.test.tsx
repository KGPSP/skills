// Sample test from qa-architect blueprint.
// Warstwa: unit/component
// Wzorzec: references/stack-profiles/nextjs-react.md §9
//
// Demonstrates:
//   - getByRole({ name }) as default selector (semantic, accessibility-aware)
//   - userEvent.setup() for realistic interactions
//   - 1 happy path + 1 edge case (Beyoncé Rule)
//   - DAMP — test reads as spec, no magical helpers

import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { vi, describe, test, expect } from 'vitest'

// --- Component under test (would normally live in src/components/LoginForm.tsx) ---
import { useState } from 'react'

type Props = { onSubmit: (email: string, password: string) => Promise<void> }

function LoginForm({ onSubmit }: Props) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [busy, setBusy] = useState(false)
  const [err, setErr] = useState<string | null>(null)

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setBusy(true)
    setErr(null)
    try {
      await onSubmit(email, password)
    } catch (e) {
      setErr(e instanceof Error ? e.message : 'unknown error')
    } finally {
      setBusy(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} aria-label="formularz logowania">
      <label>Email
        <input type="email" value={email} onChange={(e) => setEmail(e.currentTarget.value)} />
      </label>
      <label>Hasło
        <input type="password" value={password} onChange={(e) => setPassword(e.currentTarget.value)} />
      </label>
      <button type="submit" disabled={busy}>{busy ? 'Logowanie…' : 'Zaloguj'}</button>
      {err && <p role="alert">{err}</p>}
    </form>
  )
}

// --- Tests ---

describe('LoginForm', () => {
  test('wysyła formularz z poprawnymi danymi (happy path)', async () => {
    const onSubmit = vi.fn().mockResolvedValue(undefined)
    const user = userEvent.setup()

    render(<LoginForm onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText('Email'), 'anna@example.com')
    await user.type(screen.getByLabelText('Hasło'), 'tajnehaslo')
    await user.click(screen.getByRole('button', { name: 'Zaloguj' }))

    expect(onSubmit).toHaveBeenCalledWith('anna@example.com', 'tajnehaslo')
  })

  test('pokazuje błąd serwera (edge case — server failure)', async () => {
    const onSubmit = vi.fn().mockRejectedValue(new Error('Nieprawidłowe dane'))
    const user = userEvent.setup()

    render(<LoginForm onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText('Email'), 'x@y.z')
    await user.type(screen.getByLabelText('Hasło'), 'wrong')
    await user.click(screen.getByRole('button', { name: 'Zaloguj' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Nieprawidłowe dane')
  })
})
