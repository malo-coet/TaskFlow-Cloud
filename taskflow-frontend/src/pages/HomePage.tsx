import { useState, useEffect } from 'react';
import { checkHealth, type HealthResponse } from '../lib/api';

export default function HomePage() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleCheckHealth = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await checkHealth();
      setHealth(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Vérifier la santé au chargement
    handleCheckHealth();
  }, []);

  return (
    <div className="fade-in max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <section className="text-center mb-16">
        <h1 className="text-5xl font-bold text-gray-900 mb-4">Welcome to TaskFlow</h1>
        <p className="text-xl text-gray-600 mb-8">Your serverless task management application</p>
      </section>

      <section className="bg-white rounded-lg shadow p-8 mb-16">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Backend Status</h2>
        
        {loading && <p className="text-blue-600">Checking backend...</p>}
        
        {error && (
          <div className="bg-red-100 text-red-700 p-4 rounded mb-4">
            ❌ Error: {error}
          </div>
        )}
        
        {health && (
          <div className="bg-green-100 text-green-700 p-4 rounded mb-4">
            ✅ Status: {health.status}
            <p className="text-sm mt-2">Region: {health.region}</p>
            <p className="text-sm">Time: {new Date(health.timestamp).toLocaleString()}</p>
          </div>
        )}
        
        <button
          onClick={handleCheckHealth}
          disabled={loading}
          className="w-full bg-indigo-600 text-white py-2 rounded hover:bg-indigo-700 disabled:bg-gray-400"
        >
          {loading ? 'Checking...' : 'Check Backend'}
        </button>
      </section>
    </div>
  );
}
