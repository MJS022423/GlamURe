import React, { useEffect, useState } from "react";
import { NavLink, useLocation } from "react-router-dom";

import home from "../assets/home.svg";
import bookmark from "../assets/bookmark.svg";
import profile from "../assets/profile.svg";
import settings from "../assets/settings.svg";
import info from "../assets/info.svg";
import logout from "../assets/logout.svg";

const Sidebar = ({ onLogout, onExpand = () => {} }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const location = useLocation();

  // Read profile values from localStorage inside the component so they update when changed.
  const [profileName, setProfileName] = useState(() => localStorage.getItem("profile_name") || "User");
  const [profileTitle, setProfileTitle] = useState(() => localStorage.getItem("userRole") || "");

  // update from localStorage when location changes (login often navigates)
  useEffect(() => {
    setProfileName(localStorage.getItem("profile_name") || "User");
    setProfileTitle(localStorage.getItem("userRole") || "");
  }, [location]);

  // listen for storage events (other tabs) to keep sidebar in sync
  useEffect(() => {
    const onStorage = (e) => {
      if (e.key === "profile_name") setProfileName(e.newValue || "User");
      if (e.key === "userRole") setProfileTitle(e.newValue || "");
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const menuItems = [
    { name: "Home", icon: home, path: "/dashboard/home" },
    { name: "Bookmark", icon: bookmark, path: "/dashboard/bookmark" },
    { name: "Profile", icon: profile, path: "/dashboard/profile" },
    { name: "Settings", icon: settings, path: "/dashboard/settings" },
    { name: "About Us", icon: info, path: "/dashboard/about" },
  ];

  // Check if current path matches a menu item (handle /dashboard as home)
  const isActive = (path) => {
    const currentPath = location.pathname;
    return currentPath === path || (currentPath === "/dashboard" && path === "/dashboard/home");
  };

  return (
    <aside
      className={`fixed left-6 top-1/2 -translate-y-1/2 bg-black text-white rounded-2xl shadow-2xl flex flex-col transition-all duration-300 ease-in-out z-50
      ${isExpanded ? "w-64" : "w-20"} h-[95vh]`}
      onMouseEnter={() => {
        setIsExpanded(true);
        onExpand(true);
      }}
      onMouseLeave={() => {
        setIsExpanded(false);
        onExpand(false);
      }}
    >
      {/* Profile Section */}
      <div className="flex flex-col items-center text-center py-4 flex-shrink-0">
        <div className="w-14 h-14 rounded-full bg-green-600 mb-2 overflow-hidden flex items-center justify-center">
          {/* if you later store avatar url in localStorage, you can render it here */}
          <img
            src={localStorage.getItem("profile_avatar") || ""}
            alt="avatar"
            className="w-full h-full object-cover"
            onError={(e) => {
              // hide broken image
              e.currentTarget.style.display = "none";
            }}
          />
          {/* fallback when there is no avatar */}
          {!localStorage.getItem("profile_avatar") && (
            <div className="w-full h-full flex items-center justify-center text-black font-bold">
              {profileName ? profileName.charAt(0).toUpperCase() : "U"}
            </div>
          )}
        </div>

        {isExpanded && (
          <>
            <h3 className="text-lg font-semibold truncate max-w-[12rem]">{profileName}</h3>
            <p className="text-gray-400 text-sm font-medium truncate max-w-[12rem]">{profileTitle}</p>
            <div className="w-2/3 border-b border-gray-500 mt-2" />
          </>
        )}
      </div>

      {/* Scrollable Center Menu */}
      <ul
        className={`flex flex-col items-center flex-1 gap-2 overflow-y-auto no-scrollbar py-2 transition-all duration-300 ${
          isExpanded ? "items-start px-4" : ""
        }`}
      >
        {menuItems.map((item) => (
          <li key={item.name} className="w-full">
            <NavLink
              to={item.path}
              className={({ isActive: isNavActive }) =>
                `flex items-center w-full py-3 rounded-xl transition-all duration-200 ${
                  isExpanded ? "justify-start gap-4 px-2" : "justify-center"
                } ${
                  isNavActive || isActive(item.path)
                    ? "bg-red-100 text-black font-semibold"
                    : "hover:bg-gray-700"
                }`
              }
            >
              {({ isActive: isNavActive }) => (
                <>
                  <img
                    src={item.icon}
                    alt={item.name}
                    className={`w-6 h-6 ${
                      isNavActive || isActive(item.path) ? "filter-none" : "filter brightness-0 invert"
                    }`}
                  />
                  {isExpanded && <span className="text-base whitespace-nowrap">{item.name}</span>}
                </>
              )}
            </NavLink>
          </li>
        ))}
      </ul>

      {/* Logout Button */}
      <div className="flex-shrink-0 pb-3">
        <button
          onClick={onLogout}
          className={`flex items-center w-full py-3 rounded-xl hover:bg-gray-700 transition-all duration-200 ${
            isExpanded ? "justify-start gap-4 px-4" : "justify-center"
          }`}
        >
          <img src={logout} alt="Logout" className="w-6 h-6 filter brightness-0 invert" />
          {isExpanded && <span className="text-base font-semibold">Logout</span>}
        </button>
      </div>

      {/* Hide scrollbar but keep scrollable */}
      <style jsx>{`
        .no-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .no-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </aside>
  );
};

export default Sidebar;
