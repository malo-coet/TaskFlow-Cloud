/**
 * Delete Task Lambda Handler
 * Endpoint: DELETE /tasks/{taskId}
 * Requires: Cognito JWT token with userId claim
 */

import { deleteTask } from "../shared/taskService";

interface APIGatewayEvent {
  pathParameters: {
    taskId: string;
  };
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
    console.log("DeleteTask handler invoked:", event);

    // Extract userId from Cognito token
    const userId = event.requestContext.authorizer.claims.sub;

    if (!userId) {
      return {
        statusCode: 401,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Unauthorized: Missing userId" }),
      };
    }

    const taskId = event.pathParameters?.taskId;

    if (!taskId) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Invalid request: taskId is required" }),
      };
    }

    await deleteTask(userId, taskId);

    return {
      statusCode: 204,
      headers: { "Content-Type": "application/json" },
      body: "",
    };
  } catch (error) {
    console.error("DeleteTask error:", error);

    if (error instanceof Error && error.message.includes("not found")) {
      return {
        statusCode: 404,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Task not found" }),
      };
    }

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

