import { useState } from "react";
import {
  Heart,
  Eye,
  MessageSquare,
  Plus,
  User,
  ChevronLeft,
} from "lucide-react";

export default function ProfilePage() {
  const [activeTab, setActiveTab] = useState("profile");

  // Sample data
  const designer = {
    name: "Designer",
    email: "user@gmail.com",
    likes: 0,
    followers: 0,
    posts: 0,
    facebook: "NAME",
    instagram: "USERNAME",
    twitter: "USERNAME",
    contact: "09123456789",
  };

  const topDesigns = [
    {
      id: 1,
      image:
        "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400",
      likes: "4.2k",
      views: "21",
    },
    {
      id: 2,
      image:
        "https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=400",
      likes: "33.2k",
      views: "1k",
    },
    {
      id: 3,
      image:
        "https://images.unsplash.com/photo-1617127365659-c47c5007f80f?w=400",
      likes: "40.3k",
      views: "800",
    },
  ];

  const posts = [
    {
      id: 1,
      image:
        "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400",
      likes: "2.1k",
      views: "200",
    },
    {
      id: 2,
      image:
        "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400",
      likes: "1.2k",
      views: "150",
    },
    {
      id: 3,
      image:
        "https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400",
      likes: "2k",
      views: "250",
    },
    {
      id: 4,
      image:
        "https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=400",
      likes: "3k",
      views: "500",
    },
  ];

  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] text-white overflow-hidden">
      {/* Header */}
      <div className="bg-black/40 backdrop-blur-sm border-b border-pink-300 p-6 flex items-center justify-between sticky top-0 z-10">
        <div className="flex items-center gap-4">
          <ChevronLeft className="w-6 h-6 text-pink-300 cursor-pointer" />
          <h1 className="text-2xl font-bold text-pink-200 tracking-wide">
            PROFILE
          </h1>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-3xl font-extrabold text-pink-200">Glamur'e</div>
          <div className="text-xl text-white font-semibold">APPAREL</div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-8 flex-1">
        <div className="flex flex-col lg:flex-row gap-10">
          {/* Left Side - Profile Info */}
          <div className="lg:w-1/3">
            <div className="bg-pink-100 text-black rounded-3xl p-6 mb-6 shadow-md">
              <div className="flex items-center gap-4 mb-6">
                <div className="w-24 h-24 bg-pink-300 rounded-full flex items-center justify-center">
                  <User className="w-12 h-12 text-black" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-gray-900">NAME</h2>
                  <p className="text-gray-700">{designer.name}</p>
                </div>
              </div>

              {/* Stats */}
              <div className="flex justify-around mb-6">
                <div className="text-center">
                  <div className="text-xs font-semibold text-gray-600 mb-1">
                    LIKES
                  </div>
                  <div className="text-lg font-bold text-gray-900">
                    {designer.likes}
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-xs font-semibold text-gray-600 mb-1">
                    FOLLOWERS
                  </div>
                  <div className="text-lg font-bold text-gray-900">
                    {designer.followers}
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-xs font-semibold text-gray-600 mb-1">
                    POSTS
                  </div>
                  <div className="text-lg font-bold text-gray-900">
                    {designer.posts}
                  </div>
                </div>
              </div>

              <button className="w-full bg-black text-pink-200 font-semibold py-3 rounded-full flex items-center justify-center gap-2 hover:bg-pink-300 hover:text-black transition">
                <Plus className="w-5 h-5" />
                Add Post
              </button>
            </div>

            <div className="bg-pink-100 text-black rounded-3xl p-6 shadow-md">
              <h3 className="text-lg font-bold mb-4">DESIGNER INFO</h3>
              <div className="space-y-2 text-sm">
                <p>
                  <span className="font-semibold">E-MAIL:</span>{" "}
                  {designer.email}
                </p>
                <p className="font-semibold">Social Medias:</p>
                <p>FB: {designer.facebook}</p>
                <p>IG: {designer.instagram}</p>
                <p>TWITTER: {designer.twitter}</p>
                <p>
                  <span className="font-semibold">CONTACT:</span>{" "}
                  {designer.contact}
                </p>
              </div>
            </div>
          </div>

          {/* Right Side - Designs */}
          <div className="flex-1">
            {/* Top 3 Designs */}
            <div className="mb-8">
              <div className="flex items-center gap-2 mb-4">
                <h3 className="text-xl font-bold text-pink-200">
                  TOP 3 DESIGNS
                </h3>
                <span className="text-2xl">🔥</span>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {topDesigns.map((design) => (
                  <div
                    key={design.id}
                    className="bg-pink-100 text-black rounded-2xl overflow-hidden shadow-md"
                  >
                    <div className="aspect-square">
                      <img
                        src={design.image}
                        alt="Design"
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="p-3 flex items-center justify-between bg-pink-200">
                      <div className="flex items-center gap-3 text-xs">
                        <div className="flex items-center gap-1">
                          <Heart className="w-4 h-4 text-black" />
                          <span className="font-semibold">{design.likes}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Eye className="w-4 h-4 text-black" />
                          <span className="font-semibold">{design.views}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <MessageSquare className="w-4 h-4 text-black" />
                          <span className="font-semibold">Chat</span>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Posts */}
            <div>
              <h3 className="text-xl font-bold text-pink-200 mb-4">POSTS</h3>
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
                {posts.map((post) => (
                  <div
                    key={post.id}
                    className="bg-pink-100 text-black rounded-2xl overflow-hidden shadow-md"
                  >
                    <div className="aspect-square">
                      <img
                        src={post.image}
                        alt="Post"
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="p-3 flex items-center justify-between bg-pink-200">
                      <div className="flex items-center gap-2 text-xs">
                        <div className="flex items-center gap-1">
                          <Heart className="w-3 h-3 text-black" />
                          <span className="font-semibold">{post.likes}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Eye className="w-3 h-3 text-black" />
                          <span className="font-semibold">{post.views}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <MessageSquare className="w-3 h-3 text-black" />
                          <span className="font-semibold">Chat</span>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
