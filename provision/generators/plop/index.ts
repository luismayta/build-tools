import { NodePlopAPI } from 'node-plop'
import { builderGenerator, scriptGenerator, validateGenerator } from './generators'
import { sanitize } from './helpers'

export default function plop(plop: NodePlopAPI): void {
  plop.setGenerator('builder', builderGenerator)
  plop.setGenerator('script', scriptGenerator)
  plop.setGenerator('validate', validateGenerator)
  plop.setHelper('sanitize', sanitize)
}
