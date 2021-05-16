export enum ValidatePrompNames {
  'name' = 'nameValidate'
}

export enum BuildPrompNames {
  'name' = 'nameBuild'
}

export enum ScriptsPrompNames {
  'name' = 'nameScript'
}

export type AnswersValidate = { [P in ValidatePrompNames]: string }
export type AnswersBuild = { [P in BuildPrompNames]: string }
export type AnswersScript = { [P in ScriptsPrompNames]: string }
