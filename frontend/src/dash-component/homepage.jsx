import React, { useState} from "react";
import postData from "./sample.json";
import PopupPost from "./popupPost";

const Homepage = () => {
    
    const [showPostModal, setShowPostModal] = useState(false);
    const placeholderData = Array.from({ length: 40 });

  return (
    <div className="w-full h-full relative flex flex-col gap-10 items-center bg-red-100 pt-6">
      {/* Search bar and icons row */}
      <div className="flex flex-row fixed items-center justify-between w-full max-w-4xl mt-1">
        <div className="flex-1 flex items-center">
          <input
            type="text"
            placeholder="Search"
            className="rounded-lg px-4 py-2 w-full max-w-lg text-black"
          />
          <button className="ml-2 text-black text-2xl">&#10006;</button>
        </div>
        <div className="flex items-center gap-20">
          <button onClick={() => setShowPostModal(true)} className="rounded-full w-10 h-10 transition-transform duration-200 hover:scale-105">
            <img 
            src="https://www.svgrepo.com/show/521942/add-ellipse.svg" 
            alt="" 
            className="w-10 h-10 object-cover rounded mb-2 transition-transform duration-200 hover:scale-105"
            />
          </button>
          <button className="text-black text-2xl">
            <span className="inline-block align-middle">🏆</span>
          </button>
          <button className="text-black text-2xl">
            <span className="inline-block align-middle">🔔</span>
          </button>
        </div>
      </div>

      {/* Grid of placeholders */}
      <div className="grid grid-cols-5 justify-items-center mt-60 mb-5 gap-8 h-full w-full max-w-[80%] mx-auto px-5 py-5 overflow-y-auto no-scrollbar">
        {placeholderData.map((_, idx) => (
          <div
            key={idx}
            className="border border-gray-700 rounded-lg h-[200px] w-[200px] bg-white flex flex-col items-center p-2 hover:scale-105 shadow-lg transition-shadow duration-200"
          >
            {/* Placeholder image */}
            <div className="w-[90%] h-[90%] h-32 bg-gray-200 rounded mb-2 flex items-center justify-center">
              {postData && postData.images && postData.images.length > 0 ? (
                <img
                  src={postData.images[2]}
                  alt="Image"
                  className="w-[190px] h-[150px] object-cover rounded"
                />
              ) : (
                <span className="text-gray-400 text-2xl"></span>
              )}
            </div>
            {/* Like/comment row */}
            <div className="flex justify-between items-center w-full px-2 pb-1">
              <div className="flex items-center gap-1 text-black">
                <span className="text-xl">&#9829;</span>
                <span className="text-sm">{postData?.likes ?? 0}</span>
              </div>
              <div className="flex items-center gap-1 text-black">
                <span className="text-xl">&#128172;</span>
                <span className="text-sm">{postData?.comments ? postData.comments.length : 0}</span>
              </div>
            </div>
          </div>
        ))}
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
      {showPostModal && (
        <PopupPost
          onClose={() => setShowPostModal(false)}
          onUpload={() => setShowPostModal(false)}
        />
      )}
    </div>
    );
};
export default Homepage;