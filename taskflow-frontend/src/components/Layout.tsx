import { Outlet } from 'react-router-dom';
import Header from './Header';
import Footer from './Footer';
import '../App.css';
export default function Layout() {
  return (
    <div className="app-container">
      <Header />
      <main className="app-content">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
