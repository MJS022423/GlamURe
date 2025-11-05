import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import logo from "../assets/Webapp.svg";
import privacyPolicyText from "../dataprivacy";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

function Login({ onLoginSuccess }) {
  const location = useLocation();
  const [isRegister, setIsRegister] = useState(false);
  const [showPolicy, setShowPolicy] = useState(false); // 🔹 Modal state
  const navigate = useNavigate();
  const [showLoginPassword, setShowLoginPassword] = useState(false);
  const [showRegisterPassword, setShowRegisterPassword] = useState(false);

  // Check if we should show register form based on navigation state
  useEffect(() => {
    if (location.state?.register) {
      setIsRegister(true);
    }
  }, [location.state]);

  // Separate states for login and register
  const [loginData, setLoginData] = useState({
    username: "",
    password: "",
    remember: false,
  });

  const [registerData, setRegisterData] = useState({
    username: "",
    email: "",
    password: "",
    agree: false,
  });

  const handleLogin = async (e) => {
    e.preventDefault();

    if (!loginData.username || !loginData.password) return;

    try {
      const response = await fetch(`${EXPRESS_API}/auth/Login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: loginData.username,
          password: loginData.password,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        console.log("✅ Login success:", data);
        onLoginSuccess();
        navigate("/dashboard");
      } else {
        alert(data.message || "Invalid credentials");
      }
    } catch (error) {
      console.error("❌ Login error:", error);
      alert("Server error. Please try again later.");
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();

    if (!registerData.agree) {
      alert("Please agree to the Terms of Use and Privacy Policy before continuing.");
      return;
    }

    try {
      const response = await fetch(`${EXPRESS_API}/auth/Register`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: registerData.username,
          email: registerData.email,
          password: registerData.password,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        console.log("✅ Registration success:", data);
        onLoginSuccess();
        navigate("/dashboard");
      } else {
        alert(data.message || "Registration failed");
      }
    } catch (error) {
      console.error("❌ Register error:", error);
      alert("Server error. Please try again later.");
    }
  };
  const toggleLoginPassword = () => setShowLoginPassword((v) => !v);
  const toggleRegisterPassword = () => setShowRegisterPassword((v) => !v);

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-b from-white to-pink-300 relative">
      {/* Main Card */}
      <div className="relative flex bg-[#f9f9f9] shadow-2xl rounded-[50px] h-[500px] w-[800px] max-w-full overflow-hidden">
        {/* Back Button */}
        <button
          onClick={() => navigate("/main")}
          className="absolute top-5 left-6 flex items-center text-gray-600 hover:text-black transition"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth={2}
            stroke="currentColor"
            className="w-5 h-5 mr-1"
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
          </svg>
          Back
        </button>

        {/* Left Section */}
        <div className="flex flex-col items-center justify-center w-1/2 py-16">
          <img src={logo} alt="Logo" className="max-h-[200px]" />
        </div>

        {/* Divider */}
        <div className="w-px bg-gray-900 my-10"></div>

        {/* Right Section */}
        <div className="flex flex-col items-center justify-center w-1/2 px-10">
          {/* Toggle Buttons */}
          <div className="relative flex bg-[#f5f1f1] w-full border border-gray-700 rounded-full mb-10 shadow-sm">
            <div
              className={`absolute top-0 left-0 w-1/2 h-full bg-black rounded-full transition-all duration-500 ${
                isRegister ? "translate-x-full" : "translate-x-0"
              }`}
            ></div>
            <button
              className={`relative z-10 w-1/2 py-2 text-sm font-semibold rounded-full ${
                !isRegister ? "text-white" : "text-black"
              }`}
              onClick={() => setIsRegister(false)}
            >
              Login
            </button>
            <button
              className={`relative z-10 w-1/2 py-2 text-sm font-semibold rounded-full ${
                isRegister ? "text-white" : "text-black"
              }`}
              onClick={() => setIsRegister(true)}
            >
              Register
            </button>
          </div>

          {/* LOGIN FORM */}
          {!isRegister ? (
            <form
              onSubmit={handleLogin}
              className={`transition-all duration-700 ${
                isRegister
                  ? "opacity-0 -translate-x-40 absolute"
                  : "opacity-100 translate-x-0"
              } w-full max-w-xs`}
            >
              {/* Username */}
              <div className="relative mb-6">
                <input
                  type="text"
                  value={loginData.username}
                  onChange={(e) =>
                    setLoginData({ ...loginData, username: e.target.value })
                  }
                  className="peer w-full border-b border-gray-400 focus:border-black outline-none bg-transparent p-2 placeholder-transparent"
                  placeholder="Username"
                  
                />
                <label
                  className={`absolute left-2 text-gray-500 transition-all duration-300 bg-[#f9f9f9] px-1 ${
                    loginData.username
                      ? "-top-3 text-sm text-black"
                      : "top-2 text-gray-400"
                  } peer-focus:-top-3 peer-focus:text-sm peer-focus:text-black`}
                >
                  Username
                </label>
              </div>

              {/* Password */}
              <div className="relative mb-6">
                <input
                  type={showLoginPassword ? "text" : "password"}
                  value={loginData.password}
                  onChange={(e) =>
                    setLoginData({ ...loginData, password: e.target.value })
                  }
                  className="peer w-full border-b border-gray-400 focus:border-black outline-none bg-transparent p-2 placeholder-transparent"
                  placeholder="Password"
                />
                <label
                  className={`absolute left-2 text-gray-500 transition-all duration-300 bg-[#f9f9f9] px-1 ${
                    loginData.password
                      ? "-top-3 text-sm text-black"
                      : "top-2 text-gray-400"
                  } peer-focus:-top-3 peer-focus:text-sm peer-focus:text-black`}
                >
                  Password
                </label>
                <button
                  type="button"
                  onClick={toggleLoginPassword}
                  aria-label={showLoginPassword ? "Hide password" : "Show password"}
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-1"
                >
                  <img
                    src={showLoginPassword ? "https://www.svgrepo.com/show/532493/eye.svg" : "https://www.svgrepo.com/show/532465/eye-slash.svg"}
                    alt={showLoginPassword ? "Hide password" : "Show password"}
                    className="w-5 h-5"
                  />
                </button>
              </div>

              {/* Remember Me */}
              <div className="flex items-center mb-6">
                <input
                  id="remember"
                  type="checkbox"
                  checked={loginData.remember}
                  onChange={(e) =>
                    setLoginData({ ...loginData, remember: e.target.checked })
                  }
                  className="mr-2 accent-black"
                />
                <label htmlFor="remember" className="text-sm text-gray-700">
                  Remember Me
                </label>
              </div>

              <button
                type="submit"
                className="w-full py-2 bg-black text-white rounded-full shadow-md hover:bg-gray-800 transition"
              >
                Login
              </button>
            </form>
          ) : (
            // REGISTER FORM
            <form
              onSubmit={handleRegister}
              className={`transition-all duration-700 ${
                isRegister
                  ? "opacity-100 translate-x-0"
                  : "opacity-0 translate-x-40 absolute"
              } w-full max-w-xs`}
            >
              {/* Username */}
              <div className="relative mb-6">
                <input
                  type="text"
                  value={registerData.username}
                  onChange={(e) =>
                    setRegisterData({ ...registerData, username: e.target.value })
                  }
                  className="peer w-full border-b border-gray-400 focus:border-black outline-none bg-transparent p-2 placeholder-transparent"
                  placeholder="Username"
                />
                <label
                  className={`absolute left-2 text-gray-500 transition-all duration-300 bg-[#f9f9f9] px-1 ${
                    registerData.username
                      ? "-top-3 text-sm text-black"
                      : "top-2 text-gray-400"
                  } peer-focus:-top-3 peer-focus:text-sm peer-focus:text-black`}
                >
                  Username
                </label>
              </div>

              {/* Email */}
              <div className="relative mb-6">
                <input
                  type="email"
                  value={registerData.email}
                  onChange={(e) =>
                    setRegisterData({ ...registerData, email: e.target.value })
                  }
                  className="peer w-full border-b border-gray-400 focus:border-black outline-none bg-transparent p-2 placeholder-transparent"
                  placeholder="Email"
                />
                <label
                  className={`absolute left-2 text-gray-500 transition-all duration-300 bg-[#f9f9f9] px-1 ${
                    registerData.email
                      ? "-top-3 text-sm text-black"
                      : "top-2 text-gray-400"
                  } peer-focus:-top-3 peer-focus:text-sm peer-focus:text-black`}
                >
                  Email
                </label>
              </div>

              {/* Password */}
              <div className="relative mb-6">
                <input
                  type={showRegisterPassword ? "text" : "password"}
                  value={registerData.password}
                  onChange={(e) =>
                    setRegisterData({ ...registerData, password: e.target.value })
                  }
                  className="peer w-full border-b border-gray-400 focus:border-black outline-none bg-transparent p-2 placeholder-transparent"
                  placeholder="Password"
                />
                <label
                  className={`absolute left-2 text-gray-500 transition-all duration-300 bg-[#f9f9f9] px-1 ${
                    registerData.password
                      ? "-top-3 text-sm text-black"
                      : "top-2 text-gray-400"
                  } peer-focus:-top-3 peer-focus:text-sm peer-focus:text-black`}
                >
                  Password
                </label>
                <button
                  type="button"
                  onClick={toggleRegisterPassword}
                  aria-label={showRegisterPassword ? "Hide password" : "Show password"}
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-1"
                >
                  <img
                    src={showRegisterPassword ? "https://www.svgrepo.com/show/532493/eye.svg" : "https://www.svgrepo.com/show/532465/eye-slash.svg"}
                    alt={showRegisterPassword ? "Hide password" : "Show password"}
                    className="w-5 h-5"
                  />
                </button>
              </div>

              {/* Agree Checkbox */}
              <div className="flex items-center mb-6 text-sm">
                <input
                  id="agree"
                  type="checkbox"
                  checked={registerData.agree}
                  onChange={(e) =>
                    setRegisterData({ ...registerData, agree: e.target.checked })
                  }
                  className="mr-2 accent-black"
                />
                <label htmlFor="agree" className="text-gray-700">
                  I agree to the{" "}
                  <button
                    type="button"
                    onClick={() => setShowPolicy(true)}
                    className="text-black underline hover:text-gray-600"
                  >
                    Terms of Use and Privacy Policy
                  </button>
                </label>
              </div>

              <button
                type="submit"
                className="w-full py-2 bg-black text-white rounded-full shadow-md hover:bg-gray-800 transition"
              >
                Register
              </button>
            </form>
          )}
        </div>
      </div>

      {/* PRIVACY POLICY MODAL */}
      {showPolicy && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/30 backdrop-blur-sm z-50">
          {/* Floating Popup */}
          <div className="bg-white p-6 rounded-2xl shadow-2xl w-[90%] max-w-lg max-h-[80vh] overflow-hidden relative animate-[fadeIn_0.3s_ease]">
            {/* HEADER (fixed position inside the modal) */}
            <div className="sticky top-0 bg-white z-10 pb-2 border-b flex items-center justify-center">
              <h2 className="text-2xl font-semibold text-center flex-1">
                Privacy Policy
              </h2>
              <button
                onClick={() => setShowPolicy(false)}
                className="absolute right-4 text-gray-500 hover:text-black text-2xl font-bold"
              >
                ×
              </button>
            </div>

            {/* SCROLLABLE TEXT AREA */}
            <div className="text-gray-700 text-sm leading-relaxed whitespace-pre-wrap overflow-y-auto max-h-[70vh] no-scrollbar mt-2 pr-2">
              {privacyPolicyText}
            </div>

            <style jsx>{`
              .no-scrollbar::-webkit-scrollbar {
                display: none;
              }
              .no-scrollbar {
                -ms-overflow-style: none;
                scrollbar-width: none;
              }
            `}</style>
          </div>
        </div>
      )}
    </div>
  );
}

export default Login;
