const fs = require('fs')

const CONFIG = {
  enPath: 'upstream/en.ts',
  outputZh: 'personal/zh.ts',
  splitAnchor: 'export default'
}

const keyRgxExtract = /^\s*((?:[A-Z0-9_]|LaTeX)+?)\s*:/

function isFiltered(key) {
  const FILTER = [
    'ABOUT_LIBRARIES',
  ]
  return FILTER.includes(key)
}

const targetPath = process.argv[2] || CONFIG.outputZh
extractKeys(targetPath)

function parseFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(`Not found: ${filePath}`)
    return null
  }
  const content = fs.readFileSync(filePath, 'utf8')
  const parts = content.split(CONFIG.splitAnchor)

  return {
    header: parts[0],
    bodyLines: parts.length > 1 ? (CONFIG.splitAnchor + parts[1]).split('\n') : []
  }
}

function extractKeys(targetPath) {
  const file = parseFile(targetPath)
  if (!file || file.bodyLines.length === 0) return

  const result = []
  const filteredResult = []

  let tempBlock = []
  const contentLines = file.bodyLines.slice(1)

  for (let i = 0; i < contentLines.length; i++) {
    const line = contentLines[i]
    const trimmedLine = line.trim()

    if (trimmedLine.startsWith('//')) {
      // if (IGNORE_COMMENTS.includes(trimmedLine)) continue
      tempBlock.push(trimmedLine)
    }
    else if (trimmedLine === '') {
      if (tempBlock.length > 0 && tempBlock[tempBlock.length - 1] !== '') {
        tempBlock.push('')
      }
    }
    else {
      const match = line.match(keyRgxExtract)
      if (match) {
        const key = match[1]
        const tArr =
          // isFiltered(key) ? filteredResult :
          result

        if (tempBlock.length > 0) {
          tArr.push(...tempBlock)
          tempBlock = []
        }
        tArr.push(key)
      }
    }
  }

  const finalOutput = [
    ...result,
    '',
    ...filteredResult
  ].join('\n')

  const idx = targetPath.replaceAll('\\', '/').lastIndexOf('/')
  const outputPath = `${targetPath.slice(0, idx)}/KEYS-${targetPath.slice(idx + 1)}`

  fs.writeFileSync(outputPath, finalOutput, 'utf8')
}
