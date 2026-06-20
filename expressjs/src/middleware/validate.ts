import { Request, Response, NextFunction } from 'express';
import { ZodTypeAny, ZodError } from 'zod';
import { asyncHandler } from '../utils/asyncHandler';

export interface ValidationSchema {
  body?: ZodTypeAny;
  query?: ZodTypeAny;
  params?: ZodTypeAny;
  response?: ZodTypeAny;
}

/**
 * Middleware that validates request and response data against Zod schemas.
 *
 * If request validation fails, it throws a 400 Bad Request response automatically.
 * If response validation fails, it throws a 500 Internal Server Error automatically.
 */
export const validate = (schema: ValidationSchema) => {
  return asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    // 1. Validate Request Data
    try {
      if (schema.body) {
        req.body = await schema.body.parseAsync(req.body);
      }
      if (schema.query) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        req.query = (await schema.query.parseAsync(req.query)) as any;
      }
      if (schema.params) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        req.params = (await schema.params.parseAsync(req.params)) as any;
      }
    } catch (error) {
      if (error instanceof ZodError) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const zodError = error as ZodError<any>;
        res.status(400).json({
          message: 'Invalid request data',
          errors: zodError.issues,
        });
        return;
      }
      throw error;
    }

    // 2. Validate Response Data (Intercept res.json)
    if (schema.response) {
      const originalJson = res.json.bind(res);

      res.json = (body: unknown): Response => {
        try {
          const parsedBody = schema.response!.parse(body);
          return originalJson(parsedBody);
        } catch (error) {
          if (error instanceof ZodError) {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const zodError = error as ZodError<any>;
            console.error('Response Validation Error:', zodError.issues);
            res.status(500);
            return originalJson({
              message: 'Internal Server Error: Response validation failed',
            });
          }
          console.error('Unknown response validation error:', error);
          res.status(500);
          return originalJson({ message: 'Internal Server Error' });
        }
      };
    }

    next();
  });
};
