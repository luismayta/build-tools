import helpers from 'handlebars-helpers'

export const sanitize = (name: string): string => {
  return helpers().snakecase(name.replace(/[.-]+/g, '').toString())
}

export const cleanString = (text: string): string => {
  return text.replace(/[.-_]+/g, ' ').toLowerCase()
}

export const hyphenate = (text: string): string => {
  return text.replace(/([a-zA-Z])(?=[A-Z])/g, '$1-').toLowerCase()
}
