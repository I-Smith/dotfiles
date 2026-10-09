import { test, expect } from 'claude-code/testing'

test('band stays empty until a measurement arrives', async ($, on) => {
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return h(Text, null, 'engine default') as never
  })
  const ui = await $.ui.mount({ plugin: 'usage-band', surface: 'terminal', component: 'AbovePrompt', props: {} } as never)
  expect(await ui.find({ type: 'Text', text: /ctx/ })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: /engine default/ })).toBeDefined()
  await ui.unmount()
})
