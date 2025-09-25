const fs = require('fs')

const [,, targetPath] = process.argv
if (targetPath) {
  extractKeys(targetPath, 'export default')
}
else {
  const folder = 'upstream'
  const upstreamTsNames = ['en.ts']
  for (const fileName of upstreamTsNames) {
    const targetPath = `${folder}/${fileName}`
    extractKeys(targetPath, 'export default')
  }
}

function extractKeys(targetPath, splitAnchor) {
  targetPath = targetPath.replaceAll('\\', '/')
  const idx = targetPath.lastIndexOf('/')
  const folder = targetPath.slice(0, idx)
  const fileName = targetPath.slice(idx+1)
  const outputPath = `${folder}/KEYS-${fileName}`

  const tgtCont = fs.readFileSync(targetPath, 'utf8')
  const tgtObjStr = tgtCont.split(splitAnchor)[1].trim()
  const outputCont = processLines(tgtObjStr.split('\n'))
  fs.writeFileSync(outputPath, outputCont, 'utf8')
}

function processLines(lines) {
  const keyRgx = /((?:[A-Z0-9_]+|LaTeX)+?)\s*?\:\s*?("|`|$)/g

  const result = []
  let lastIsEmpty = !1
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()

    if (line) {
      lastIsEmpty = !1
      if (line.startsWith('//')) {
        // if (!line.match(keyRgx))
          result.push(line)
      }
      else {
        keyRgx.lastIndex = 0
        const matches = []
        let match
        while ((match = keyRgx.exec(line)) !== null) {
          matches.push(match[1])
        }
        if (matches[0]) result.push(matches)
      }
    }
    else if (!lastIsEmpty) {
      result.push('')
      lastIsEmpty = !0
    }
  }
  return result.join('\n')
}