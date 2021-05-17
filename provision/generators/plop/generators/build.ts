import { Actions, PlopGeneratorConfig } from 'node-plop'
import * as path from 'path'
import { BuildPrompNames, AnswersBuild as Answers } from './entities'
import { baseRootPath, baseTemplatesPath, pathExists } from '../utils'
const testPath = path.join(baseRootPath, 'test', 'build')

export const buildGenerator: PlopGeneratorConfig = {
  description: 'add a test build',
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

    if (!pathExists(testPath)) {
      throw new Error(`path '${answers.nameBuild}' not exists in '${testPath}'`)
    }

    const actions: Actions = []

    actions.push({
      type: 'append',
      templateFile: `${baseTemplatesPath}/build/test.append.hbs`,
      path: `${testPath}/docker_test.go`,
      abortOnFail: true
    })

    return actions
  }
}
