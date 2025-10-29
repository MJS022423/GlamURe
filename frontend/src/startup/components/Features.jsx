import React from "react";
import "../designs/Features.css";

const Features = () => {
  return (
    <section id="features" className="features">
      <h2>Platform Highlights</h2>
      <div className="feature-grid">
        <div className="feature-card">
          <h3>🏆 Ranking / Leaderboard</h3>
          <p>
            Discover top designs based on likes and track the top designers
            dominating the charts.
          </p>
        </div>
        <div className="feature-card">
          <h3>💬 Messages</h3>
          <p>
            Connect with other designers or recruiters through private messages.
          </p>
        </div>
        <div className="feature-card">
          <h3>💼 Applying / Hiring</h3>
          <p>
            Designers can apply to job posts, while recruiters can find and
            message talents directly.
          </p>
        </div>
        <div className="feature-card">
          <h3>👗 Design Categories</h3>
          <p>Explore designs by category: Men's or Women's Apparel.</p>
        </div>
        <div className="feature-card">
          <h3>📌 Bookmark Design</h3>
          <p>Save your favorite designs for future inspiration and reference.</p>
        </div>
      </div>
    </section>
  );
};

export default Features;
