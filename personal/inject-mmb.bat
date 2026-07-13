// @echo off & chcp 65001 >nul & node "%~f0" %1 & pause

const lang = process.argv[2] || 'en'

const fs = require('fs')
const path = require('path')
const { minify } = require('terser')
const LZString = require('lz-string')
const acorn = require('acorn')

const REMOTE_URL = 'https://cdn.jsdelivr.net/gh/zsviczian/obsidian-excalidraw-plugin@master/ea-scripts/Mindmap Builder.js.md'
const langPath = path.join(__dirname, 'zh-mmb.ts')
const outputPath = 'D:/obv/Ember/s5/Excalidraw/Downloaded/Mindmap Builder.md'

const CHUNK_SIZE = 256

async function main() {
  try {
    console.log('fetching...')
    const response = await fetch(REMOTE_URL)
    if (!response.ok) throw new Error('Failed to fetch')
    let source = await response.text()

    const ast = acorn.parse(source, {
      ecmaVersion: 'latest',
      sourceType: 'script',
      allowReturnOutsideFunction: true
    })

    const addLocaleNodes = ast.body.filter(node =>
      node.type === 'ExpressionStatement' &&
      node.expression.type === 'CallExpression' &&
      node.expression.callee.name === 'addLocale'
    )

    const rangeStart = addLocaleNodes[0].start
    const rangeEnd = addLocaleNodes[addLocaleNodes.length - 1].end

    let stringsBody = fs.readFileSync(langPath, 'utf-8')

    const newLocaleCall = `\naddLocale("${lang}", ${stringsBody});\n`

    const data =
      source.substring(0, rangeStart) +
      newLocaleCall +
      source.substring(rangeEnd)

    const minified = await minify(data, {
      compress: { passes: 3 },
      mangle: true,
      parse: { bare_returns: true },
      module: false,
    })
    const compressed = LZString.compressToBase64(minified.code)

    let result = ''
    for (let i = 0; i < compressed.length; i += CHUNK_SIZE) {
      result += '\n ' + compressed.slice(i, i + CHUNK_SIZE)
    }

    const finalMD = `/*
\`\`\`js*/
const existingTab = ea.checkForActiveSidepanelTabForScript();
if (existingTab) {
  const hostEA = existingTab.getHostEA();
  if (hostEA && hostEA !== ea) {
    hostEA.activateMindmap = true;
    hostEA.setView(ea.targetView);
    existingTab.open(false);
    return;
  }
}

const mmbSource = \`${result}\`;
const script = ea.decompressFromBase64(mmbSource.replaceAll("\\n ", "").trim());
const AsyncFunction = Object.getPrototypeOf(async () => {}).constructor;
await new AsyncFunction("ea", "utils", script)(ea, utils);
`

    fs.writeFileSync(outputPath, finalMD, 'utf-8')
  } catch (err) {
    console.error(err.message)
  }
}

main()
