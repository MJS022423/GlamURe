import React from "react";
import "../designs/Categories.css";

const Categories = () => {
  return (
    <section className="categories">
      <h2>Fashion Categories</h2>
      <div className="category-grid">
        <div className="category-card">👗 Women's Wear</div>
        <div className="category-card">👔 Men's Wear</div>
        <div className="category-card">👜 Accessories</div>
        <div className="category-card">👟 Footwear</div>
        <div className="category-card">🌿 Sustainable Fashion</div>
        <div className="category-card">👶 Children's Fashion</div>
      </div>
    </section>
  );
};

export default Categories;
