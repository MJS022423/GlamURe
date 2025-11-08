import React, { useEffect, useState } from "react";
import { ChevronLeft, X } from "lucide-react";

const GlamureBookmarks = () => {
  const [selectedDesign, setSelectedDesign] = useState(null);
  const [designs, setDesigns] = useState([]);

  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem("bookmarks") || "[]");
      setDesigns(saved);
    } catch {}

    const onStorage = (e) => {
      if (e.key === "bookmarks") {
        try { setDesigns(JSON.parse(e.newValue || "[]")); } catch {}
      }
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const collections = [
    { id: 9, image: "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400&h=500&fit=crop", title: "Spring Collection", description: "Fresh and vibrant spring styles" },
    { id: 10, image: "https://images.unsplash.com/photo-1558769132-cb1aea37f5ce?w=400&h=500&fit=crop", title: "Winter Styles", description: "Cozy winter fashion collection" },
    { id: 11, image: "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400&h=500&fit=crop", title: "Accessories", description: "Complete your look with accessories" },
    { id: 12, image: "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=500&fit=crop", title: "Luxury Items", description: "Premium luxury fashion pieces" },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-200 via-pink-100 to-pink-50">
      {/* Header */}
      <div className={`transition-colors duration-500 py-6 px-8 ${
        selectedDesign 
          ? 'bg-gradient-to-r from-rose-400 to-pink-300' 
          : 'bg-gradient-to-r from-purple-300 to-pink-200'
      }`}>
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button 
              onClick={() => selectedDesign && setSelectedDesign(null)}
              className="p-2 hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-800" />
            </button>
            <h1 className="text-4xl font-bold text-gray-800">
              {selectedDesign ? selectedDesign.title : 'BOOKMARKS'}
            </h1>
          </div>
          <div className="flex items-center gap-6">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-white bg-opacity-50 rounded-lg flex items-center justify-center">
                <span className="text-purple-500 text-xl">💎</span>
              </div>
              <span className="text-xl font-semibold text-gray-800">Glamur'e</span>
            </div>
            <span className="text-xl font-semibold text-gray-800">APPAREL</span>
          </div>
        </div>
      </div>

      {/* Main Content */}
      {!selectedDesign ? (
        <div className="max-w-7xl mx-auto p-8">
          {/* Saved Designs Section */}
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-gray-800 mb-6">Saved Designs</h2>
            {designs.length === 0 ? (
              <div className="text-gray-600">No bookmarks yet. Save posts using the bookmark icon.</div>
            ) : (
              <div className="grid grid-cols-4 gap-6">
                {designs.map(design => (
                  <DesignCard 
                    key={design.id}
                    design={design}
                    onClick={() => setSelectedDesign(design)}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Collections Section */}
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-gray-800 mb-6">Collections</h2>
            <div className="grid grid-cols-4 gap-6">
              {collections.map(design => (
                <DesignCard 
                  key={design.id}
                  design={design}
                  onClick={() => setSelectedDesign(design)}
                />
              ))}
            </div>
          </div>
        </div>
      ) : (
        <ExpandedView design={selectedDesign} onClose={() => setSelectedDesign(null)} />
      )}
    </div>
  );
};

const DesignCard = ({ design, onClick }) => (
  <div 
    onClick={onClick}
    className="bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl hover:scale-105 transition-all cursor-pointer"
  >
    <div className="aspect-[3/4] bg-gray-100 overflow-hidden">
      <img 
        src={design.image} 
        alt={design.title}
        className="w-full h-full object-cover"
      />
    </div>
    <div className="p-4">
      <h3 className="font-semibold text-gray-800 text-center">{design.title}</h3>
    </div>
  </div>
);

const ExpandedView = ({ design, onClose }) => (
  <div className="max-w-7xl mx-auto p-8 animate-fadeIn">
    <button
      onClick={onClose}
      className="mb-6 flex items-center gap-2 px-4 py-2 bg-white bg-opacity-50 hover:bg-opacity-70 rounded-lg transition-colors"
    >
      <X className="w-5 h-5" />
      <span className="font-semibold">Close</span>
    </button>
    
    <div className="grid grid-cols-2 gap-8">
      {/* Image Section */}
      <div className="bg-white rounded-3xl overflow-hidden shadow-2xl">
        <img 
          src={design.image} 
          alt={design.title}
          className="w-full h-full object-cover"
        />
      </div>

      {/* Details Section */}
      <div className="space-y-6">
        <div className="bg-white rounded-3xl p-8 shadow-xl">
          <h2 className="text-3xl font-bold text-gray-800 mb-4">{design.title}</h2>
          <p className="text-gray-600 text-lg mb-6">{design.description}</p>
          
          <div className="space-y-4">
            <div className="flex justify-between items-center py-3 border-b border-gray-200">
              <span className="font-semibold text-gray-700">Category:</span>
              <span className="text-gray-600">Apparel</span>
            </div>
            <div className="flex justify-between items-center py-3 border-b border-gray-200">
              <span className="font-semibold text-gray-700">Collection:</span>
              <span className="text-gray-600">2024 Season</span>
            </div>
            <div className="flex justify-between items-center py-3 border-b border-gray-200">
              <span className="font-semibold text-gray-700">Saved Date:</span>
              <span className="text-gray-600">Nov 7, 2025</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-3xl p-8 shadow-xl">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Design Notes</h3>
          <p className="text-gray-600">
            This design represents a perfect blend of elegance and modern style. 
            The attention to detail and craftsmanship makes it a standout piece 
            in the collection.
          </p>
        </div>

        <div className="flex gap-4">
          <button className="flex-1 bg-gradient-to-r from-pink-400 to-rose-400 text-white font-semibold py-4 rounded-xl hover:shadow-lg transition-all">
            View Full Collection
          </button>
          <button className="flex-1 bg-white text-gray-800 font-semibold py-4 rounded-xl hover:shadow-lg transition-all">
            Share Design
          </button>
        </div>
      </div>
    </div>
  </div>
);

export default GlamureBookmarks;