/**
 * List Tasks Lambda Handler
 * Endpoint: GET /tasks
 * Requires: Cognito JWT token with userId claim
 */

import { listTasks } from "../shared/taskService";
import type { Task } from "../shared/taskService";

interface APIGatewayEvent {
  requestContext: {
    authorizer: {
      claims: {
        sub: string; // Cognito userId
        email: string;
      };
    };
  };
}

interface APIGatewayResponse {
  statusCode: number;
  body: string;
  headers: Record<string, string>;
}

export const handler = async (event: APIGatewayEvent): Promise<APIGatewayResponse> => {
  try {
    console.log("ListTasks handler invoked:", event);

    // Extract userId from Cognito token
    const userId = event.requestContext.authorizer.claims.sub;

    if (!userId) {
      return {
        statusCode: 401,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Unauthorized: Missing userId" }),
      };
    }

    const tasks: Task[] = await listTasks(userId);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(tasks),
    };
  } catch (error) {
    console.error("ListTasks error:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "Internal Server Error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
    };
  }
};

