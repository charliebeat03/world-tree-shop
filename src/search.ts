/**
 * Búsqueda tolerante a tildes, mayúsculas y errores tipográficos pequeños.
 * Se comparte entre el catálogo público y el panel administrativo.
 */
export const normalizeSearch = (value: string) =>
  value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLocaleLowerCase().trim()

function editDistance(a: string, b: string): number {
  if (Math.abs(a.length - b.length) > 2) return 3
  const matrix = Array.from({ length: a.length + 1 }, () => Array(b.length + 1).fill(0))
  for (let i = 0; i <= a.length; i++) matrix[i][0] = i
  for (let j = 0; j <= b.length; j++) matrix[0][j] = j
  for (let i = 1; i <= a.length; i++) {
    for (let j = 1; j <= b.length; j++) {
      const substitution = matrix[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1)
      matrix[i][j] = Math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, substitution)
      // Una transposición de letras contiguas cuenta como un único error.
      if (i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1]) {
        matrix[i][j] = Math.min(matrix[i][j], matrix[i - 2][j - 2] + 1)
      }
    }
  }
  return matrix[a.length][b.length]
}

function tokenMatches(queryToken: string, candidate: string): boolean {
  if (candidate.includes(queryToken) || queryToken.includes(candidate)) return true
  if (queryToken.length < 4 || candidate.length < 4) return false
  const threshold = queryToken.length >= 8 ? 2 : 1
  return editDistance(queryToken, candidate) <= threshold
}

export function matchesSearch(query: string, values: Array<string | null | undefined>): boolean {
  const normalizedQuery = normalizeSearch(query)
  if (!normalizedQuery) return true
  const candidates = values
    .filter((value): value is string => Boolean(value))
    .flatMap(value => normalizeSearch(value).split(/[^a-z0-9]+/).filter(Boolean))
  const fullText = values.filter(Boolean).map(value => normalizeSearch(value!)).join(' ')
  if (fullText.includes(normalizedQuery)) return true
  const queryTokens = normalizedQuery.split(/\s+/).filter(Boolean)
  return queryTokens.every(token => candidates.some(candidate => tokenMatches(token, candidate)))
}
