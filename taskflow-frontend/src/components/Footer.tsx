export default function Footer() {
  const currentYear = new Date().getFullYear();
  return (
    <footer className="bg-gray-800 text-white mt-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="text-center">
          <h3 className="text-lg font-semibold mb-2">TaskFlow</h3>
          <p className="text-gray-400 mb-4">Your serverless task management solution</p>
          <p className="text-gray-500 text-sm">© {currentYear} TaskFlow. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
