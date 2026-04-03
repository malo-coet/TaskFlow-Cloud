/**
 * Health Check Lambda Handler
 * Endpoint: GET /taskflow-health-check
 * Response: { status: "ok" }
 */

export const handler = async (event) => {
  console.log('Health check request:', event);

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({
      status: 'ok',
      timestamp: new Date().toISOString(),
      region: process.env.AWS_REGION || 'unknown',
    }),
  };
};
