// backend/system.js
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Resolve __dirname in ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Make sure posts.json is in backend/data/posts.json
const POSTS_FILE = path.join(__dirname, "data", "posts.json");

// Read posts
export function readPosts() {
  try {
    const data = fs.readFileSync(POSTS_FILE, "utf-8");
    const parsed = JSON.parse(data);
    return parsed.map(p => ({ ...p, likes: p.likes || [] })); // default likes array
  } catch (err) {
    console.error("Error reading posts:", err);
    return [];
  }
}

// Save posts
export function savePosts(posts) {
  try {
    fs.writeFileSync(POSTS_FILE, JSON.stringify(posts, null, 2));
    return true;
  } catch (err) {
    console.error("Error writing posts:", err);
    return false;
  }
}
