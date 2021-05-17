import { Actions, PlopGeneratorConfig } from 'node-plop'
import * as path from 'path'
import { ValidatePrompNames, AnswersValidate as Answers } from './entities'
import { baseRootPath, baseTemplatesPath, pathExists } from '../utils'
import { sanitize } from '../helpers'
const testPath = path.join(baseRootPath, 'test')

export const validateGenerator: PlopGeneratorConfig = {
  description: 'add an test validate',
  prompts: [
    {
      type: 'input',
      name: ValidatePrompNames.name,
      message: 'What should it be program to validate?',
      default: 'terraform'
    }
  ],
  actions: (data) => {
    const answers = data as Answers
    const testValidatePath = `${testPath}/validate/`

    if (!pathExists(testValidatePath)) {
      throw new Error(`Stage '${answers.nameValidate}' exists in '${testValidatePath}'`)
    }

    const actions: Actions = []

    actions.push({
      type: 'add',
      templateFile: `${baseTemplatesPath}/validate/test.add.hbs`,
      path: `${testValidatePath}/${sanitize(answers.nameValidate)}_test.go`
    })

    return actions
  }
}
