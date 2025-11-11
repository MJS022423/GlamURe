import React, { useRef, useState } from "react";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

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

  const [selectedTags, setSelectedTags] = useState(["Men", "Casual"]);

  const handleImageSelect = (e) => {
    const fileList = e.target.files;
    if (!fileList || fileList.length === 0) return;
    if (fileList.length > 1) {
      alert("You can only upload 1 image. Extra files were ignored.");
    }
    const file = fileList[0];
    const preview = URL.createObjectURL(file);
    setSelectedImages([{ file, preview }]);
    e.target.value = null; // allow reselect same file
  };

  const removeImage = () => setSelectedImages([]);

  const toggleTag = (category, tag) => {
    setSelectedTags(prev => {
      const categoryTags = sampleTags[category] || [];
      const isGender = category === "Gender";
      const isStyle = category === "Style";

      if (prev.includes(tag)) {
        const next = prev.filter(t => t !== tag);
        if (isGender && !next.some(t => categoryTags.includes(t))) {
          return [...next, "Men"];
        }
        return next;
      }

      if (isGender) {
        const othersRemoved = prev.filter(t => !sampleTags.Gender.includes(t));
        return [...othersRemoved, tag];
      }

      if (isStyle) {
        return [...prev, tag];
      }

      return [...prev, tag];
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
    formData.append("userid", userId || "");
    formData.append("caption", description);
    formData.append("tags", JSON.stringify(selectedTags));
    formData.append("images", selectedImages[0].file);

    try {
      const res = await fetch(`${EXPRESS_API}/post/Addpost`, {
        method: "POST",
        headers: {
          Authorization: token ? `Bearer ${token}` : undefined
        },
        body: formData
      });

      let data = null;
      try { data = await res.json(); } catch { /* ignore */ }

      if (!res.ok) {
        const errMsg = (data && (data.error || data.message)) || `Failed to upload post (${res.status})`;
        throw new Error(errMsg);
      }

      // Close modal immediately after successful upload
      onClose?.();

      // Use server-returned post data if available, otherwise fallback
      const newPost = data && data.success && data.post ? data.post : {
        id: Date.now().toString(),
        username: localStorage.getItem("profile_name") || "You",
        description,
        images: [selectedImages[0].preview],
        tags: selectedTags,
        gender: selectedTags.find(t => sampleTags.Gender.includes(t)),
        style: selectedTags.find(t => sampleTags.Style.includes(t)),
        likes: 0,
        comments: [],
        createdAt: new Date().toISOString()
      };

      // Add post to parent feed
      addPost(newPost);

      // Reset form
      setDescription("");
      setSelectedImages([]);
      setSelectedTags(["Men", "Casual"]);

    } catch (error) {
      console.error("Upload failed:", error);
      alert(error.message || "Something went wrong — please try again.");
    }
  };

  // small helper to check selection
  const isTagSelected = (tag) => selectedTags.includes(tag);

  return (
    <div className="fixed inset-0 z-30 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/50" onClick={onClose} />

      <div className="relative flex gap-6 z-10 max-w-[95%] items-start">
        {/* Main card */}
        <div className="w-[470px] bg-white rounded-3xl shadow-2xl border border-gray-200 flex-shrink-0 overflow-hidden">
          <div className="relative px-6 py-4 border-b">
            <h2 className="text-2xl font-bold text-gray-900 text-center">Create Post</h2>
            <button
              type="button"
              onClick={onClose}
              className="absolute top-3 right-3 text-gray-600 text-2xl leading-none hover:text-gray-900 hover:scale-105 transition-transform duration-200"
            >×</button>
          </div>

          <div className="px-6 pt-4 pb-6 space-y-4 max-h-[600px] overflow-y-auto">
            <div className="flex items-center gap-4 text-gray-900">
              <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-200 text-2xl">👤</span>
              <div>
                <div className="font-semibold text-lg">{localStorage.getItem("profile_name") || "You"}</div>
                <div className="text-sm text-gray-500">{localStorage.getItem("profile_email") || ""}</div>
              </div>
            </div>

            <div className="relative">
              <textarea
                value={description}
                maxLength={100}
                onChange={(e) => setDescription(e.target.value)}
                className="w-full h-32 border rounded-2xl px-4 py-3 resize-none focus:outline-none focus:ring-2 focus:ring-gray-400 text-black placeholder-gray-500"
                placeholder="What's on your mind?"
              />
              <span className="absolute bottom-2 right-4 text-gray-500 text-sm">{description.length}/100</span>
            </div>

            {/* Controls row: left = buttons, right = preview */}
            <div className="flex items-center gap-4">
              <div className="flex flex-col gap-3">
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="px-4 py-2 border rounded-2xl text-blue-600 font-semibold hover:bg-blue-50 transition-transform duration-200"
                >
                  {selectedImages.length ? "Change Image" : "+ Add Image"}
                </button>

                <button
                  type="button"
                  onClick={() => setShowTags(true)}
                  className="px-4 py-2 border rounded-2xl text-blue-600 font-semibold hover:bg-blue-50 transition-transform duration-200"
                >
                  + Tags
                </button>
              </div>

              {/* preview on right */}
              <div className="ml-auto">
                {selectedImages.length ? (
                  <div className="relative w-24 h-24 rounded-2xl overflow-hidden border">
                    <img
                      src={selectedImages[0].preview}
                      alt="preview"
                      className="w-full h-full object-cover"
                      onClick={() => setZoomedImage(selectedImages[0].preview)}
                    />
                    <button
                      onClick={removeImage}
                      className="absolute top-1 right-1 bg-black/70 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm"
                    >✖</button>
                  </div>
                ) : (
                  <div className="w-24 h-24 rounded-2xl bg-gray-100 flex items-center justify-center text-gray-400 border">
                    No image
                  </div>
                )}
              </div>
            </div>
          </div>

          <div className="px-6 pb-4">
            <button
              type="button"
              onClick={handleUpload}
              disabled={selectedImages.length === 0}
              className={`w-full py-3 rounded-2xl text-white font-semibold text-lg ${selectedImages.length === 0 ? "bg-gray-400 cursor-not-allowed" : "bg-black hover:opacity-90 transition-transform duration-200"}`}
            >
              Upload Post
            </button>
          </div>
        </div>

        {/* Tags drawer */}
        {showTags && (
          <div className="w-[470px] bg-white rounded-3xl shadow-2xl border border-gray-200 overflow-hidden flex-shrink-0 flex flex-col animate-slide-in">
            <div className="flex justify-between items-center p-4 border-b">
              <h3 className="text-xl font-bold text-gray-900">Select Tags</h3>
              <button onClick={() => setShowTags(false)} className="text-xl font-bold text-gray-600 hover:text-gray-900">×</button>
            </div>

            <div className="p-4 overflow-y-auto max-h-[600px] space-y-4">
              {Object.entries(sampleTags).map(([category, tags]) => (
                <div key={category}>
                  <p className="font-semibold text-gray-700 mb-2">{category}</p>
                  <div className="flex flex-wrap gap-2">
                    {tags.map(tag => {
                      const active = isTagSelected(tag);
                      // gender is exclusive single-choice; style is multi
                      return (
                        <button
                          key={tag}
                          onClick={() => toggleTag(category, tag)}
                          className={`px-3 py-1 rounded-full text-sm border transition-all duration-200 ${active ? "bg-blue-600 text-white border-blue-600" : "bg-gray-100 text-gray-800 border-gray-300 hover:bg-gray-200"}`}
                        >
                          {tag}
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Zoom preview */}
      {zoomedImage && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-40 cursor-pointer" onClick={() => setZoomedImage(null)}>
          <img src={zoomedImage} alt="zoomed" className="max-h-[85%] max-w-[85%] rounded-2xl" />
        </div>
      )}

      <style jsx>{`
        @keyframes slide-in { from { transform: translateX(-20px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        .animate-slide-in { animation: slide-in 0.22s ease-out; }
      `}</style>

      {/* hidden single-file input */}
      <input ref={fileInputRef} type="file" accept="image/*" className="hidden" onChange={handleImageSelect} />
    </div>
  );
}
