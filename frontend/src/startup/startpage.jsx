import React, { useState } from "react";
import Header from "./components/Header";
import Hero from "./components/Hero";
import Features from "./components/Features";
import Categories from "./components/Categories";
import About from "./components/About";
import Footer from "./components/Footer";
import "./startpage.css";

const Startpage = () => {
  const [activeSection, setActiveSection] = useState("home");

  return (
    <div className="app">
      <Header
        activeSection={activeSection}
        setActiveSection={setActiveSection}
      />

      {activeSection === "home" && <Hero />}
      {activeSection === "features" && <Features />}
      {activeSection === "category" && <Categories />}
      {activeSection === "about" && <About />}

      <Footer />
    </div>
  );
};

export default Startpage;