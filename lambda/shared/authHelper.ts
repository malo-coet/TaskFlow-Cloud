import { APIGatewayProxyEventV2 } from "aws-lambda";
import { decode } from "jsonwebtoken";

export interface JWTPayload {
  sub: string;        // User ID (Cognito)
  email: string;
  email_verified: boolean;
  iss: string;        // Issuer (Cognito)
  aud: string;        // Audience (App Client ID)
  iat: number;        // Issued at
  exp: number;        // Expiration
  [key: string]: any;
}

/**
 * Extract userId from JWT Authorization header
 * @param event API Gateway v2 event
 * @returns User ID (Cognito sub claim)
 */
export function extractUserIdFromJWT(event: APIGatewayProxyEventV2): string {
  const authHeader = event.headers?.authorization;
  
  if (!authHeader) {
    throw new Error("Missing Authorization header");
  }

  // Extract token from "Bearer <token>"
  const token = authHeader.split(" ")[1];
  if (!token) {
    throw new Error("Invalid Authorization header format");
  }

  // Decode without verification (already validated by API Gateway authorizer)
  // For production, verify signature with Cognito public key
  const payload = decode(token, { complete: false }) as JWTPayload | null;
  
  if (!payload || !payload.sub) {
    throw new Error("Invalid JWT or missing sub claim");
  }

  return payload.sub;
}

/**
 * Get email from JWT
 */
export function getEmailFromJWT(event: APIGatewayProxyEventV2): string {
  const authHeader = event.headers?.authorization;
  if (!authHeader) {
    throw new Error("Missing Authorization header");
  }

  const token = authHeader.split(" ")[1];
  const payload = decode(token, { complete: false }) as JWTPayload | null;
  
  if (!payload || !payload.email) {
    throw new Error("Invalid JWT or missing email claim");
  }

  return payload.email;
}

/**
 * Full JWT payload
 */
export function getJWTPayload(event: APIGatewayProxyEventV2): JWTPayload {
  const authHeader = event.headers?.authorization;
  if (!authHeader) {
    throw new Error("Missing Authorization header");
  }

  const token = authHeader.split(" ")[1];
  const payload = decode(token, { complete: false }) as JWTPayload | null;
  
  if (!payload) {
    throw new Error("Invalid JWT");
  }

  return payload;
}

