import { Actions, PlopGeneratorConfig } from 'node-plop'
import * as path from 'path'
import { ScriptsPrompNames, AnswersScript as Answers } from './entities'
import { baseRootPath, baseTemplatesPath, pathExists } from '../utils'
import { sanitize } from '../helpers'
const testPath = path.join(baseRootPath, 'test')

export const scriptGenerator: PlopGeneratorConfig = {
  description: 'add an script test',
  prompts: [
    {
      type: 'input',
      name: ScriptsPrompNames.name,
      message: 'What should it be name script?',
      default: 'docker install'
    }
  ],
  actions: (data) => {
    const answers = data as Answers
    const scriptPath = `${baseRootPath}/scripts/`

    if (pathExists(scriptPath)) {
      throw new Error(`Stage '${answers.nameScript}' exists in '${scriptPath}'`)
    }

    const actions: Actions = []

    actions.push({
      type: 'add',
      templateFile: `${baseTemplatesPath}/scripts/test.add.hbs`,
      path: `${testPath}/${sanitize(answers.nameScript)}_test.go`
    })

    return actions
  }
}
