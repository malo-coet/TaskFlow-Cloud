/**
 * API Service - TaskFlow
 * Centralise tous les appels aux Lambda functions
 */

const API_URL = import.meta.env.VITE_API_URL;

export interface HealthResponse {
  status: string;
  timestamp: string;
  region: string;
}

/**
 * Appeler l'endpoint /taskflow-health-check
 */
export async function checkHealth(): Promise<HealthResponse> {
  try {
    const response = await fetch(`${API_URL}/taskflow-health-check`);
    
    if (!response.ok) {
      throw new Error(`Health check failed: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Health check error:', error);
    throw error;
  }
}
