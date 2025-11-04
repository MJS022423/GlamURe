import React, { useState } from "react";
import Sidebar from "./sidebar";

function Dashboard({ goLogout }) {
  const [isSidebarExpanded, setIsSidebarExpanded] = useState(false);

  return (
    <div className="h-screen w-full bg-gray-100 flex relative items-center justify-center">
      <Sidebar
        onLogout={goLogout}
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
          // ✅ adjust width so it doesn’t overflow and keeps symmetry
          width: isSidebarExpanded
            ? "calc(100% - 21.5rem)"
            : "calc(100% - 9.5rem)",
        }}
      >
        <h1 className="text-2xl font-semibold">
          Welcome to your Dashboard!
        </h1>
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
