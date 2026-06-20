import serverlessExpress from '@vendia/serverless-express';
import app from './app';
import { APIGatewayProxyEvent, Context, Handler } from 'aws-lambda';

let serverlessExpressInstance: Handler;

const setup = async (event: APIGatewayProxyEvent, context: Context) => {
  serverlessExpressInstance = serverlessExpress({ app });
  return serverlessExpressInstance(event, context, () => {});
};

export const handler = (event: APIGatewayProxyEvent, context: Context) => {
  if (serverlessExpressInstance) return serverlessExpressInstance(event, context, () => {});

  return setup(event, context);
};
