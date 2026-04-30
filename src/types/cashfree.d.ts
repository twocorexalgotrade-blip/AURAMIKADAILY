declare module '@cashfreepayments/cashfree-js' {
  export function load(config: { mode: 'sandbox' | 'production' }): Promise<{
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    checkout: (options: Record<string, unknown>) => Promise<any>;
  }>;
}
