import { useState } from 'react';
import { Home, Bookmark, MessageCircle, User, Info, Settings, LogOut, Heart, Eye, MessageSquare, Plus, ChevronLeft } from 'lucide-react';

export default function ProfilePage() {
  const [activeTab, setActiveTab] = useState('profile');

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
    contact: "09123456789"
  };

  const topDesigns = [
    { id: 1, image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400", likes: "4.2k", views: "21", comments: 0 },
    { id: 2, image: "https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=400", likes: "33.2k", views: "1k", comments: 0 },
    { id: 3, image: "https://images.unsplash.com/photo-1617127365659-c47c5007f80f?w=400", likes: "40.3k", views: "800", comments: 0 }
  ];

  const posts = [
    { id: 1, image: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400", likes: "2.1k", views: "200", comments: 0 },
    { id: 2, image: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400", likes: "1.2k", views: "150", comments: 0 },
    { id: 3, image: "https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400", likes: "2k", views: "250", comments: 0 },
    { id: 4, image: "https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=400", likes: "3k", views: "500", comments: 0 }
  ];

  return (
    <div className="flex h-screen bg-pink-100 overflow-hidden">
      {/* Sidebar */}
      <div className="w-64 bg-pink-200 flex flex-col">
        {/* Logo */}
        <div className="p-6 flex items-center justify-center">
          <div className="w-12 h-12 bg-pink-400 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-xl">G</span>
          </div>
        </div>

        {/* User Profile Card */}
        <div className="px-6 mb-6">
          <div className="bg-pink-300 rounded-2xl p-4 text-center">
            <div className="w-16 h-16 bg-pink-400 rounded-full mx-auto mb-2 flex items-center justify-center">
              <User className="w-8 h-8 text-white" />
            </div>
            <p className="text-xs font-semibold text-gray-700">NAME</p>
            <p className="text-xs text-gray-600">Designer</p>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-4">
          <button 
            onClick={() => setActiveTab('home')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition ${activeTab === 'home' ? 'bg-pink-300' : 'hover:bg-pink-300'}`}
          >
            <Home className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">Home</span>
          </button>
          
          <button 
            onClick={() => setActiveTab('bookmarks')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition ${activeTab === 'bookmarks' ? 'bg-pink-300' : 'hover:bg-pink-300'}`}
          >
            <Bookmark className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">Bookmarks</span>
          </button>
          
          <button 
            onClick={() => setActiveTab('messages')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition ${activeTab === 'messages' ? 'bg-pink-300' : 'hover:bg-pink-300'}`}
          >
            <MessageCircle className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">Messages</span>
          </button>
          
          <button 
            onClick={() => setActiveTab('profile')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition ${activeTab === 'profile' ? 'bg-pink-300' : 'hover:bg-pink-300'}`}
          >
            <User className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">Profile</span>
            <ChevronLeft className="w-4 h-4 ml-auto text-gray-600" />
          </button>
          
          <button 
            onClick={() => setActiveTab('about')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition ${activeTab === 'about' ? 'bg-pink-300' : 'hover:bg-pink-300'}`}
          >
            <Info className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">About Us</span>
          </button>
          
          <button 
            onClick={() => setActiveTab('settings')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition ${activeTab === 'settings' ? 'bg-pink-300' : 'hover:bg-pink-300'}`}
          >
            <Settings className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">Settings</span>
          </button>
        </nav>

        {/* Logout */}
        <div className="p-4">
          <button className="w-full flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-pink-300 transition">
            <LogOut className="w-5 h-5 text-pink-600" />
            <span className="text-sm font-medium text-gray-700">Logout</span>
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-y-auto">
        {/* Header */}
        <div className="bg-pink-100 p-6 flex items-center justify-between sticky top-0 z-10">
          <div className="flex items-center gap-4">
            <ChevronLeft className="w-6 h-6 text-gray-700 cursor-pointer" />
            <h1 className="text-2xl font-bold text-gray-800">PROFILE</h1>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-3xl">Glamur'e</div>
            <div className="text-2xl font-bold">APPAREL</div>
          </div>
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-pink-300 rounded-lg flex items-center justify-center cursor-pointer">
              <MessageSquare className="w-5 h-5 text-pink-600" />
            </div>
            <div className="w-10 h-10 bg-pink-300 rounded-lg flex items-center justify-center cursor-pointer">
              <User className="w-5 h-5 text-pink-600" />
            </div>
            <div className="w-10 h-10 bg-pink-300 rounded-lg flex items-center justify-center cursor-pointer">
              <Settings className="w-5 h-5 text-pink-600" />
            </div>
          </div>
        </div>

        {/* Profile Content */}
        <div className="p-8">
          <div className="flex gap-8">
            {/* Left Side - Profile Info */}
            <div className="w-1/3">
              {/* Profile Picture */}
              <div className="bg-white rounded-3xl p-6 mb-6 shadow-sm">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-24 h-24 bg-pink-300 rounded-full flex items-center justify-center">
                    <User className="w-12 h-12 text-white" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-gray-800">NAME</h2>
                    <p className="text-gray-600">{designer.name}</p>
                  </div>
                </div>

                {/* Stats */}
                <div className="flex justify-around mb-6">
                  <div className="text-center">
                    <div className="text-xs font-semibold text-gray-600 mb-1">LIKES</div>
                    <div className="text-lg font-bold text-gray-800">{designer.likes}</div>
                  </div>
                  <div className="text-center">
                    <div className="text-xs font-semibold text-gray-600 mb-1">FOLLOWERS</div>
                    <div className="text-lg font-bold text-gray-800">{designer.followers}</div>
                  </div>
                  <div className="text-center">
                    <div className="text-xs font-semibold text-gray-600 mb-1">POST</div>
                    <div className="text-lg font-bold text-gray-800">{designer.posts}</div>
                  </div>
                </div>

                {/* Add Post Button */}
                <button className="w-full bg-pink-300 text-gray-700 font-semibold py-3 rounded-full flex items-center justify-center gap-2 hover:bg-pink-400 transition">
                  <Plus className="w-5 h-5" />
                  Add Post
                </button>
              </div>

              {/* Designer Info */}
              <div className="bg-white rounded-3xl p-6 shadow-sm">
                <h3 className="text-lg font-bold text-gray-800 mb-4">DESIGNER INFO:</h3>
                <div className="space-y-2 text-sm">
                  <p className="text-gray-600">
                    <span className="font-semibold">E-MAIL:</span> {designer.email}
                  </p>
                  <p className="text-gray-600 font-semibold">Social Medias:</p>
                  <p className="text-gray-600">FB: {designer.facebook}</p>
                  <p className="text-gray-600">IG: {designer.instagram}</p>
                  <p className="text-gray-600">TWITTER: {designer.twitter}</p>
                  <p className="text-gray-600">
                    <span className="font-semibold">CONTACT NUMBER:</span> {designer.contact}
                  </p>
                </div>
              </div>
            </div>

            {/* Right Side - Designs */}
            <div className="flex-1">
              {/* Top 3 Designs */}
              <div className="mb-8">
                <div className="flex items-center gap-2 mb-4">
                  <h3 className="text-xl font-bold text-gray-800">TOP 3 DESIGNS</h3>
                  <span className="text-2xl">🔥</span>
                </div>
                <div className="grid grid-cols-3 gap-4">
                  {topDesigns.map((design) => (
                    <div key={design.id} className="bg-white rounded-2xl overflow-hidden shadow-sm">
                      <div className="aspect-square bg-pink-50">
                        <img src={design.image} alt="Design" className="w-full h-full object-cover" />
                      </div>
                      <div className="p-3 flex items-center justify-between bg-pink-200">
                        <div className="flex items-center gap-3 text-xs">
                          <div className="flex items-center gap-1">
                            <Heart className="w-4 h-4 text-pink-600 fill-pink-600" />
                            <span className="font-semibold text-gray-700">{design.likes}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Eye className="w-4 h-4 text-pink-600" />
                            <span className="font-semibold text-gray-700">{design.views}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <MessageSquare className="w-4 h-4 text-pink-600" />
                            <span className="font-semibold text-gray-700">Chat</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Posts */}
              <div>
                <h3 className="text-xl font-bold text-gray-800 mb-4">POSTS</h3>
                <div className="grid grid-cols-4 gap-4">
                  {posts.map((post) => (
                    <div key={post.id} className="bg-white rounded-2xl overflow-hidden shadow-sm">
                      <div className="aspect-square bg-pink-50">
                        <img src={post.image} alt="Post" className="w-full h-full object-cover" />
                      </div>
                      <div className="p-3 flex items-center justify-between bg-pink-200">
                        <div className="flex items-center gap-2 text-xs">
                          <div className="flex items-center gap-1">
                            <Heart className="w-3 h-3 text-pink-600 fill-pink-600" />
                            <span className="font-semibold text-gray-700">{post.likes}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Eye className="w-3 h-3 text-pink-600" />
                            <span className="font-semibold text-gray-700">{post.views}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <MessageSquare className="w-3 h-3 text-pink-600" />
                            <span className="font-semibold text-gray-700">Chat</span>
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
    </div>
  );
}