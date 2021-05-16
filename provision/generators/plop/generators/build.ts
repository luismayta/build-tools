import { Actions, PlopGeneratorConfig } from 'node-plop'
import * as path from 'path'
import { BuildPrompNames, AnswersBuild as Answers } from './entities'
import { baseRootPath, baseTemplatesPath, pathExists } from '../utils'
import { sanitize } from '../helpers'
const testPath = path.join(baseRootPath, 'test')

export const buildGenerator: PlopGeneratorConfig = {
  description: 'add an test build',
  prompts: [
    {
      type: 'input',
      name: BuildPrompNames.name,
      message: 'What should it be name build?',
      default: 'docker'
    }
  ],
  actions: (data) => {
    const answers = data as Answers
    const buildPath = `${testPath}/build}`

    if (!pathExists(buildPath)) {
      throw new Error(`Stage '${answers.nameBuild}' not exists in '${buildPath}'`)
    }

    const actions: Actions = []

    actions.push({
      type: 'append',
      templateFile: `${baseTemplatesPath}/image/test.append.hbs`,
      path: `${testPath}/docker_${sanitize(answers.nameBuild)}_test.go`,
      abortOnFail: true
    })

    return actions
  }
}
