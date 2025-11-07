import React, { useEffect, useRef, useState } from "react";
import { Sparkles, HeartHandshake } from "lucide-react";

const AboutPage = () => {
  const aboutRef = useRef(null);
  const [aboutVisible, setAboutVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => setAboutVisible(entry.isIntersecting),
      { threshold: 0.3 }
    );
    if (aboutRef.current) observer.observe(aboutRef.current);
    return () => observer.disconnect();
  }, []);

  return (
    <section
      id="about"
      ref={aboutRef}
      className="min-h-screen flex flex-col justify-center items-center text-center px-8 py-20 bg-black text-white"
    >
      <div
        className={`max-w-3xl transition-all duration-1000 ease-out transform ${
          aboutVisible
            ? "opacity-100 translate-y-0"
            : "opacity-0 translate-y-12"
        }`}
      >
        <div className="flex flex-col items-center gap-3 mb-10">
          <Sparkles className="w-10 h-10 text-pink-400 animate-pulse" />
          <h2 className="text-4xl font-bold tracking-wide text-white">
            About <span className="text-pink-400">Glamure</span>
          </h2>
        </div>

        <p className="text-lg leading-relaxed text-gray-300 mb-6">
          Glamure is more than just a platform — it’s a vibrant ecosystem built
          to uplift and empower fashion designers worldwide. Our goal is to
          inspire creativity, connect communities, and celebrate individuality
          through the art of design.
        </p>

        <p className="text-lg leading-relaxed text-gray-300">
          Every designer — from emerging talents to industry veterans — finds a
          space to showcase their unique vision. Glamure brings together passion
          and innovation, creating endless opportunities for artistic growth.
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
  );
};

export default AboutPage;