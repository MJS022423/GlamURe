import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = false;

async function DisplayPost(req, res) {
  ConsoleLog("[ POST DISPLAY ROUTER ]", log);
  try {
    const leaderboard = req.query.leaderboard === 'true';

    const collection = await db.Collection();

    const users = await collection.find({ Post: { $exists: true, $ne: [] } }).toArray();

    let allPosts = users.flatMap(user =>
      (user.Post || []).map(post => ({
        id: post.Post_id,
        userId: user._id,
        username: user.Username || "Unknown User",
        profile_pic: user.Profile_pic || null,
        caption: post.Caption || "",
        tags: post.Tags || [],
        likes: post.likes || 0,
        comments: post.comments || [],
        createdDate: post.createdDate || new Date(),
        images: (post.Images || []).map(img => {
          const buffer = Buffer.isBuffer(img) ? img : img.buffer ? Buffer.from(img.buffer) : Buffer.from([]);
          return `data:image/jpeg;base64,${buffer.toString('base64')}`;
        }),
        gender: post.Gender || "Unisex",
        style: post.Style || "Casual",
      }))
    );

    if (leaderboard) {
      // Filter posts with at least 1 like for leaderboard
      allPosts = allPosts.filter(post => post.likes > 0);
      allPosts.sort((a, b) => b.likes - a.likes);
    } else {
      allPosts.sort((a, b) => new Date(b.createdDate) - new Date(a.createdDate));
    }

    const totalDocs = allPosts.length;

    res.status(200).json({
      success: true,
      totalDocs,
      results: allPosts,
    });

  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE POSTS ]: ${error.message}`, log);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    db.Close();
  }
}

export default DisplayPost;
