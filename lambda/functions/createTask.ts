/**
 * Create Task Lambda Handler
 * Endpoint: POST /tasks
 * Requires: Cognito JWT token with userId claim
 * Body: { title: string, description?: string, dueDate?: string, tags?: string[] }
 */

import { createTask } from "../shared/taskService";
import type { Task, CreateTaskInput } from "../shared/taskService";

interface APIGatewayEvent {
  body: string | null;
  requestContext: {
    authorizer: {
      jwt?: {
        claims?: Record<string, string>;
      };
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
    console.log("CreateTask handler invoked:", event);

    // Extract userId from Cognito token
    const claims = event.requestContext.authorizer?.jwt?.claims ?? event.requestContext.authorizer?.claims;
    const userId = claims?.sub;

    if (!userId) {
      return {
        statusCode: 401,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Unauthorized: Missing userId" }),
      };
    }

    // Parse request body
    const body = event.body ? JSON.parse(event.body) : {};
    const { title, description, dueDate, tags } = body;

    if (!title || typeof title !== "string" || title.trim().length === 0) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Invalid request: title is required and must be a non-empty string" }),
      };
    }

    const input: CreateTaskInput = {
      userId,
      title: title.trim(),
      description: description?.trim() || "",
      dueDate,
      tags: Array.isArray(tags) ? tags : [],
    };

    const task: Task = await createTask(input);

    return {
      statusCode: 201,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(task),
    };
  } catch (error) {
    console.error("CreateTask error:", error);
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

