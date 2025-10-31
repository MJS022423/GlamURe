// src/startup/components/Header.jsx
import React from "react";
import { useNavigate } from "react-router-dom";
import "../designs/Header.css";
import file from "../../assets/file.svg";

const Header = ({activeSection ,setActiveSection}) => {
  const navigate = useNavigate();

  return (
    <header className="header">
      <div className="logo" onClick={() => setActiveSection("home")}>
        <img src={file} className="icon" alt="Logo" />
      </div>

      <nav className="nav">
        <button
          onClick={() => setActiveSection("features")}
          className={activeSection === "features" ? "active" : ""}
        >
          Features
        </button>
        <button
          onClick={() => setActiveSection("category")}
          className={activeSection === "category" ? "active" : ""}
        >
          Categories
        </button>
        <button
          onClick={() => setActiveSection("about")}
          className={activeSection === "about" ? "active" : ""}
        >
          About
        </button>
      </nav>

      <div className="auth-buttons">
        <button className="login-btn" onClick={() => navigate("/login")}>
          Login
        </button>
        <button className="signup-btn" onClick={() => navigate("/login")}>
          Sign Up
        </button>
      </div>
    </header>
  );
};

export default Header;
