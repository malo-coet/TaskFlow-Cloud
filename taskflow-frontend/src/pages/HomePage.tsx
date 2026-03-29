import { useState } from 'react';

export default function HomePage() {
  const [count, setCount] = useState(0);

  return (
    <div className="fade-in max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <section className="text-center mb-16">
        <h1 className="text-5xl font-bold text-gray-900 mb-4">Welcome to TaskFlow</h1>
        <p className="text-xl text-gray-600 mb-8">Your serverless task management application</p>
      </section>

      <section className="bg-white rounded-lg shadow p-8 mb-16">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Interactive Counter</h2>
        <div className="text-center">
          <p className="text-6xl font-bold text-blue-600 mb-4">{count}</p>
          <div className="flex gap-4 justify-center">
            <button
              onClick={() => setCount(count - 1)}
              className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
            >
              Decrease
            </button>
            <button
              onClick={() => setCount(count + 1)}
              className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
            >
              Increase
            </button>
            <button
              onClick={() => setCount(0)}
              className="px-4 py-2 bg-gray-400 text-white rounded hover:bg-gray-500"
            >
              Reset
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}
