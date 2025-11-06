
import express from "express";
import path from "path";
import cors from "cors";
import { readPosts, savePosts } from "./system.js";

const app = express();
const PORT = 5000;

// Configure CORS
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));

// Configure json
app.use(express.json());

// Configure rate limiting
const limiter = rateLimit({
  windowMs: 30 * 60 * 1000,
  limit: 100,
  standardHeaders: true,
  legacyHeaders: false
});

app.use(cors());
app.use(express.json());

// Serve static files like favicon
app.use(express.static(path.join(path.dirname(''), 'public')));

// GET posts
app.get("/api/posts", (req, res) => {
  const posts = readPosts();
  res.json(posts);
});

// POST new post
app.post("/api/posts", (req, res) => {
  const posts = readPosts();
  const newPost = {
    id: Date.now(),
    username: req.body.username || "Anonymous",
    profilePic: req.body.profilePic || "https://via.placeholder.com/40",
    description: req.body.description || "",
    images: req.body.images?.length ? req.body.images : ["https://via.placeholder.com/400"],
    tags: req.body.tags?.length ? req.body.tags : ["Unisex"],
    likes: [],
    commentsList: [],
    createdAt: Date.now()
  };
  posts.unshift(newPost);

  if (savePosts(posts)) {
    res.json(newPost);
  } else {
    res.status(500).json({ error: "Failed to save post." });
  }
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
