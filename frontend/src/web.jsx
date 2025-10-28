// src/web.jsx
import React, { useState, useEffect } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import LoadingScreen from "./component/loading";
import Login from "./component/login";
import Dashboard from "./component/dashboard";

export default function Web() {
  const [loading, setLoading] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  // Simulate loading screen
  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 3000);
    return () => clearTimeout(timer);
  }, []);

  if (loading) return <LoadingScreen />;

  return (
    <Routes>
      {/* Default route (Login) */}
      <Route
        path="/"
        element={
          isLoggedIn ? (
            <Navigate to="/dashboard" />
          ) : (
            <Login onLoginSuccess={() => setIsLoggedIn(true)} />
          )
        }
      />

      {/* Dashboard route */}
      <Route
        path="/dashboard"
        element={
          isLoggedIn ? (
            <Dashboard goLogout={() => setIsLoggedIn(false)} />
          ) : (
            <Navigate to="/" />
          )
        }
      />

      {/* If user enters an invalid URL */}
      <Route path="*" element={<Navigate to="/" />} />
    </Routes>
  );
}
