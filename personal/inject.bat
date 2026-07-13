// @echo off & chcp 65001 >nul & node "%~f0" %1 & exit /b

const lang = process.argv[2] || 'en'

const fs = require('fs')
const path = require('path')
const zlib = require('zlib')

const langPath = path.join(__dirname, 'zh.ts')
const jsParent = 'D:/obv/Ember/.obsidian/plugins/obsidian-excalidraw-plugin'

let rawCont = fs.readFileSync(langPath, 'utf8')

const match = rawCont.match(/export\s+default\s+/)
if (!match) process.exit(1)
const startIndex = match.index + match[0].length
const contentStr = rawCont.slice(startIndex).trim()

const wrapCode = `x = ${contentStr}`

const compressed = zlib.deflateSync(Buffer.from(wrapCode, 'utf-8'), { level: 9 })
const base64Data = compressed.toString('base64')

let mainJs = fs.readFileSync(jsParent + '/main.js', 'utf8')
const regex = /const PLUGIN_LANGUAGES\s*=.*/
const newDeclaration = `const PLUGIN_LANGUAGES = {"${lang}": "${base64Data}"};`

if (regex.test(mainJs)) {
  mainJs = mainJs.replace('"tags: [excalidraw]",', '')
  mainJs = mainJs.replace('await loadSceneFonts(this.scene.elements),', '')
  mainJs = mainJs.replace('new obsidian_module.Notice(t$d("FONTS_LOADED"))', '')
  fs.writeFileSync(jsParent + '/main.js', mainJs.replace(regex, newDeclaration))
  console.log(`patched: ${lang}`)
} else {
  console.error('PLUGIN_LANGUAGES match failed.')
}
