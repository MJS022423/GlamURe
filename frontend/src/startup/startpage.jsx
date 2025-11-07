import React, { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { Sparkles, HeartHandshake } from "lucide-react";
import file from "../assets/file.svg";
import land1 from "../assets/Images/land1.jpg";
import land2 from "../assets/Images/land2.jpg";
import land3 from "../assets/Images/land3.jpg";
import land4 from "../assets/Images/land4.jpg";
import "./startpage.css";

const Startpage = () => {
  const [activeSection, setActiveSection] = useState("home");
  const [menuOpen, setMenuOpen] = useState(false);
  const [currentImage, setCurrentImage] = useState(0);
  const [aboutVisible, setAboutVisible] = useState(false);
  const navigate = useNavigate();
  const aboutRef = useRef(null);

  const images = [land1, land2, land3, land4];

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentImage((prev) => (prev + 1) % images.length);
    }, 5000);
    return () => clearInterval(interval);
  }, [images.length]);

  useEffect(() => {
    const sections = document.querySelectorAll("section[id]");
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) setActiveSection(entry.target.id);
        });
      },
      { threshold: 0.6 }
    );
    sections.forEach((section) => observer.observe(section));
    return () => sections.forEach((section) => observer.unobserve(section));
  }, []);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => setAboutVisible(entry.isIntersecting),
      { threshold: 0.5 }
    );
    if (aboutRef.current) observer.observe(aboutRef.current);
    return () => {
      if (aboutRef.current) observer.unobserve(aboutRef.current);
    };
  }, []);

  const scrollToSection = (id) => {
    const section = document.getElementById(id);
    if (section) section.scrollIntoView({ behavior: "smooth" });
    setActiveSection(id);
    setMenuOpen(false);
  };

  return (
    <div
      className="app overflow-y-auto  no-scrollbar flex flex-col min-h-screen w-full bg-green-100 "
      style={{ scrollBehavior: "smooth" }}
    >
      {/* Hide scrollbar */}
      <style jsx>{`
              .no-scrollbar::-webkit-scrollbar {
                display: none;
              }
              .no-scrollbar {
                -ms-overflow-style: none;
                scrollbar-width: none;
              }
            `} </style>

      {/* HEADER */}
      <header className="header fixed top-0 left-0 w-full z-50 bg-[#111] text-white h-20 shadow-md flex items-center justify-between px-6">
        <div
          className="w-[100px] h-[50px] cursor-pointer"
          style={{
            backgroundColor: "#ff6392",
            maskImage: `url(${file})`,
            WebkitMaskImage: `url(${file})`,
            maskRepeat: "no-repeat",
            WebkitMaskRepeat: "no-repeat",
            maskSize: "contain",
            WebkitMaskSize: "contain",
          }}
          onClick={() => scrollToSection("hero")}
        ></div>

        <nav className="hidden md:flex gap-8 text-[16px] font-medium absolute left-1/2 transform -translate-x-1/2">
          {["features", "category", "about"].map((item) => (
            <button
              key={item}
              onClick={() => scrollToSection(item)}
              className={`transition duration-300 hover:text-[#f65b89] ${
                activeSection === item ? "text-[#f65b89]" : ""
              }`}
            >
              {item.charAt(0).toUpperCase() + item.slice(1)}
            </button>
          ))}
        </nav>

        <div className="hidden md:flex gap-3">
          <button
            onClick={() => navigate("/login", { state: { register: false } })}
            className="border border-[#ff6392] text-[#ff6392] w-24 h-10 font-semibold rounded hover:opacity-90 transition"
          >
            Login
          </button>
          <button
            onClick={() => navigate("/login", { state: { register: true } })}
            className="bg-[#ff6392] text-black font-semibold w-24 h-10 rounded hover:opacity-90 transition"
          >
            Sign Up
          </button>
        </div>

        {/* Mobile Menu */}
        <button
          className="md:hidden text-white"
          onClick={() => setMenuOpen(!menuOpen)}
        >
          {menuOpen ? (
            <svg xmlns="http://www.w3.org/2000/svg" className="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" className="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          )}
        </button>

        {menuOpen && (
          <div className="absolute top-20 left-0 w-full bg-[#111] text-white flex flex-col items-center gap-4 py-4 md:hidden">
            {["features", "category", "about"].map((item) => (
              <button
                key={item}
                onClick={() => scrollToSection(item)}
                className="hover:text-[#f65b89] transition"
              >
                {item.charAt(0).toUpperCase() + item.slice(1)}
              </button>
            ))}
            <div className="flex gap-3 mt-2">
              <button
                onClick={() => navigate("/login")}
                className="border border-[#ff6392] text-[#ff6392] px-4 py-2 rounded"
              >
                Login
              </button>
              <button
                onClick={() => navigate("/login", { state: { register: true } })}
                className="bg-[#ff6392] text-black px-4 py-2 rounded"
              >
                Sign Up
              </button>
            </div>
          </div>
        )}
      </header>

      {/* MAIN CONTENT */}
      <main className="flex-1 w-full">
        {/* HERO */}
        <section
          id="hero"
          className="min-h-screen flex flex-col md:flex-row items-center justify-between w-full relative"
          style={{
            backgroundImage: `url(${images[currentImage]})`,
            backgroundSize: "cover",
            backgroundPosition: "center",
            transition: "background-image 1s ease-in-out",
          }}
        >
          <div className="absolute inset-0 bg-black/40"></div>
          <div className="relative z-10 flex flex-col gap-6 text-center md:text-left md:w-1/2 px-8 md:px-20 text-white">
            <h1 className="text-5xl font-extrabold leading-tight animate-fadeIn">
              Where Creativity Meets Opportunity
            </h1>
            <p className="text-lg md:text-xl animate-slideUp">
              Glamure is a platform for aspiring and professional designers to
              showcase, connect, and shine in the world of fashion.
            </p>
            <div className="flex flex-col md:flex-row gap-5 justify-center md:justify-start mt-4">
              <button
                className="bg-pink-600 hover:bg-pink-700 text-white font-semibold py-3 px-6 rounded-full shadow-md transition duration-300"
                onClick={() => scrollToSection("category")}
              >
                Explore Designs
              </button>
              <button
                className="border-2 border-pink-600 text-pink-600 hover:bg-pink-50 font-semibold py-3 px-6 rounded-full shadow-md transition duration-300 bg-white/10 backdrop-blur"
                onClick={() =>
                  navigate("/login", { state: { register: true } })
                }
              >
                Join as Designer
              </button>
            </div>
          </div>
        </section>

     {/* FEATURES */}
<section
  id="features"
  className="min-h-screen flex flex-col justify-center items-center text-center pt-28 pb-36 px-6 bg-gradient-to-b from-[#9ba19d] to-[#2a2a2a] text-white"
>
  {/* Header */}
  <div className="flex flex-col justify-start items-center gap-4 mb-20">
    <Sparkles className="w-10 h-10 text-[#ff1493] animate-pulse" />
    <h2 className="text-5xl font-extrabold tracking-wide h-25">
      Platform <span className="text-[#ff1493]">Features</span>
    </h2>
  </div>

<<<<<<< Updated upstream
  {/* Title */}
  <div className="absolute top-1/50 left-1/2 -translate-x-1/2 text-center z-10">
    <h2 className="text-4xl font-bold text-black tracking-wide">Features</h2>
  </div>

  {/* Feature Cards */}
  <div className="flex flex-col gap-20 max-w-5xl w-full text-left">
=======
  {/* Features List */}
  <div className="flex flex-col gap-20 max-w-4xl w-full items-center">
>>>>>>> Stashed changes
    {[
      {
        icon: "🏆",
        title: "Ranking / Leaderboard",
        text: "Discover top designers and trendsetters dominating the charts through likes and engagement.",
      },
      {
        icon: "💬",
        title: "Comments & Likes",
        text: "Connect directly with other designers, clients, or recruiters through our built-in messaging system.",
      },
      {
        icon: "📤",
        title: "Posting Designs",
        text: "Submit your designs, apply to contests, and collaborate with brands across the fashion industry.",
      },
    ].map((feature, i) => (
      <div
        key={i}
        className="flex flex-col items-center gap-4 text-center"
      >
        <div className="flex items-center justify-center gap-3">
          <span className="text-4xl">{feature.icon}</span>
          <h3 className="text-3xl sm:text-4xl font-extrabold text-white transition duration-300 hover:text-[#ff1493] hover:scale-105">
            {feature.title}
          </h3>
        </div>
        <p className="text-lg font-semibold text-white/90 max-w-2xl leading-relaxed">
          {feature.text}
        </p>
      </div>
    ))}
  </div>
</section>



      {/* CATEGORIES */}
<section
  id="category"
  className="min-h-screen flex flex-col items-center justify-center text-center py-24 px-6 bg-gradient-to-b from-[#2a2a2a] to-[#000000] text-white overflow-hidden"
>
  <h2 className="text-5xl font-extrabold mb-10 bg-gradient-to-r from-pink-500 to-fuchsia-400 text-transparent bg-clip-text animate-pulse tracking-wide h-15">
    Fashion Categories
  </h2>

  <p className="text-gray-300 max-w-3xl mb-16 text-lg leading-relaxed h-25">
    Discover the diverse world of fashion — from timeless sophistication to modern creativity.
  </p>

  <div className="flex flex-wrap justify-center gap-10 w-full max-w-6xl">
    {[
      "👗 Women's Wear",
      "👔 Men's Wear",
      "👜 Accessories",
      "👟 Footwear",
      "🌿 Sustainable Fashion",
      "👶 Children's Fashion",
    ].map((c, i) => (
      <div
        key={i}
        className="group relative bg-[#1a1a1a] rounded-3xl px-10 py-10 font-semibold text-xl cursor-pointer transition-all duration-500 border border-gray-700 hover:border-pink-500 hover:scale-110 hover:shadow-[0_0_35px_rgba(236,72,153,0.4)] w-[250px] h-[180px] flex items-center justify-center text-center"
      >
        <span className="relative z-10 bg-gradient-to-r from-pink-400 to-fuchsia-500 bg-clip-text text-transparent">
          {c}
        </span>
        <div className="absolute inset-0 bg-gradient-to-r from-fuchsia-500 to-pink-600 rounded-3xl opacity-0 group-hover:opacity-25 transition duration-500 blur-lg"></div>
      </div>
    ))}
  </div>
</section>

        {/* ABOUT */}
        <section
          id="about"
          ref={aboutRef}
          className="min-h-screen flex flex-col justify-center items-center text-center px-8 py-20 bg-gradient-to-b from-black via-[#1a1a1a] to-[#ff6392] text-white"
        >
          <div
            className={`max-w-3xl transition-all duration-1000 ease-out transform ${
              aboutVisible
                ? "opacity-100 translate-y-0"
                : "opacity-0 translate-y-12"
            }`}
          >
            <div className="flex flex-col items-center gap-3 mb-10">
              <Sparkles className="w-10 h-10 text-[#ff80ab] animate-pulse" />
              <h2 className="text-4xl font-bold text-white tracking-wide">
                About <span className="text-[#ff80ab]">Glamure</span>
              </h2>
            </div>
            <p className="text-lg leading-relaxed text-gray-200 mb-6">
              Glamure is more than just a platform — it's a vibrant ecosystem
              built to uplift and empower fashion designers worldwide.
            </p>
            <p className="text-lg leading-relaxed text-gray-100">
              Every designer — from emerging talents to industry veterans —
              finds a space to showcase their unique vision.
            </p>
            <div
              className={`flex justify-center items-center gap-4 mt-10 transition-all duration-1000 delay-300 ${
                aboutVisible
                  ? "opacity-100 translate-y-0"
                  : "opacity-0 translate-y-8"
              }`}
            >
              <HeartHandshake className="w-8 h-8 text-pink-400 animate-bounce" />
              <span className="text-xl font-semibold text-pink-300">
                Designed for Dreamers. Built for Designers.
              </span>
            </div>
          </div>
        </section>
      </main>

      {/* FOOTER */}
      <footer className="bg-[#111] text-white text-center flex flex-col justify-center items-center gap-5 px-4 py-10">
        <p>© 2025 Glamure — Designed for Designers.</p>
        <h2>Contact us</h2>
        <div className="flex gap-10">
          <a href="https://www.facebook.com/kimbenedick.anzures.9" target="_blank" rel="noopener noreferrer">
            <img src="https://www.svgrepo.com/show/503338/facebook.svg" alt="Facebook" className="w-6 h-6 filter invert hover:scale-110 transition" />
          </a>
          <a href="https://www.instagram.com/beben_brsg/" target="_blank" rel="noopener noreferrer">
            <img src="https://www.svgrepo.com/show/512399/instagram-167.svg" alt="Instagram" className="w-6 h-6 filter invert hover:scale-110 transition" />
          </a>
          <a href="https://discord.gg/zzx3JTmn" target="_blank" rel="noopener noreferrer">
            <img src="https://www.svgrepo.com/show/506463/discord.svg" alt="Discord" className="w-6 h-6 filter invert hover:scale-110 transition" />
          </a>
        </div>
      </footer>
    </div>
  );
};

export default Startpage;
