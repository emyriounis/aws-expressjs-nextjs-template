import serverlessExpress from '@vendia/serverless-express'
import app from './app'

let serverlessExpressInstance: any

const setup = async (event: any, context: any) => {
  serverlessExpressInstance = serverlessExpress({ app })
  return serverlessExpressInstance(event, context)
}

export const handler = (event: any, context: any) => {
  if (serverlessExpressInstance)
    return serverlessExpressInstance(event, context)

  return setup(event, context)
}
