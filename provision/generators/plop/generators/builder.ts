import { Actions, PlopGeneratorConfig } from 'node-plop'
import * as path from 'path'
import { BuilderPrompNames, AnswersBuilder as Answers } from './entities'
import { baseRootPath, baseTemplatesPath, pathExists } from '../utils'
const testPath = path.join(baseRootPath, 'test', 'builder')

export const builderGenerator: PlopGeneratorConfig = {
  description: 'add a test builder',
  prompts: [
    {
      type: 'input',
      name: BuilderPrompNames.name,
      message: 'What should it be name builder?',
      default: 'docker'
    }
  ],
  actions: (data) => {
    const answers = data as Answers

    if (!pathExists(testPath)) {
      throw new Error(`path '${answers.nameBuilder}' not exists in '${testPath}'`)
    }

    const actions: Actions = []

    actions.push({
      type: 'append',
      templateFile: `${baseTemplatesPath}/builder/test.append.hbs`,
      path: `${testPath}/docker_test.go`,
      abortOnFail: true
    })

    return actions
  }
}
