/**
 * Task Service — DynamoDB operations
 * Handles CRUD operations for tasks with proper error handling and logging
 */

import {
  DynamoDBClient,
  PutItemCommand,
  GetItemCommand,
  QueryCommand,
  UpdateItemCommand,
  DeleteItemCommand,
} from "@aws-sdk/client-dynamodb";
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb";

const dynamoDb = new DynamoDBClient({ region: process.env.AWS_REGION });
const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "TaskFlow-Tasks";

export interface Task {
  taskId: string;
  userId: string;
  title: string;
  description?: string;
  status: "TODO" | "IN_PROGRESS" | "DONE" | "CANCELLED";
  dueDate?: string;
  tags?: string[];
  createdAt: string;
  updatedAt: string;
}

export interface CreateTaskInput {
  userId: string;
  title: string;
  description?: string;
  dueDate?: string;
  tags?: string[];
}

export interface UpdateTaskInput {
  userId: string;
  taskId: string;
  title?: string;
  description?: string;
  status?: string;
  dueDate?: string;
  tags?: string[];
}

function generateTaskId(): string {
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0;
    const v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

export async function createTask(input: CreateTaskInput): Promise<Task> {
  const taskId = generateTaskId();
  const now = new Date().toISOString();

  const task: Task = {
    taskId,
    userId: input.userId,
    title: input.title,
    description: input.description || "",
    status: "TODO",
    dueDate: input.dueDate,
    tags: input.tags || [],
    createdAt: now,
    updatedAt: now,
  };

  const params = {
    TableName: TABLE_NAME,
    Item: marshall({
      PK: `USER#${input.userId}`,
      SK: `TASK#${taskId}`,
      ...task,
    }),
  };

  await dynamoDb.send(new PutItemCommand(params));
  return task;
}

export async function getTask(userId: string, taskId: string): Promise<Task | null> {
  const params = {
    TableName: TABLE_NAME,
    Key: marshall({
      PK: `USER#${userId}`,
      SK: `TASK#${taskId}`,
    }),
  };

  const result = await dynamoDb.send(new GetItemCommand(params));

  if (!result.Item) {
    return null;
  }

  const item = unmarshall(result.Item);
  return {
    taskId: item.taskId,
    userId: item.userId,
    title: item.title,
    description: item.description,
    status: item.status,
    dueDate: item.dueDate,
    tags: item.tags,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
  };
}

export async function listTasks(userId: string): Promise<Task[]> {
  const params = {
    TableName: TABLE_NAME,
    KeyConditionExpression: "PK = :pk AND begins_with(SK, :sk)",
    ExpressionAttributeValues: marshall({
      ":pk": `USER#${userId}`,
      ":sk": "TASK#",
    }),
  };

  const result = await dynamoDb.send(new QueryCommand(params));

  if (!result.Items) {
    return [];
  }

  return result.Items.map((item) => {
    const unmarshalled = unmarshall(item as any);
    return {
      taskId: unmarshalled.taskId,
      userId: unmarshalled.userId,
      title: unmarshalled.title,
      description: unmarshalled.description,
      status: unmarshalled.status,
      dueDate: unmarshalled.dueDate,
      tags: unmarshalled.tags,
      createdAt: unmarshalled.createdAt,
      updatedAt: unmarshalled.updatedAt,
    };
  });
}

export async function updateTask(input: UpdateTaskInput): Promise<Task> {
  const now = new Date().toISOString();
  const updates: string[] = [];
  const expressionAttributeValues: Record<string, unknown> = {
    ":updatedAt": now,
  };

  if (input.title !== undefined) {
    updates.push("title = :title");
    expressionAttributeValues[":title"] = input.title;
  }
  if (input.description !== undefined) {
    updates.push("description = :description");
    expressionAttributeValues[":description"] = input.description;
  }
  if (input.status !== undefined) {
    updates.push("status = :status");
    expressionAttributeValues[":status"] = input.status;
  }
  if (input.dueDate !== undefined) {
    updates.push("dueDate = :dueDate");
    expressionAttributeValues[":dueDate"] = input.dueDate;
  }
  if (input.tags !== undefined) {
    updates.push("tags = :tags");
    expressionAttributeValues[":tags"] = input.tags;
  }

  updates.push("updatedAt = :updatedAt");

  const params = {
    TableName: TABLE_NAME,
    Key: marshall({
      PK: `USER#${input.userId}`,
      SK: `TASK#${input.taskId}`,
    }),
    UpdateExpression: `SET ${updates.join(", ")}`,
    ExpressionAttributeValues: marshall(expressionAttributeValues),
    ReturnValues: "ALL_NEW" as const,
  };

  const result = await dynamoDb.send(new UpdateItemCommand(params));

  if (!result.Attributes) {
    throw new Error("Failed to update task");
  }

  const item = unmarshall(result.Attributes);
  return {
    taskId: item.taskId,
    userId: item.userId,
    title: item.title,
    description: item.description,
    status: item.status,
    dueDate: item.dueDate,
    tags: item.tags,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
  };
}

export async function deleteTask(userId: string, taskId: string): Promise<void> {
  const params = {
    TableName: TABLE_NAME,
    Key: marshall({
      PK: `USER#${userId}`,
      SK: `TASK#${taskId}`,
    }),
  };

  await dynamoDb.send(new DeleteItemCommand(params));
}

