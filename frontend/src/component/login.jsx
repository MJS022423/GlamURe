import React, { useState } from "react";
import { useNavigate } from "react-router-dom"; // 👈 import navigate
import logo from "../assets/Webapp.svg"; // your logo image
import "../style/login.css"; // your CSS file

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

function Login({ onLoginSuccess }) {
  // Track which form is active
  const [isRegister, setIsRegister] = useState(false);
  const [loginData, setLoginData] = useState({ username: "", password: "" });
  const [registerData, setRegisterData] = useState({
    username: "",
    email: "",
    password: "",
  });
  const navigate = useNavigate(); // 👈 initialize navigation

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch(`${EXPRESS_API}/auth/Login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(loginData)
      });

      const data = await res.json();
      if (res.ok) {
        onLoginSuccess(); // mark as logged in
        navigate("/dashboard"); // 👈 go to dashboard
      } else {
        console.log(data.message || "Login Failed");
      }

    } catch (err) {
      console.log("Error connecting to server");
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch(`${EXPRESS_API}/auth/Register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(registerData),
      });

      const data = await res.json();
      if (data.ok) {
        onLoginSuccess();
        navigate("/dashboard"); // 👈 same for register
      } else {
        console.log(data.message || "Registration failed");
      }

    } catch (err) {
      console.log("Error connecting to server");
    }
  };

  return (
    <div className="float">
      <img src={logo} className="Applogo" alt="logo" />
      <div className="divide"></div>

      <div className="form">
        <div className="btnb">
          <div
            id="btn"
            style={{
              left: isRegister ? "120px" : "0px",
              transition: "left 0.5s",
            }}
          ></div>

          <button
            id="logbtn"
            type="button"
            className={`toggle ${!isRegister ? "active" : ""}`}
            onClick={() => setIsRegister(false)}
            style={{
              color: isRegister ? "black" : "rgba(255, 255, 255, 1)",
              fontWeight: "bold",
            }}
          >
            Login
          </button>

          <button
            id="regBtn"
            type="button"
            className={`toggle ${isRegister ? "active" : ""}`}
            onClick={() => setIsRegister(true)}
            style={{
              color: isRegister ? "rgba(255, 255, 255, 1)" : "black",
              fontWeight: "bold",
            }}
          >
            Register
          </button>
        </div>


        {!isRegister ? (<form
          id="logform"
          onSubmit={handleLogin}
          className="inp"
          style={{
            position: "relative",
            left: isRegister ? "-400px" : "0px",
            opacity: isRegister ? 0 : 1,
            transition: "left 1.5s",
          }}
        >
          <div className="input-wrap">
            <input type="text" className="inpf" placeholder=" " required />
            <div className="label">Username</div>
          </div>

          <div className="input-wrap">
            <input type="password" className="inpf" placeholder=" " required />
            <div className="label">Password</div>
          </div>

          <input type="submit" className="sub-btn" value="Login" />
        </form>) :


          (<form
            id="regform"
            onSubmit={handleRegister}
            className="inp"
            style={{
              opacity: isRegister ? 1 : 0,
              left: isRegister ? "0px" : "400px",
              transition: "left 0.5s",
              position: "relative",
            }}
          >
            <div className="input-wrap">
              <input type="text" className="inpf" placeholder=" " required />
              <div className="label">Username</div>
            </div>

            <div className="input-wrap">
              <input type="email" className="inpf" placeholder=" " required />
              <div className="label">Email</div>
            </div>

            <div className="input-wrap">
              <input type="password" className="inpf" placeholder=" " required />
              <div className="label">Password</div>
            </div>

            <input type="submit" className="sub-btn" value="Register" />
          </form>
          )}
      </div>

    </div>
  );
}

export default Login;
