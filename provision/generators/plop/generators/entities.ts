export enum ValidatePrompNames {
  'name' = 'nameValidate'
}

export enum BuilderPrompNames {
  'name' = 'nameBuilder'
}

export enum ScriptsPrompNames {
  'name' = 'nameScript'
}

export type AnswersValidate = { [P in ValidatePrompNames]: string }
export type AnswersBuilder = { [P in BuilderPrompNames]: string }
export type AnswersScript = { [P in ScriptsPrompNames]: string }
