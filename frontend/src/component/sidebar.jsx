import React, { useState } from "react";
import { NavLink, useLocation } from "react-router-dom";

import home from "../assets/home.svg";
import bookmark from "../assets/bookmark.svg";
import profile from "../assets/profile.svg";
import settings from "../assets/settings.svg";
import info from "../assets/info.svg";
import logout from "../assets/logout.svg";

const profileName = localStorage.getItem("profile_name");  
const profileTitle = localStorage.getItem("userRole"); 

const Sidebar = ({ onLogout, onExpand = () => {} }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const location = useLocation();

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
        <div className="w-14 h-14 rounded-full bg-green-600 mb-2"></div>
        {isExpanded && (
          <>
            <h3 className="text-lg font-semibold">{profileName}</h3>
            <p className="text-gray-400 text-sm font-medium">{profileTitle}</p>
            <div className="w-2/3 border-b border-gray-500 mt-2"></div>
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
                      isNavActive || isActive(item.path)
                        ? "filter-none"
                        : "filter brightness-0 invert"
                    }`}
                  />
                  {isExpanded && (
                    <span className="text-base whitespace-nowrap">{item.name}</span>
                  )}
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
          <img
            src={logout}
            alt="Logout"
            className="w-6 h-6 filter brightness-0 invert"
          />
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
