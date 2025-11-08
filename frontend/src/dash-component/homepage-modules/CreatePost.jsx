import React, { useRef, useState } from "react";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API

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

export default function CreatePost({ onClose, addPost }) {
  const fileInputRef = useRef(null);
  const [description, setDescription] = useState("");
  const [selectedImages, setSelectedImages] = useState([]);
  const [zoomedImage, setZoomedImage] = useState(null);
  const [showTags, setShowTags] = useState(false);
  const [selectedTags, setSelectedTags] = useState([]);

  const handleImageSelect = (e) => {
    const files = Array.from(e.target.files);
    const remainingSlots = 1;

    if (files.length > remainingSlots) {
      alert(`You can only upload up to 1 image.`);
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
      const filtered = prev.filter(t => !categoryTags.includes(t));
      if (prev.includes(tag)) return prev.filter(t => t !== tag);
      return isExclusive ? [...filtered, tag] : [...prev, tag];
    });
  };

  const handleUpload = async () => {
    const token = localStorage.getItem("token");
    const userId = localStorage.getItem("userid");
    if (selectedImages.length === 0) {
      alert("You must add at least one image to post.");
      return;
    }

    const formData = new FormData();
    formData.append("userid", userId);
    formData.append("caption", description);
    formData.append("tags", JSON.stringify(selectedTags));

    selectedImages.forEach((img) => {
      formData.append("images", img.file); // each image file
    });
    try {
      const res = await fetch(`${EXPRESS_API}/post/Addpost`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      if (!res.ok) {
        throw new Error(data.error || "Failed to upload post");
      }

      console.log("✅ Post uploaded successfully:", data);
      alert("Post uploaded successfully!");
      
      setDescription("");
      setSelectedImages([]);
      setSelectedTags([]);
      onClose();

    } catch (error) {
      alert("Something went wrong please try again.");
    }

    // const newPost = {
    //   id: Date.now(),
    //   username: "Jzar Alaba",
    //   description,
    //   images: selectedImages.map(img => img.preview),
    //   tags: selectedTags,
    //   gender: selectedTags.find(t => sampleTags.Gender.includes(t)) || "Unisex",
    //   style: selectedTags.find(t => sampleTags.Style.includes(t)) || "Casual",
    //   likes: 0,
    //   comments: [],
    //   createdAt: new Date().toISOString(),
    // };

    // addPost(newPost);

    // reset state
  };

  return (
    <div className="fixed inset-0 z-30 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/50" onClick={onClose} />

      <div className="relative flex gap-6 z-10 max-w-[95%] items-start">
        <div className="w-[470px] bg-white rounded-3xl shadow-2xl border border-gray-200 flex-shrink-0 overflow-hidden">
          {/* Header */}
          <div className="relative px-6 py-4 border-b">
            <h2 className="text-2xl font-bold text-gray-900 text-center">Create Post</h2>
            <button
              type="button"
              onClick={onClose}
              className="absolute top-3 right-3 text-gray-600 text-2xl leading-none hover:text-gray-900 hover:scale-105 transition-transform duration-200"
            >
              ×
            </button>
          </div>

          {/* Body */}
          <div className="px-6 pt-4 pb-6 space-y-4 max-h-[600px] overflow-y-auto">
            <div className="flex items-center gap-4 text-gray-900">
              <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-200 text-2xl">👤</span>
              <span className="font-semibold text-lg">Jzar Alaba</span>
            </div>

            <div className="relative">
              <textarea
                value={description}
                maxLength={100} // limit to 100 characters
                onChange={(e) => setDescription(e.target.value)}
                className="w-full h-32 border rounded-2xl px-4 py-3 resize-none focus:outline-none focus:ring-2 focus:ring-gray-400 text-black placeholder-gray-500"
                placeholder="What's on your mind?"
              />
              <span className="absolute bottom-2 right-4 text-gray-500 text-sm">{description.length}/100</span>
            </div>

            <button
              type="button"
              onClick={() => setShowTags(true)}
              className="px-4 py-2 border rounded-2xl text-blue-600 font-semibold hover:bg-blue-50 hover:scale-105 transition-transform duration-200 w-max"
            >
              + Tags
            </button>

            <div className="flex flex-col gap-2">
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="px-4 py-2 border rounded-2xl text-blue-600 font-semibold hover:bg-blue-50 hover:scale-105 transition-transform duration-200 w-max"
              >
                + Add Image
              </button>
              <input ref={fileInputRef} type="file" multiple accept="image/*" className="hidden" onChange={handleImageSelect} />

              <div className="flex items-center gap-3 overflow-x-auto py-2">
                {selectedImages.map((img, idx) => (
                  <div key={idx} className="relative flex-shrink-0">
                    <img
                      src={img.preview}
                      alt={`preview-${idx}`}
                      className="w-28 h-28 object-cover rounded-2xl cursor-pointer hover:scale-105 transition-transform duration-200"
                      onClick={() => setZoomedImage(img.preview)}
                    />
                    <button
                      onClick={() => removeImage(idx)}
                      className="absolute top-1 right-1 bg-black/70 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm hover:scale-110 transition-transform duration-200"
                    >
                      ✖
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="px-6 pb-4">
            <button
              type="button"
              onClick={handleUpload}
              className={`w-full py-3 rounded-2xl text-white font-semibold text-lg ${selectedImages.length === 0 ? "bg-gray-400 cursor-not-allowed" : "bg-black hover:opacity-90 hover:scale-105 transition-transform duration-200"}`}
              disabled={selectedImages.length === 0}
            >
              Upload Post
            </button>
          </div>
        </div>

        {/* Tags card */}
        {showTags && (
          <div className="w-[470px] bg-white rounded-3xl shadow-2xl border border-gray-200 overflow-hidden flex-shrink-0 flex flex-col animate-slide-in">
            <div className="flex justify-between items-center p-4 border-b">
              <h3 className="text-xl font-bold text-gray-900">Select Tags</h3>
              <button
                onClick={() => setShowTags(false)}
                className="text-xl font-bold text-gray-600 hover:text-gray-900 hover:scale-105 transition-transform duration-200"
              >
                ×
              </button>
            </div>

            <div className="p-4 overflow-y-auto max-h-[600px] space-y-4">
              {Object.entries(sampleTags).map(([category, tags]) => (
                <div key={category}>
                  <p className="font-semibold text-gray-700 mb-2">{category}</p>
                  <div className="flex flex-wrap gap-2">
                    {tags.map(tag => (
                      <button
                        key={tag}
                        onClick={() => toggleTag(category, tag)}
                        className={`px-3 py-1 rounded-full text-sm border transition-all duration-200 ${selectedTags.includes(tag) ? "bg-blue-600 text-white border-blue-600" : "bg-gray-100 text-gray-800 border-gray-300 hover:bg-gray-200 hover:scale-105"}`}
                      >
                        {tag}
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Zoomed Image */}
      {zoomedImage && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-40 cursor-pointer" onClick={() => setZoomedImage(null)}>
          <img src={zoomedImage} alt="zoomed" className="max-h-[85%] max-w-[85%] rounded-2xl" />
        </div>
      )}

      <style jsx>{`
          @keyframes slide-in { from { transform: translateX(-20px); opacity: 0; } to { transform: translateX(0); opacity: 1; } 
          .animate-slide-in { animation: slide-in 0.3s ease-out; }
        `}</style>
    </div>
  );
}
