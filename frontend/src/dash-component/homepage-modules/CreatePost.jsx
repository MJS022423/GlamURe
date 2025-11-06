import React, { useRef, useState } from "react";

const sampleTags = {
  Gender: ["Men", "Women", "Unisex"],
  Style: ["Casual", "Formal", "Streetwear", "Luxury", "Minimalist", "Bohemian", "Athletic", "Trendy", "Classic", "Edgy", "Elegant", "Modern", "Chic", "Urban", "Designer", "Fashionista"],
  Occasion: ["Everyday", "Workwear", "Partywear", "Outdoor", "Seasonal", "Special Event"],
  Material: ["Cotton", "Denim", "Leather", "Silk", "Wool", "Linen", "Synthetic", "Eco-Friendly", "Sustainable"],
  Color: ["Monochrome", "Colorful", "Neutral", "Pastel", "Bold", "Patterned"],
  Accessories: ["Footwear", "Bags", "Jewelry", "Hats", "Belts", "Scarves", "Sunglasses"],
  Features: ["Comfortable", "Layered", "Textured", "Statement", "Soft", "Versatile", "Functional"]
};

export default function CreatePost({ onClose, addPost }) {
  const fileInputRef = useRef(null);
  const [description, setDescription] = useState("");
  const [selectedImages, setSelectedImages] = useState([]);
  const [zoomedImage, setZoomedImage] = useState(null);
  const [showTags, setShowTags] = useState(false);
  const [selectedTags, setSelectedTags] = useState([]);

  const handleImageSelect = (e) => {
    const files = Array.from(e.target.files);
    const remainingSlots = 20 - selectedImages.length;

    if (files.length > remainingSlots) {
      alert(`You can only upload up to 20 images. You can add ${remainingSlots} more.`);
      e.target.value = null;
      return;
    }

    const images = files.map(file => ({ file, preview: URL.createObjectURL(file) }));
    setSelectedImages(prev => [...prev, ...images]);
    e.target.value = null;
  };

  const removeImage = (index) => setSelectedImages(prev => prev.filter((_, i) => i !== index));

  const toggleTag = (category, tag) => {
    setSelectedTags(prev => {
      const categoryTags = sampleTags[category];
      const isExclusive = ["Gender"].includes(category);
      let filtered = prev.filter(t => !categoryTags.includes(t));

      if (prev.includes(tag)) {
        return prev.filter(t => t !== tag);
      } else {
        return isExclusive ? [...filtered, tag] : [...prev, tag];
      }
    });
  };

  const handleUpload = () => {
    if (!description && selectedImages.length === 0) return;

    const newPost = {
      id: Date.now(),
      username: "Jzar Alaba",
      description,
      images: selectedImages.map(img => img.preview),
      tags: selectedTags,
      gender: selectedTags.find(t => sampleTags.Gender.includes(t)) || "Unisex",
      style: selectedTags.find(t => sampleTags.Style.includes(t)) || "Casual",
      likes: 0,
      comments: [],
      createdAt: new Date().toISOString(),
    };

    addPost(newPost);

    setDescription("");
    setSelectedImages([]);
    setSelectedTags([]);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-30 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/50" onClick={onClose} />
      <div className="relative w-[950px] max-w-[95%] bg-white rounded-3xl shadow-2xl border border-gray-200 overflow-hidden">
        {/* Header */}
        <div className="relative px-10 py-6 border-b">
          <h2 className="text-3xl font-bold text-gray-900 text-center">Create Post</h2>
          <button type="button" onClick={onClose} className="absolute top-5 right-5 text-gray-600 hover:text-gray-900 text-3xl leading-none">×</button>
        </div>

        {/* Body */}
        <div className="px-10 pt-8 pb-10 space-y-6">
          <div className="flex items-center gap-5 text-gray-900">
            <span className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-gray-200 text-3xl">👤</span>
            <span className="font-semibold text-xl">Jzar Alaba</span>
          </div>

          {/* Description */}
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full h-48 border rounded-2xl px-5 py-4 resize-none focus:outline-none focus:ring-2 focus:ring-gray-400 text-black placeholder-gray-500"
            placeholder="What's on your mind?"
          />

          {/* Tags */}
          <div className="flex flex-col gap-3">
            <button type="button" onClick={() => setShowTags(!showTags)} className="px-5 py-2 border rounded-2xl text-blue-600 font-semibold hover:bg-blue-50 w-max">+ Tags</button>
            <div className={`transition-all duration-300 overflow-hidden ${showTags ? "max-h-[600px]" : "max-h-0"}`}>
              {Object.entries(sampleTags).map(([category, tags]) => (
                <div key={category} className="mb-3">
                  <p className="font-semibold text-gray-700 mb-2">{category}</p>
                  <div className="flex flex-wrap gap-2">
                    {tags.map(tag => (
                      <button
                        key={tag}
                        onClick={() => toggleTag(category, tag)}
                        className={`px-3 py-1 rounded-full text-sm border transition-all duration-200
                          ${selectedTags.includes(tag)
                            ? "bg-blue-600 text-white border-blue-600"
                            : "bg-gray-100 text-gray-800 border-gray-300 hover:bg-gray-200"}`}
                      >
                        {tag}
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Image Upload */}
          <div className="flex flex-col gap-4">
            <button type="button" onClick={() => fileInputRef.current?.click()} className="px-5 py-3 border rounded-2xl text-lg font-semibold text-blue-600 hover:bg-blue-50 w-max">+ Add Images</button>
            <input ref={fileInputRef} type="file" multiple accept="image/*" className="hidden" onChange={handleImageSelect} />

            <div className="flex items-center gap-5 overflow-x-auto py-2">
              {selectedImages.map((img, idx) => (
                <div key={idx} className="relative flex-shrink-0">
                  <img src={img.preview} alt={`preview-${idx}`} className="w-36 h-36 object-cover rounded-2xl cursor-pointer hover:scale-105 transition-transform duration-200" onClick={() => setZoomedImage(img.preview)} />
                  <button onClick={() => removeImage(idx)} className="absolute top-1 right-1 bg-black/70 text-white rounded-full w-7 h-7 flex items-center justify-center text-sm">✖</button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-10 pb-8">
          <button type="button" onClick={handleUpload} className="w-full py-5 rounded-2xl bg-black text-white font-semibold text-xl hover:opacity-90">Upload Post</button>
        </div>
      </div>

      {zoomedImage && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-40 cursor-pointer" onClick={() => setZoomedImage(null)}>
          <img src={zoomedImage} alt="zoomed" className="max-h-[85%] max-w-[85%] rounded-2xl" />
        </div>
      )}
    </div>
  );
}
