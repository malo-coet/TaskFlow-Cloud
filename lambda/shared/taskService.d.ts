/**
 * Task Service — DynamoDB operations
 * Handles CRUD operations for tasks with proper error handling and logging
 */
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
export declare function createTask(input: CreateTaskInput): Promise<Task>;
export declare function getTask(userId: string, taskId: string): Promise<Task | null>;
export declare function listTasks(userId: string): Promise<Task[]>;
export declare function updateTask(input: UpdateTaskInput): Promise<Task>;
export declare function deleteTask(userId: string, taskId: string): Promise<void>;
//# sourceMappingURL=taskService.d.ts.map