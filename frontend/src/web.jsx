// src/web.jsx
import React, { useState, useEffect } from "react";
import { Routes, Route, Navigate, useNavigate } from "react-router-dom";
import LoadingScreen from "./component/loading";
import Login from "./component/login";
import Dashboard from "./component/dashboard";
import Startpage from "./startup/startpage";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

export default function Web() {
  const [loading, setLoading] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false); // Set initial state to false
  const navigate = useNavigate();
  
  // Handle initial loading screen only
  useEffect(() => {
    const timer = setTimeout(() => {
      setLoading(false);
    }, 3000); // Reduced to 3 seconds for better UX

    return () => clearTimeout(timer);
<<<<<<< HEAD
  }, []);
=======
  }, []); // Only run once on component mount

  // Separate effect for handling initial auth state
  useEffect(() => {
    if (!loading && !isLoggedIn && window.location.pathname === '/') {
      navigate('/main');
    }
  }, [loading, isLoggedIn, navigate]);
>>>>>>> 50dac15264a6c27c09d9a8503455026a48cc2506

  useEffect(() => {
    const checkServer = async () => {
      try {
        const res = await fetch(`${EXPRESS_API}/status`);
        if (res.ok) {
          setLoading(false);
        } else {
          setTimeout(checkServer, 200); 
        }
      } catch {
        setTimeout(checkServer, 200); 
      }
    };

    checkServer();
  }, []);
  if (loading) return <LoadingScreen />;

  return (
    <Routes>
      {/* Default route */}
      <Route path="/" element={<Navigate to="/main" />} />

      {/* Start page (Landing) */}
      <Route path="/main" element={<Startpage />} />

      {/* Login page */}
      <Route
        path="/login"
        element={
          isLoggedIn ? (
            <Navigate to="/dashboard" />
          ) : (
            <Login onLoginSuccess={() => setIsLoggedIn(true)} />
          )
        }
      />

      {/* Dashboard (Protected Route) */}
      <Route
        path="/dashboard"
        element={
          isLoggedIn ? (
            <Dashboard goLogout={() => setIsLoggedIn(false)} />
          ) : (
            <Navigate to="/login" />
          )
        }
      />

      {/* Catch-all invalid URLs */}
      <Route path="*" element={<Navigate to="/main" />} />
    </Routes>
  );
}
