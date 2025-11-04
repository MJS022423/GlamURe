import React, {useState} from "react";
import '../style/header.css'; // your CSS file

import icon from '../assets/file.svg'; // your icon image
import search from '../assets/search.svg'; // your search image
import bell from '../assets/bell.svg'; // your bell image
import rank from '../assets/leaderboard.svg'; // your rank image
import job from '../assets/suitcase.svg'; // your job image

const Header = () => {
    const [isSearchActive, setIsSearchActive] = useState(false);
    const [searchText, setSearchText] = useState("");

    const handleActivateSearch = () => {
    setIsSearchActive(true);
    };

    const handleCloseSearch = (e) => {
        e.stopPropagation(); // Prevent re-triggering when clicking close
        setIsSearchActive(false);
        setSearchText("");
    };
    return(
        <header className="dheader fixed top-0 flex flex-wrap z-50 relative justify-evenly ">
            <img src={icon} className="appicon" alt="" />
            <div id="searchbar" className={`search ${isSearchActive ? "active" : ""}`} 
                onClick={handleActivateSearch}>
                <img
                    src={search}
                    className="searchicon"
                    alt="search"
                    onClick={() => setIsSearchActive(true)}
                />
                 <input
                    type="text"
                    className={`searchinput ${isSearchActive ? "show" : ""}`}
                    placeholder=""
                    value={searchText}
                    onChange={(e) => setSearchText(e.target.value)}
                    onClick={(e) => e.stopPropagation()} // allows typing without closing
                />
                {isSearchActive && (
                    <button className="closebtn" onClick={handleCloseSearch}>
                    ✕
                    </button>
                )}
            </div>
            <div className="nav-item">
            <img src={rank} className="rankicon" alt="" />
            </div>
            <div className="nav-item">
            <img src={bell} className="bellicon" alt="" />
            </div>
            <div className="nav-item">
            <img src={job} className="jobicon" alt="" />
            </div>
        </header>
    )
}

export default Header;