import { NodePlopAPI } from 'node-plop'
import { buildGenerator, scriptGenerator, validateGenerator } from './generators'
import { sanitize } from './helpers'

export default function plop(plop: NodePlopAPI): void {
  plop.setGenerator('build', buildGenerator)
  plop.setGenerator('script', scriptGenerator)
  plop.setGenerator('validate', validateGenerator)
  plop.setHelper('sanitize', sanitize)
}
