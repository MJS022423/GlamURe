import React, {useState} from 'react';
import { Link } from 'react-router-dom';
import '../style/sidebar.css';

import home from '../assets/home.svg'; // your home image
import bookmark from '../assets/bookmark.svg'; // your bookmark image
import message from '../assets/message.svg'; // your message image
import profile from '../assets/profile.svg'; // your profile image
import settings from '../assets/settings.svg'; // your settings image
import info from '../assets/info.svg'; // your info image
import logout from '../assets/logout.svg'; // your logout image

const Sidebar = () => {
    const [activeMenu, setActiveMenu] = useState("Home");
    const [isExpanded, setIsExpanded] = useState(false);

    const menuItems = [
      { name: "Home", icon: home },
      { name: "Bookmark", icon: bookmark },
      { name: "Message", icon: message },
      { name: "Profile", icon: profile },
      { name: "Settings", icon: settings },
      { name: "About Us", icon: info },
    ];
    return (
        <aside
            className={`sidebar ${isExpanded ? "expanded" : ""}`}
            onMouseEnter={() => setIsExpanded(true)}
            onMouseLeave={() => setIsExpanded(false)}
            >
            <div className="profile-section">
                <div className='userprofile'></div>
                <h3>NAME</h3>
                <p>Designer</p>
            </div>
            <ul>
                {menuItems.map((item) => (
                    <li key={item.name}>
                        <button
                        className={`sidebar-btn ${
                            activeMenu === item.name ? "active" : ""
                        }`}
                        onClick={() => setActiveMenu(item.name)}
                        >
                        <img src={item.icon} alt={item.name} className="menu-icon" />
                        <span>{item.name}</span>
                        </button>
                    </li>
                ))}
            </ul>
            <div className="logout-section">
                <img src={logout} alt="Logout" className="menu-icon" />
                <span>Logout</span>
            </div>
        </aside>
    )
}
export default Sidebar;