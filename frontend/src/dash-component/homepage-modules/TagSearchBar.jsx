import React, { useState } from "react";

// Sample tags grouped by category
const sampleTags = {
  Gender: ["Men", "Women", "Unisex"],
  Style: [
    "Casual", "Formal", "Streetwear", "Luxury", "Minimalist", "Bohemian",
    "Athletic", "Trendy", "Classic", "Edgy", "Elegant", "Modern", "Chic",
    "Urban", "Designer", "Fashionista"
  ],
  Occasion: ["Everyday", "Workwear", "Partywear", "Outdoor", "Seasonal", "Special Event"],
  Material: ["Cotton", "Denim", "Leather", "Silk", "Wool", "Linen", "Synthetic", "Eco-Friendly", "Sustainable"],
  Color: ["Monochrome", "Colorful", "Neutral", "Pastel", "Bold", "Patterned"],
  Accessories: ["Footwear", "Bags", "Jewelry", "Hats", "Belts", "Scarves", "Sunglasses"],
  Features: ["Comfortable", "Layered", "Textured", "Statement", "Soft", "Versatile", "Functional"]
};

// Flatten all tags into a single array
const ALL_TAGS = Object.values(sampleTags).flat();

export default function TagSearchBar({ onSearch }) {
  const [searchInput, setSearchInput] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [selectedTags, setSelectedTags] = useState([]);

  // Show suggestions as user types
  const handleChange = (e) => {
    const value = e.target.value;
    setSearchInput(value);

    if (!value.trim()) {
      setSuggestions([]);
      return;
    }

    const filtered = ALL_TAGS.filter(
      tag =>
        tag.toLowerCase().includes(value.toLowerCase()) &&
        !selectedTags.includes(tag)
    );
    setSuggestions(filtered);
  };

  // Add a tag when selected from suggestions
  const handleSelectTag = (tag) => {
    const updatedTags = [...selectedTags, tag];
    setSelectedTags(updatedTags);
    setSearchInput("");
    setSuggestions([]);
    if (onSearch) onSearch(updatedTags);
  };

  // Remove a tag from selected list
  const handleRemoveTag = (tagToRemove) => {
    const updatedTags = selectedTags.filter(tag => tag !== tagToRemove);
    setSelectedTags(updatedTags);
    if (onSearch) onSearch(updatedTags);
  };

  // Clear input
  const handleClearInput = () => {
    setSearchInput("");
    setSuggestions([]);
  };

  return (
    <div className="relative w-full max-w-lg">
      <div className="flex flex-wrap items-center gap-2 border border-gray-800 rounded-lg px-2 py-1 focus-within:ring-2 focus-within:ring-pink-400">
        {selectedTags.map((tag, idx) => (
          <div
            key={idx}
            className="flex items-center bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium cursor-pointer hover:bg-blue-200 transition-all duration-200 transform hover:scale-105"
            onClick={() => handleRemoveTag(tag)}
            title="Click to remove"
          >
            {tag} ×
          </div>
        ))}

        <input
          type="text"
          value={searchInput}
          onChange={handleChange}
          placeholder="Search tags..."
          className="flex-1 min-w-[120px] px-2 py-1 text-black focus:outline-none"
        />
        {searchInput && (
          <button onClick={handleClearInput} className="ml-1 text-black text-xl">&#10006;</button>
        )}
      </div>

      {suggestions.length > 0 && (
        <div className="absolute mt-1 w-full bg-white border border-gray-300 rounded-lg shadow-lg z-10 max-h-48 overflow-y-auto">
          {suggestions.map((tag, idx) => (
            <div
              key={idx}
              onClick={() => handleSelectTag(tag)}
              className="px-4 py-2 cursor-pointer hover:bg-gray-200 text-black transition-colors duration-200"
            >
              {tag}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
