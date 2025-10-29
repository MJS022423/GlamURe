import React from "react";
import "../designs/Hero.css";

const Hero = () => {
  return (
    <section className="hero">
      <div className="hero-text">
        <h1>Where Creativity Meets Opportunity</h1>
        <p>
          Glamure is a platform for aspiring and professional designers to
          showcase, connect, and shine in the world of fashion.
        </p>
        <div className="hero-buttons">
          <button className="cta-btn">Explore Designs</button>
          <button className="secondary-btn">Join as Designer</button>
        </div>
      </div>
      <div className="hero-image">
        <img
          src="https://images.unsplash.com/photo-1521334884684-d80222895322"
          alt="Fashion Design"
        />
      </div>
    </section>
  );
};

export default Hero;
