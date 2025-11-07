import React, { useState, useRef, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

const SetupAccount = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const fileInputRef = useRef(null);
    const [profileImage, setProfileImage] = useState(null);
    const [formData, setFormData] = useState({
        displayName: "",
        gender: "",
        userType: ""
    });

    // Get username from navigation state or localStorage
    const username = location.state?.username || localStorage.getItem('username') || sessionStorage.getItem('username');

    // Redirect to login if no username found
    useEffect(() => {
        if (!username) {
            navigate("/login");
        }
    }, [username, navigate]);

    const handleImageClick = () => {
        fileInputRef.current?.click();
    };

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onloadend = () => {
                setProfileImage(reader.result);
            };
            reader.readAsDataURL(file);
        }
    };

    // Gender selection - mutually exclusive (only one can be selected)
    const handleGenderSelect = (gender) => {
        setFormData({ ...formData, gender }); // Replaces previous selection
    };

    // User Type selection - mutually exclusive (only one can be selected)
    const handleUserTypeSelect = (userType) => {
        setFormData({ ...formData, userType }); // Replaces previous selection
    };

    const handleSetup = async (e) => {
        e.preventDefault();

        if (!formData.displayName || !formData.gender || !formData.userType) {
            alert("Please fill in all fields");
            return;
        }

        try {
            if (!username) {
                alert("User session not found. Please register again.");
                navigate("/login");
                return;
            }

            const response = await fetch(`${EXPRESS_API}/auth/SetupAccount`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    username: username,
                    displayName: formData.displayName,
                    gender: formData.gender,
                    role: formData.userType,
                    profileImage: profileImage
                }),
            });

            const data = await response.json();

            if (response.ok) {
                console.log("✅ Account setup success:", data);
                navigate("/dashboard");
            } else {
                alert(data.error || data.message || "Setup failed");
            }
        } catch (error) {
            console.error("❌ Setup error:", error);
            alert("Server error. Please try again later.");
        }
    };

    return (
        <div className="flex items-center justify-center min-h-screen bg-[#FFB6C1]">
            {/* Main Card */}
            <div className="bg-white rounded-3xl border-2 border-purple-500 shadow-2xl w-[90%] max-w-md p-8 flex flex-col items-center">
                {/* Title */}
                <h1 className="text-3xl font-bold text-black mb-6">Setup Account</h1>

                {/* Profile Image Placeholder */}
                <div className="mb-4">
                    <div 
                        className="w-24 h-24 rounded-full border-4 border-black bg-white flex items-center justify-center cursor-pointer overflow-hidden"
                        onClick={handleImageClick}
                    >
                        {profileImage ? (
                            <img src={profileImage} alt="Profile" className="w-full h-full object-cover" />
                        ) : (
                            <svg 
                                xmlns="http://www.w3.org/2000/svg" 
                                fill="none" 
                                viewBox="0 0 24 24" 
                                strokeWidth={2} 
                                stroke="currentColor" 
                                className="w-12 h-12 text-black"
                            >
                                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                            </svg>
                        )}
                    </div>
                    <input
                        ref={fileInputRef}
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        className="hidden"
                    />
                </div>

                {/* Add Image Button */}
                <button
                    type="button"
                    onClick={handleImageClick}
                    className="mb-6 px-4 py-2 bg-black text-white rounded-lg text-sm font-medium hover:bg-gray-800 transition shadow-lg shadow-pink-500/50"
                >
                    Add Image
                </button>

                {/* Display Name */}
                <div className="w-full mb-6">
                    <label className="block text-black font-medium mb-2">Display Name</label>
                    <input
                        type="text"
                        value={formData.displayName}
                        onChange={(e) => setFormData({ ...formData, displayName: e.target.value })}
                        className="w-full px-4 py-2 border-2 border-black rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                        placeholder="Enter your display name"
                    />
                </div>

                {/* Gender and User Type */}
                <div className="w-full grid grid-cols-2 gap-6 mb-6">
                    {/* Gender */}
                    <div>
                        <label className="block text-black font-medium mb-2">Gender</label>
                        <div className="flex gap-2">
                            <button
                                type="button"
                                onClick={() => handleGenderSelect("Male")}
                                className={`flex-1 py-2 px-4 rounded-full border-2 border-black text-sm font-medium transition ${
                                    formData.gender === "Male"
                                        ? "bg-black text-white"
                                        : "bg-white text-black hover:bg-gray-100"
                                }`}
                            >
                                Male
                            </button>
                            <button
                                type="button"
                                onClick={() => handleGenderSelect("Female")}
                                className={`flex-1 py-2 px-4 rounded-full border-2 border-black text-sm font-medium transition ${
                                    formData.gender === "Female"
                                        ? "bg-black text-white"
                                        : "bg-white text-black hover:bg-gray-100"
                                }`}
                            >
                                Female
                            </button>
                        </div>
                    </div>

                    {/* User Type */}
                    <div>
                        <label className="block text-black font-medium mb-2">User Type</label>
                        <div className="flex gap-2">
                            <button
                                type="button"
                                onClick={() => handleUserTypeSelect("Viewer")}
                                className={`flex-1 py-2 px-4 rounded-full border-2 border-black text-sm font-medium transition ${
                                    formData.userType === "Viewer"
                                        ? "bg-black text-white"
                                        : "bg-white text-black hover:bg-gray-100"
                                }`}
                            >
                                Viewer
                            </button>
                            <button
                                type="button"
                                onClick={() => handleUserTypeSelect("Designer")}
                                className={`flex-1 py-2 px-4 rounded-full border-2 border-black text-sm font-medium transition ${
                                    formData.userType === "Designer"
                                        ? "bg-black text-white"
                                        : "bg-white text-black hover:bg-gray-100"
                                }`}
                            >
                                Designer
                            </button>
                        </div>
                    </div>
                </div>

                {/* Setup Button */}
                <button
                    type="button"
                    onClick={handleSetup}
                    className="w-full py-3 bg-black text-white rounded-lg text-lg font-bold hover:bg-gray-800 transition shadow-lg shadow-pink-500/50"
                >
                    Setup
                </button>
            </div>
        </div>
    );
}

export default SetupAccount;
