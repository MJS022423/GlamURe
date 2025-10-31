// src/component/dashboard.jsx
import React, { useState } from "react";
import Sidebar from "./sidebar";
import Header from "./header";
import "../style/dashboard.css";

function Dashboard({ goLogout }) {
  const [showLogoutPopup, setShowLogoutPopup] = useState(false);

  return (
    <div className="dashboard-container">
      <Header />
      <div className="main-layout">
        <div className="leftside">
          <Sidebar onLogout={() => setShowLogoutPopup(true)} />
        </div>

        <main>
          {/* Place page content here */}
          <h2>Welcome to your Dashboard!</h2>
        </main>

        <aside></aside>
      </div>

      {/* Logout Confirmation Popup */}
      {showLogoutPopup && (
        <div className="logout-popup">
          <div className="popup-box">
            <p>Are you sure you want to log out?</p>
            <div className="popup-actions">
              <button
                onClick={() => {
                  goLogout(); // clears login state in Web.jsx
                  setShowLogoutPopup(false);
                }}
                className="confirm-btn"
              >
                Yes
              </button>
              <button
                onClick={() => setShowLogoutPopup(false)}
                className="cancel-btn"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Dashboard;
