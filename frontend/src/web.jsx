// src/App.jsx
import React, { useState, useEffect } from "react";
import LoadingScreen from "./component/loading";
import Login from "./component/login";

export default function Web() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 3000);
    return () => clearTimeout(timer);
  }, []);

  return (
    <>
      {loading ? <LoadingScreen /> : <Login />}
    </>
  );
}
