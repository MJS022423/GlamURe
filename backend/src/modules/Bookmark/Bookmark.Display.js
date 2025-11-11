import { ObjectId } from "mongodb";
import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = false;

async function Display(req, res) {
  ConsoleLog("[ BOOKMARK DISPLAY ROUTER ]", log);
  try {
    const { userId } = req.query;

    if (!userId || !ObjectId.isValid(userId)) {
      return res.status(400).json({
        success: false,
        error: "Invalid userId format. Must be a 24-character hex string."
      });
    }

    const collection = await db.Collection();
    const user = await collection.findOne({ _id: new ObjectId(userId) });

    const bookmarkedIds = (user?.Bookmark || []).map(b => b.Post_id);

    // Find all users who have posts with the bookmarked IDs
    const usersWithBookmarkedPosts = await collection.find({
      Post: { $exists: true, $ne: [] },
      "Post.Post_id": { $in: bookmarkedIds }
    }).toArray();

    const bookmarks = [];
    usersWithBookmarkedPosts.forEach(userDoc => {
      (userDoc.Post || []).forEach(post => {
        if (bookmarkedIds.includes(post.Post_id)) {
          const savedEntry = user.Bookmark.find(b => b.Post_id === post.Post_id);
          bookmarks.push({
            id: post.Post_id,
            username: userDoc.Username || "Unknown User",
            caption: post.Caption,
            images: (post.Images || []).map(img => {
              const buffer = Buffer.isBuffer(img) ? img : img.buffer ? Buffer.from(img.buffer) : Buffer.from([]);
              return `data:image/jpeg;base64,${buffer.toString('base64')}`;
            }),
            tags: post.Tags || [],
            gender: post.Gender || "Unisex",
            style: post.Style || "Casual",
            likes: post.likes || [],
            comments: post.comments || [],
            savedAt: savedEntry?.SavedAt || null
          });
        }
      });
    });

      console.log(bookmarks);

    ConsoleLog("[ SUCCESSFULLY RETRIEVE BOOKMARK ]", log);
    return res.status(200).json({ success: true, bookmarks });
  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE BOOKMARK ]: ${error.message}`, log);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    db.Close();
  }
}

export default Display;
