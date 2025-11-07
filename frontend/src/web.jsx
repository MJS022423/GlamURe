// src/web.jsx
import React, { useState, useEffect } from "react";
import { Routes, Route, Navigate, useNavigate } from "react-router-dom";
import LoadingScreen from "./component/loading";
import Login from "./component/login";
import Dashboard from "./component/dashboard";
import Startpage from "./startup/startpage";
import SetupAccount from "./component/setupAccount";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

export default function Web() {
  const [loading, setLoading] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(true);
  const navigate = useNavigate();
  
  // Check server status on mount
  useEffect(() => {
    let attempts = 0;
    const maxAttempts = 3;

    const checkServer = async () => {
      try {
        if (!EXPRESS_API) {
          console.error('VITE_EXPRESS_API environment variable is not set');
          setLoading(false);
          return;
        }

        const res = await fetch(`${EXPRESS_API}/status`);
        if (res.ok) {
          setLoading(false);
        } else {
          attempts++;
          if (attempts < maxAttempts) {
            setTimeout(checkServer, 1000);
          } else {
            console.error('Server not responding after multiple attempts');
            setLoading(false);
          }
        }
      } catch (error) {
        console.error('Error connecting to server:', error);
        attempts++;
        if (attempts < maxAttempts) {
          setTimeout(checkServer, 1000);
        } else {
          setLoading(false);
        }
      }
    };

    checkServer();
  }, []);

  // Handle navigation when not logged in and on root path
  useEffect(() => {
    if (!loading && !isLoggedIn && window.location.pathname === '/') {
      navigate('/main');
    }
  }, [loading, isLoggedIn, navigate]);
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

      {/* Setup Account page */}
      <Route
        path="/setupAccount"
        element={<SetupAccount />}
      />

      {/* Dashboard (Protected Route) */}
      <Route
        path="/dashboard"
        element={
          isLoggedIn ? (
            <Navigate to="/dashboard/home" replace />
          ) : (
            <Navigate to="/login" />
          )
        }
      />
      <Route
        path="/dashboard/*"
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
