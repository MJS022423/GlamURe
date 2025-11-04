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
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const navigate = useNavigate();
  

  // Simulate loading screen
  useEffect(() => {
    const timer = setTimeout(() => {
      setLoading(false);
      if (!isLoggedIn) navigate("/landing"); // 👈 after loading, go to landing page
    }, 3000);

    return () => clearTimeout(timer);
  }, []);

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
      <Route path="/" element={<Navigate to="/landing" />} />

      {/* Start page (Landing) */}
      <Route path="/landing" element={<Startpage />} />

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
      <Route path="*" element={<Navigate to="/landing" />} />
    </Routes>
  );
}
