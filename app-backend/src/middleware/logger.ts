import { Request, Response, NextFunction } from 'express';

export function requestLogger(req: Request, res: Response, next: NextFunction): void {
  const start = Date.now();
  const ts = new Date().toISOString();
  const ip = req.headers['x-forwarded-for'] ?? req.socket.remoteAddress ?? '-';

  res.on('finish', () => {
    const ms = Date.now() - start;
    console.log(`[${ts}] ${req.method} ${req.path} ${res.statusCode} ${ms}ms ip=${ip}`);
  });

  next();
}
