import React, { useState } from 'react';
import { Shield, User, Camera, ChevronDown, AlignEndHorizontal } from 'lucide-react';

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API

const Settings = () => {
  const [profile, setProfile] = useState({
    name: '',
    username: '',
    profilePicture: null
  });

  const [passwords, setPasswords] = useState({
    current: '',
    new: '',
    confirm: ''
  });

  const [expandedSections, setExpandedSections] = useState({
    profile: false,
    security: false,
    account: false
  });

  const toggleSection = (section) => {
    setExpandedSections(prev => ({ ...prev, [section]: !prev[section] }));
  };

  const handleProfileChange = (key, value) => {
    setProfile(prev => ({ ...prev, [key]: value }));
  };

  const handlePasswordChange = (key, value) => {
    setPasswords(prev => ({ ...prev, [key]: value }));
  };

  const handleProfilePictureChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setProfile(prev => ({ ...prev, profilePicture: reader.result }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSaveProfile = async () => {
    const token = localStorage.getItem("token");
    const userId = localStorage.getItem("userid");

    if (!token || !userId) {
      alert("You must be logged in to update your profile.");
      return;
    }

    try {
      const res = await fetch(`${EXPRESS_API}/auth/UpdateProfile`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          userid: userId,
          name: profile.name,
          username: profile.username,
          profilePicture: profile.profilePicture
        }),
      });

      if (res.ok) {
        alert("Profile Sucessfully changes");
      } else {
        alert("Something went wrong please try again.");
      }

    } catch (error) {
      console.log( error.message);
    }
  };

  const handleSavePassword = async () => {
    const token = localStorage.getItem("token");
    const userId = localStorage.getItem("userid");

    if (passwords.new !== passwords.confirm) {
      alert('New passwords do not match!');
      return;
    }
    
    try {

      const res = await fetch(`${EXPRESS_API}/auth/UpdatePass`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ 
            userid: userId,
            password: passwords.current,
            newPassword: passwords.new,
          }),
      });

      if (res.ok) {
        alert("Successfully change password");
        setPasswords({ current: '', new: '', confirm: '' });
      } else {
        alert("Something went wrong. Please try again.");
      }

    } catch ( error ) {
      console.log( error.message);
    }
    };

  const handleDeleteAccount = async () => {
    const confirmDelete = window.confirm(
      "Are you sure you want to permanently delete your account? This action cannot be undone."
    );

    if (!confirmDelete) return;

    const token = localStorage.getItem("token");
    const userId = localStorage.getItem("userid");

    if (!token || !userId) {
      alert("You must be logged in to delete your account.");
      return;
    }

    try {

      const res = await fetch(`${EXPRESS_API}/auth/DeleteAccount`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ userid: userId }),
      });

      const data = await res.json();

      if (res.ok) {
        alert("Your account has been permanently deleted.");

        localStorage.removeItem("token");
        localStorage.removeItem("userid");

        window.location.href = "/login";
      } else {
        alert(`Error: ${data.error || "Failed to delete account."}`);
      }
    } catch (error) {
      console.log( error.message);
    }
  };


  return (
    <div className="h-full overflow-y-auto no-scrollbar bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] text-white overflow-hidden">
        <style jsx>{`
              .no-scrollbar::-webkit-scrollbar {
                display: none;
              }
              .no-scrollbar {
                -ms-overflow-style: none;
                scrollbar-width: none;
              }
            `}
      </style>
      {/* Header */}
      <div className="sticky top-0 z-50 bg-[#1b1b1b] border-b border-pink-300 py-6 px-8">
  <div className="max-w-10xl mx-auto flex items-left justify-start flex-col">
    <h1 className="text-4xl font-bold text-white">ACCOUNT SETTINGS</h1>
    <p className="text-gray-300 mt-3 font-bold">Manage your preferences and application configuration</p>
  </div>
</div>

      {/* Settings Content */}
      <div className="px-100 py-10 max-w-20xl">
        {/* Profile Section */}
        <div className="mb-6">
          <button
            onClick={() => toggleSection('profile')}
            className="w-full text-left bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-gray-800 flex items-center">
                <User className="w-5 h-5 mr-3 text-pink-500" />
                Profile Settings
              </h2>
              <ChevronDown className={`w-5 h-5 text-gray-500 transition-transform duration-200 ${expandedSections.profile ? 'transform rotate-180' : ''}`} />
            </div>
          </button>

          {expandedSections.profile && (
            <div className="mt-4 bg-white rounded-xl shadow-sm border border-gray-200">
              {/* Profile Picture */}
              <div className="p-6 border-b border-gray-100">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-6">
                    <div className="relative">
                      <div className="w-20 h-20 rounded-full bg-gray-200 overflow-hidden flex items-center justify-center">
                        {profile.profilePicture ? (
                          <img src={profile.profilePicture} alt="Profile" className="w-full h-full object-cover" />
                        ) : (
                          <User className="w-10 h-10 text-gray-400" />
                        )}
                      </div>
                      <label htmlFor="profile-picture" className="absolute bottom-0 right-0 w-7 h-7 bg-pink-500 rounded-full flex items-center justify-center cursor-pointer hover:bg-pink-600 transition-colors">
                        <Camera className="w-4 h-4 text-white" />
                        <input
                          id="profile-picture"
                          type="file"
                          accept="image/*"
                          onChange={handleProfilePictureChange}
                          className="hidden"
                        />
                      </label>
                    </div>
                    <div>
                      <h3 className="font-medium text-gray-800 mb-1">Profile Picture</h3>
                      <p className="text-sm text-gray-500">Upload a new profile picture</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Profile Name */}
              <div className="p-6 border-b border-gray-100">
                <div>
                  <h3 className="font-medium text-gray-800 mb-1">Profile Name</h3>
                  <p className="text-sm text-gray-500 mb-4">Change your display name</p>
                  <input
                    type="text"
                    value={profile.name}
                    onChange={(e) => handleProfileChange('name', e.target.value)}
                    className="w-full max-w-md px-4 py-2.5 border border-gray-300 rounded-lg bg-white text-gray-700 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                    placeholder="Enter your name"
                  />
                </div>
              </div>

              {/* Username */}
              <div className="p-6">
                <div>
                  <h3 className="font-medium text-gray-800 mb-1">Username</h3>
                  <p className="text-sm text-gray-500 mb-4">Change your unique username</p>
                  <input
                    type="text"
                    value={profile.username}
                    onChange={(e) => handleProfileChange('username', e.target.value)}
                    className="w-full max-w-md px-4 py-2.5 border border-gray-300 rounded-lg bg-white text-gray-700 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                    placeholder="Enter username"
                  />
                </div>
              </div>

              {/* Save Button */}
              <div className="p-6 border-t border-gray-100 bg-gray-50 rounded-b-xl">
                <button
                  onClick={handleSaveProfile}
                  className="px-6 py-2.5 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors font-medium"
                >
                  Save Profile Changes
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Security Section */}
        <div className="mb-6">
          <button
            onClick={() => toggleSection('security')}
            className="w-full text-left bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-gray-800 flex items-center">
                <Shield className="w-5 h-5 mr-3 text-pink-500" />
                Security & Privacy
              </h2>
              <ChevronDown className={`w-5 h-5 text-gray-500 transition-transform duration-200 ${expandedSections.security ? 'transform rotate-180' : ''}`} />
            </div>
          </button>

          {expandedSections.security && (
            <div className="mt-4 bg-white rounded-xl shadow-sm border border-gray-200">
              <div className="p-6">
                <div>
                  <h3 className="font-medium text-gray-800 mb-1">Change Password</h3>
                  <p className="text-sm text-gray-500 mb-6">Update your account password</p>

                  <div className="space-y-4 max-w-md">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Current Password
                      </label>
                      <input
                        type="password"
                        value={passwords.current}
                        onChange={(e) => handlePasswordChange('current', e.target.value)}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg bg-white text-gray-700 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                        placeholder="Enter current password"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        New Password
                      </label>
                      <input
                        type="password"
                        value={passwords.new}
                        onChange={(e) => handlePasswordChange('new', e.target.value)}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg bg-white text-gray-700 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                        placeholder="Enter new password"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Confirm New Password
                      </label>
                      <input
                        type="password"
                        value={passwords.confirm}
                        onChange={(e) => handlePasswordChange('confirm', e.target.value)}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg bg-white text-gray-700 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent"
                        placeholder="Confirm new password"
                      />
                    </div>

                    <button
                      onClick={handleSavePassword}
                      className="px-6 py-2.5 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors font-medium"
                    >
                      Change Password
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Account Section */}
        <div className="mb-12">
          <button
            onClick={() => toggleSection('account')}
            className="w-full text-left bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-gray-800 flex items-center">
                <User className="w-5 h-5 mr-3 text-pink-500" />
                Account
              </h2>
              <ChevronDown className={`w-5 h-5 text-gray-500 transition-transform duration-200 ${expandedSections.account ? 'transform rotate-180' : ''}`} />
            </div>
          </button>

          {expandedSections.account && (
            <div className="mt-4 bg-white rounded-xl shadow-sm border border-gray-200">
              <div className="p-6">
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <h3 className="font-medium text-red-600 mb-1">Delete Account</h3>
                    <p className="text-sm text-gray-500">Permanently delete your account and all data</p>
                  </div>
                  <button onClick={handleDeleteAccount}
                    className="px-6 py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-colors font-medium">
                    Delete
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Settings;