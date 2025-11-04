import React, { useState,useEffect } from "react";
import { useNavigate} from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import file from "../assets/file.svg";
import "./startpage.css";

const Startpage = () => {
  const [activeSection, setActiveSection] = useState("home");
  const [menuOpen, setMenuOpen] = useState(false);
  const navigate = useNavigate();

  const scrollToSection = (id) => {
    const section = document.getElementById(id);
    if (section) {
      section.scrollIntoView({ behavior: "smooth" });
    }
    setActiveSection(id);
    setMenuOpen(false);
  };

  // --- Auto-highlight based on scroll position ---
  useEffect(() => {
    const sections = document.querySelectorAll("section[id]");
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveSection(entry.target.id);
          }
        });
      },
      { threshold: 0.6 } // 60% visible triggers highlight
    );

    sections.forEach((section) => observer.observe(section));

    return () => {
      sections.forEach((section) => observer.unobserve(section));
    };
  }, []);

  return (
    <div className="app flex flex-col min-h-screen w-screen bg-green-100 overflow-hidden ">
      <header className="header fixed top-0 left-0 w-full z-50 bg-[#111] text-white h-20 shadow-md relative flex items-center justify-between px-6">
  {/* Logo */}
  <div
    className="w-[100px] h-[50px] mask mask-center cursor-pointer"
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

  {/* Center Nav (desktop only) */}
  <nav className="hidden md:flex gap-8 text-[16px] font-medium absolute left-1/2 transform -translate-x-1/2">
    <button
      onClick={() => scrollToSection("features")}
      className={`transition duration-300 hover:text-[#f65b89] ${
        activeSection === "features" ? "text-[#f65b89]" : ""
      }`}
    >
      Features
    </button>
    <button
      onClick={() => scrollToSection("category")}
      className={`transition duration-300 hover:text-[#f65b89] ${
        activeSection === "category" ? "text-[#f65b89]" : ""
      }`}
    >
      Categories
    </button>
    <button
      onClick={() => scrollToSection("about")}
      className={`transition duration-300 hover:text-[#f65b89] ${
        activeSection === "about" ? "text-[#f65b89]" : ""
      }`}
    >
      About
    </button>
  </nav>

  {/* Auth buttons (desktop) */}
  <div className="hidden md:flex gap-3">
    <button
      onClick={() => navigate("/login")}
      className="border border-[#ff6392] text-[#ff6392] w-24 h-10 font-semibold rounded hover:opacity-90 transition"
    >
      Login
    </button>
    <button
      onClick={() => navigate("/login")}
      className="bg-[#ff6392] text-black font-semibold w-24 h-10 rounded hover:opacity-90 transition"
    >
      Sign Up
    </button>
  </div>

  {/* Hamburger (mobile only) */}
  <button
    className="md:hidden text-white focus:outline-none"
    onClick={() => setMenuOpen(!menuOpen)}
  >
    <svg
      xmlns="http://www.w3.org/2000/svg"
      className="h-7 w-7"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
    >
      {menuOpen ? (
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
      ) : (
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
      )}
    </svg>
  </button>

  {/* Mobile dropdown menu */}
  {menuOpen && (
    <div className="absolute top-20 left-0 w-full bg-[#111] text-white flex flex-col items-center gap-4 py-4 md:hidden shadow-md border-t border-[#222]">
      <button
        onClick={() => scrollToSection("features")}
        className="hover:text-[#f65b89] transition"
      >
        Features
      </button>
      <button
        onClick={() => scrollToSection("category")}
        className="hover:text-[#f65b89] transition"
      >
        Categories
      </button>
      <button
        onClick={() => scrollToSection("about")}
        className="hover:text-[#f65b89] transition"
      >
        About
      </button>
      <div className="flex gap-3 mt-2">
        <button
          onClick={() => navigate('/login')}
          className="border border-[#ff6392] text-[#ff6392] px-4 py-2 rounded hover:opacity-90"
        >
          Login
        </button>
        <button
          onClick={() => navigate('/login')}
          className="bg-[#ff6392] text-black px-4 py-2 rounded hover:opacity-90"
        >
          Sign Up
        </button>
      </div>
    </div>
  )}
</header>

      <main className="flex-1 w-full overflow-y-scroll snap-y snap-mandatory scrollbar-hide scroll-smooth overflow-x-hidden">

  {/* Hero Section */}
  <section
    id="hero"
    className="snap-start min-h-screen flex flex-col md:flex-row items-center justify-between py-20 pt-20 w-screen bg-gradient-to-r from-[#f9f9f9] to-[#fce4ec] px-30"
  >
    {/* Text Section */}
    <div className="flex flex-col gap-6 text-center md:text-left md:w-1/2 px-8 md:px-20">
      <h1 className="text-4xl md:text-5xl font-extrabold text-gray-800 leading-tight">
        Where Creativity Meets Opportunity
      </h1>
      <p className="text-gray-700 text-lg md:text-xl">
        Glamure is a platform for aspiring and professional designers to
        showcase, connect, and shine in the world of fashion.
      </p>

      <div className="flex flex-wrap flex-col md:flex-row gap-5 justify-center md:justify-start mt-4">
        <button
          className="bg-pink-600 hover:bg-pink-700 w-35 h-10 text-white font-semibold py-3 px-6 rounded-full shadow-md transition duration-300"
          onClick={() => setActiveSection("category")}
        >
          Explore Designs
        </button>
        <button
          className="border-2 border-pink-600 w-35 text-pink-600 hover:bg-pink-50 font-semibold py-3 px-6 rounded-full shadow-md transition duration-300"
          onClick={() => navigate("/login")}
        >
          Join as Designer
        </button>
      </div>
    </div>

    {/* Image Section */}
    <div className="flex justify-end w-full md:w-1/2 px-4 md:px-10">
      <img
        src="https://assets.vogue.com/photos/616062ff816ea2de6ec85809/master/w_1920,c_limit/00_story.jpg"
        alt="Fashion Design"
        className="rounded-2xl h-80 shadow-lg w-full max-w-md object-cover"
      />
    </div>
  </section>

  {/* Features Section */}
  <section
    id="features"
    className="min-h-screen snap-start flex flex-col justify-center items-center bg-blue-500 text-center scroll-mt-20 w-screen py-24 px-6"
  >
    <h2 className="text-3xl font-semibold text-white mb-8">
      Platform Highlights
    </h2>

    <div className="flex flex-col lg:flex-row flex-wrap justify-center gap-6 max-w-6xl mx-auto">
      {[
        { title: "🏆 Ranking / Leaderboard", text: "Discover top designs based on likes and track the top designers dominating the charts." },
        { title: "💬 Messages", text: "Connect with other designers or recruiters through private messages." },
        { title: "💼 Applying / Hiring", text: "Designers can apply to job posts, while recruiters can find and message talents directly." },
        { title: "👗 Design Categories", text: "Explore designs by category: Men's or Women's Apparel." },
        { title: "📌 Bookmark Design", text: "Save your favorite designs for future inspiration and reference." },
      ].map((feature, idx) => (
        <div
          key={idx}
          className="bg-white border border-gray-200 rounded-2xl p-6 w-full lg:w-[30%] transition-transform duration-300 hover:-translate-y-1 hover:shadow-[0_4px_12px_rgba(255,99,146,0.2)]"
        >
          <h3 className="text-pink-500 text-xl font-semibold mb-3">
            {feature.title}
          </h3>
          <p className="text-gray-700">{feature.text}</p>
        </div>
      ))}
    </div>
  </section>

  {/* Categories Section */}
  <section
    id="category"
    className="min-h-screen snap-start flex flex-col items-center justify-center text-center py-20 w-screen bg-orange-500"
  >
    <h2 className="text-3xl font-semibold text-gray-900 mb-10">
      Fashion Categories
    </h2>

    <div className="flex flex-wrap justify-center items-center gap-5 bg-[#f6b0ba] w-full max-w-5xl mx-auto rounded-xl py-8 px-4">
      {[
        "👗 Women's Wear",
        "👔 Men's Wear",
        "👜 Accessories",
        "👟 Footwear",
        "🌿 Sustainable Fashion",
        "👶 Children's Fashion",
      ].map((category, idx) => (
        <div
          key={idx}
          className="bg-[#ffe4ed] rounded-xl px-8 py-5 font-bold cursor-pointer transition-transform duration-300 hover:bg-[#f794a3] hover:scale-105"
        >
          {category}
        </div>
      ))}
    </div>
  </section>

  {/* About Section */}
  <section
    id="about"
    className="min-h-screen snap-start flex flex-col justify-center items-center text-center pt-15 w-screen bg-red-500 text-gray-800"
  >
    <div className="max-w-3xl px-6">
      <h2 className="text-3xl font-semibold mb-10">About Glamure</h2>
      <p className="mb-6 leading-8">
        Glamure is more than just a platform — it's a vibrant ecosystem designed
        to uplift and empower both aspiring and professional fashion designers.
        In an industry where creativity meets fierce competition, Glamure offers
        a sanctuary where talent is nurtured, ideas are celebrated, and
        connections flourish.
      </p>
      <p className="leading-8">
        Our community is built on collaboration, inspiration, and mutual growth,
        where every member — from emerging artists to seasoned professionals —
        can find their voice and be seen. Whether you're sketching your first
        collection or preparing for your next runway show, Glamure is your
        creative partner.
      </p>
    </div>
  </section>
</main>


      {/* Footer */}
      <footer className="footer bg-[#111] text-white text-center flex flex-col justify-center items-center gap-5 h-auto w-screen px-4 py-10">

      <p className="mt-3">© 2025 Glamure — Designed for Designers.</p>
      <h2>Contact us</h2>
      <div className="w-half flex flex-row md:flex-row gap-10 mb-10">
        <a 
          href="https://www.facebook.com/kimbenedick.anzures.9"  
          target="_blank" 
          rel="noopener noreferrer">
          <button className="bg-black-600 p-2 h-5 w-5 rounded-full hover:bg-blue-700 transition">
          <img 
            src="https://www.svgrepo.com/show/503338/facebook.svg" 
            alt="Facebook.com" 
            className="w-5 h-5 filter invert"
          />
        </button>
        </a>
        <a 
          href="https://www.instagram.com/beben_brsg/?fbclid=IwY2xjawN2w8NleHRuA2FlbQIxMABicmlkETExME9QWW9ZOWw1Z0V4QlFhAR4ac2uHxcHk_sRUaQAg_-59T2yQ1JGQW6oDtRtMW1-sdP1Ahvb7FXL2nfDCCA_aem_nRfMQTirdwNNSATvk9KZkQ#"  
          target="_blank" 
          rel="noopener noreferrer">
          <button className="bg-black-600 p-2 rounded-full w-5 h-5 hover:bg-gradient-to-r hover:from-yellow-400 hover:via-pink-500 hover:to-purple-600 transition">
          <img 
            src="https://www.svgrepo.com/show/512399/instagram-167.svg" 
            alt="Instagram.com" 
            className="w-5 h-4 filter invert"
          />
        </button>
        </a>
        <a 
          href="https://discord.gg/zzx3JTmn"
          target="_blank" 
          rel="noopener noreferrer">
          <button className="bg-black-600 p-2 rounded-full w-5 h-5 hover:bg-blue-700 transition">
          <img 
            src="https://www.svgrepo.com/show/506463/discord.svg"
            alt="Discord.com" 
            className="w-5 h-5 filter invert"
          />
        </button>
        </a>
      </div>
    </footer> 
    </div>
  );  
};

export default Startpage;