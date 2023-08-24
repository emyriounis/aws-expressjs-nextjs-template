import serverlessExpress from '@vendia/serverless-express'
import app from './app'

let serverlessExpressInstance: any

// function asyncTask() {
//   return new Promise((resolve) => {
//     setTimeout(() => resolve('connected to database'), 1000)
//   })
// }

const setup = async (event: any, context: any) => {
  // const asyncValue = await asyncTask()
  // console.log(asyncValue)
  serverlessExpressInstance = serverlessExpress({ app })
  return serverlessExpressInstance(event, context)
}

export const handler = (event: any, context: any) => {
  if (serverlessExpressInstance)
    return serverlessExpressInstance(event, context)

  return setup(event, context)
}
