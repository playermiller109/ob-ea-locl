
<div align="center">

  [zsviczian](https://github.com/zsviczian/obsidian-excalidraw-plugin/releases)
  | [twp.json](https://opencc.js.org/converter?config=s2twp)
  | <>
  <a href="https://github.com/zsviczian/obsidian-excalidraw-plugin/releases/download/<>/main.js">main.js</a>
  <a href="https://github.com/zsviczian/obsidian-excalidraw-plugin/releases/download/<>/styles.css">styles.css</a>
</div>

```js
node --input-type=module -e "import OpenCC from 'opencc-wasm'; import fs from 'node:fs'; (async () => { const dir = 'src/lang/locale/'; const c = await OpenCC.Converter({ config: 's2twp' }); const input = fs.readFileSync(dir+'zh-cn.ts', 'utf8').split('\n'); let output = []; for (let line of input) { output.push(await c(line)); } const final = output.join('\n').replace(/文本/g,'文字').replace(/後設/g,'元').replace(/通過/g,'透過'); fs.writeFileSync(dir+'zh-tw.ts', final); console.log('✨l10n'); })()"
```
