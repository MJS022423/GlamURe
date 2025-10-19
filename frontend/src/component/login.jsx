import React, { useState } from "react";
import logo from "../assets/Webapp.svg"; // your logo image
import "../style/login.css"; // your CSS file

function Login() {
  // Track which form is active
  const [isRegister, setIsRegister] = useState(false);

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

        
        {!isRegister?(<form
          id="logform"
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
        </form>):

        
        (<form
          id="regform"
          className="inp"
          style={{
            opacity: isRegister ? 1:0,
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
