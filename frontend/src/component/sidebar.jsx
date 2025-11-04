import React, { useState } from "react";
import home from "../assets/home.svg";
import bookmark from "../assets/bookmark.svg";
import profile from "../assets/profile.svg";
import settings from "../assets/settings.svg";
import info from "../assets/info.svg";
import logout from "../assets/logout.svg";

const Sidebar = ({ onLogout, onExpand = () => {} }) => {
  const [activeMenu, setActiveMenu] = useState("Home");
  const [isExpanded, setIsExpanded] = useState(false);

  const menuItems = [
    { name: "Home", icon: home },
    { name: "Bookmark", icon: bookmark },
    { name: "Profile", icon: profile },
    { name: "Settings", icon: settings },
    { name: "About Us", icon: info },
  ];

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
            <h3 className="text-lg font-semibold">NAME</h3>
            <p className="text-gray-400 text-sm font-medium">Designer</p>
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
            <button
              onClick={() => setActiveMenu(item.name)}
              className={`flex items-center w-full py-3 rounded-xl transition-all duration-200 ${
                isExpanded ? "justify-start gap-4 px-2" : "justify-center"
              } ${
                activeMenu === item.name
                  ? "bg-pink-500 text-black font-semibold"
                  : "hover:bg-gray-700"
              }`}
            >
              <img
                src={item.icon}
                alt={item.name}
                className={`w-6 h-6 ${
                  activeMenu === item.name
                    ? "filter-none"
                    : "filter brightness-0 invert"
                }`}
              />
              {isExpanded && (
                <span className="text-base whitespace-nowrap">{item.name}</span>
              )}
            </button>
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
