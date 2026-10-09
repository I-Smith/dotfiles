import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Reading } from '../types'

const reading = atom({ plugin: 'usage-band', key: 'reading' } as const, null)
const effort = atom({ plugin: 'usage-band', key: 'effort' } as const, null)

const shortModel = (m: string) => m.replace(/^claude-/, '').replace(/-\d{8}$/, '')

const tone = (pct: number) => (pct >= 85 ? 'error' : pct >= 60 ? 'warning' : 'success')

const label = (kind: string) =>
  kind === 'five_hour' ? '5h' : kind === 'seven_day' ? '7d' : kind === 'spend_limit' ? '$lim' : kind

const kfmt = (n: number) => (n >= 1e6 ? `${(n / 1e6).toFixed(1)}M` : n >= 1e3 ? `${Math.round(n / 1e3)}k` : `${n}`)

const until = (iso: string | undefined, now: number) => {
  if (!iso) return ''
  const m = Math.max(0, Math.round((Date.parse(iso) - now) / 60000))
  return m >= 1440 ? ` ↻${Math.floor(m / 1440)}d` : m >= 60 ? ` ↻${Math.floor(m / 60)}h${m % 60}m` : ` ↻${m}m`
}

const bar = (pct: number) => {
  const n = Math.round(Math.min(100, pct) / 20)
  return '█'.repeat(n) + '░'.repeat(5 - n)
}

export const register: Register = on => {
  on('turn.step', async function* ($, e, next) {
    await update($, effort, () => (e.effort === undefined ? null : String(e.effort)))

    return yield* next(e)
  })

  on('session.measure', async ($, e, next) => {
    const r: Reading = {
      ctx: e.context.percent,
      tokens: e.context.tokens,
      window: e.context.window,
      limits: e.rateLimits.map(l => ({ kind: l.kind, pct: l.percentUsed, resetsAt: l.resetsAt })),
      usd: e.cost?.usd,
    }
    await update($, reading, () => r)

    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const r = await read($, reading)

    if (e.props.hasSurvey || r === null) {
      return next(e)
    }

    const now = await $.clock.now()
    const model = shortModel(await $.session.model())
    const eff = await read($, effort)
    const { Box, Text } = $.ui.resolve(e)
    const ctx = r.ctx ?? 0

    return (
      <Box>
        <Text color="claude" bold>{model}</Text>
        {eff !== null ? <Text color="suggestion"> {eff}</Text> : null}
        <Text dimColor> │ ctx </Text>
        <Text color={tone(ctx)}>{bar(ctx)} {Math.round(ctx)}%</Text>
        <Text dimColor> {r.tokens !== undefined ? `${kfmt(r.tokens)}/` : ''}{kfmt(r.window)}</Text>
        {r.limits.map(l => (
          <Text key={l.kind}>
            <Text dimColor> │ {label(l.kind)} </Text>
            <Text color={tone(l.pct)}>{bar(l.pct)} {Math.round(l.pct)}%</Text>
            <Text dimColor>{until(l.resetsAt, now)}</Text>
          </Text>
        ))}
        {r.usd !== undefined ? <Text dimColor> │ ${r.usd.toFixed(2)}</Text> : null}
      </Box>
    )
  })
}
