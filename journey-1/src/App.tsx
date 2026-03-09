import './App.css'
import Header from './components/layout/Header'
import { Footer } from './components/layout/Footer'
import LandingPage from './pages/LandingPage'
import UploadPage from './pages/UploadPage'
import SuccessPage from './pages/SuccessPage'
import { BrowserRouter, Routes, Route } from 'react-router-dom'


import { useEffect } from 'react';
import { themeConfig } from './config/themeConfig';

function App() {
  useEffect(() => {
    const root = document.documentElement;
    root.style.setProperty('--primary-color', themeConfig.colors.primary);
    root.style.setProperty('--primary-hover', themeConfig.colors.primaryHover);
    root.style.setProperty('--secondary-color', themeConfig.colors.secondary);
    root.style.setProperty('--text-primary', themeConfig.colors.textPrimary);
    root.style.setProperty('--text-secondary', themeConfig.colors.textSecondary);
    root.style.setProperty('--bg-color', themeConfig.colors.bg);
    root.style.setProperty('--surface-color', themeConfig.colors.surface);
    root.style.setProperty('--success-color', themeConfig.colors.success);
    root.style.setProperty('--error-color', themeConfig.colors.error);
  }, []);

  return (
    <div className="app-container">
      <BrowserRouter>
        <Header />
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/upload" element={<UploadPage />} />
          <Route path="/success" element={<SuccessPage />} />
        </Routes>
        <Footer />
      </BrowserRouter>
    </div>
  )
}

export default App