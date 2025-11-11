import React, { useState } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import Sidebar from "./sidebar";
import Homepage from "../dash-component/homepage-modules/homepage";
import Bookmark from "../dash-component/bookmark";
import Profilepage from "../dash-component/profilepage";
import Settings from "../dash-component/settings";
import AboutPage from "../dash-component/aboutpage";

function Dashboard({ goLogout }) {
  const [isSidebarExpanded, setIsSidebarExpanded] = useState(false);
  const [showLogoutPopup, setShowLogoutPopup] = useState(false);

  return (
    <div className="h-screen w-full bg-gray-100 flex relative items-center justify-center">
      <Sidebar
        onLogout={() => setShowLogoutPopup(true)}
        onExpand={setIsSidebarExpanded}
      />

      <main
        className={`
          bg-transparent border-2 border-solid border-gray-900 rounded-2xl p-6 text-white
          transition-all duration-300 ease-in-out overflow-auto no-scrollbar
        `}
        style={{
          height: "95vh",
          
          // ✅ keep consistent gap between sidebar and main (both collapsed & expanded)
          marginLeft: isSidebarExpanded ? "20rem" : "8rem",
          marginRight: "1.5rem",
          // ✅ adjust width so it doesn't overflow and keeps symmetry
          width: isSidebarExpanded
            ? "calc(100% - 21.5rem)"
            : "calc(100% - 9.5rem)",
        }}
      >
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard/home" replace />} />
          <Route path="/home" element={<Homepage />} />
          <Route path="/bookmark" element={<Bookmark />} />
          <Route path="/profile" element={<Profilepage />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/about" element={<AboutPage />} />
          <Route path="*" element={<Navigate to="/dashboard/home" replace />} />
        </Routes>

        {/* Logout Confirmation Popup */}
        {showLogoutPopup && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-lg shadow-lg text-center">
              <h2 className="text-lg font-semibold mb-4">Are you sure you want to logout?</h2>
              <div className="flex justify-center gap-4">
                <button
                  onClick={() => {
                    setShowLogoutPopup(false);
                    goLogout();
                  }}
                  className="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
                >
                  Yes, Logout
                </button>
                <button
                  onClick={() => setShowLogoutPopup(false)}
                  className="bg-gray-300 text-black px-4 py-2 rounded hover:bg-gray-400"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}
        <style jsx>{`
        .no-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .no-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
      </main>
    </div>
  );
}

export default Dashboard;
