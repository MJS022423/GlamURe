import React from "react";
import "../style/load.css"; // Assuming you have a CSS file for styling

function LoadingScreen() {
  const bars = Array.from({ length: 10 }); // creates 10 bars dynamically

  return (
    <div className="spectrum-container">
      <div className="spectrum">
        {bars.map((_, i) => (
          <div key={i} className="bar" style={{ animationDelay: `${i * 0.1}s` }}></div>
        ))}
      </div>
      
    </div>
  );
}

export default LoadingScreen;
