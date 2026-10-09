export type Reading = {
  ctx?: number
  tokens?: number
  window: number
  limits: { kind: string; pct: number; resetsAt?: string }[]
  usd?: number
}

declare module 'claude-code' {
  interface PluginState {
    'usage-band': { reading: Reading | null; effort: string | null }
  }
}
