/**
 * Update Task Lambda Handler
 * Endpoint: PUT /tasks/{taskId}
 * Requires: Cognito JWT token with userId claim
 * Body: { title?: string, description?: string, status?: string, dueDate?: string, tags?: string[] }
 */

import { updateTask } from "../shared/taskService";
import type { Task, UpdateTaskInput } from "../shared/taskService";

interface APIGatewayEvent {
  pathParameters: {
    taskId: string;
  };
  body: string | null;
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
    console.log("UpdateTask handler invoked:", event);

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

    // Parse request body
    const body = event.body ? JSON.parse(event.body) : {};
    const { title, description, status, dueDate, tags } = body;

    // Validate status if provided
    const validStatuses = ["TODO", "IN_PROGRESS", "DONE", "CANCELLED"];
    if (status && !validStatuses.includes(status)) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          error: "Invalid status. Must be one of: TODO, IN_PROGRESS, DONE, CANCELLED",
        }),
      };
    }

    const input: UpdateTaskInput = {
      userId,
      taskId,
      title: title?.trim(),
      description: description?.trim(),
      status,
      dueDate,
      tags: Array.isArray(tags) ? tags : undefined,
    };

    const task: Task = await updateTask(input);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(task),
    };
  } catch (error) {
    console.error("UpdateTask error:", error);

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

