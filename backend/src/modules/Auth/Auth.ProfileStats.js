import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = false;

async function GetProfileStats(req, res) {
  ConsoleLog("[ PROFILE STATS ROUTER ]", log);
  try {
    const userId = req.user.id; // From auth middleware

    const collection = await db.Collection();
    const user = await collection.findOne({ _id: userId });

    if (!user) {
      return res.status(404).json({ success: false, error: "User not found" });
    }

    const posts = user.Post || [];
    const totalPosts = posts.length;
    const totalLikes = posts.reduce((sum, post) => sum + (post.likes || 0), 0);
    const email = user.Email || "";
    const socialMedia = user.SocialMedia || {};
    const contact = user.Contact || "";

    res.status(200).json({
      success: true,
      stats: {
        totalPosts,
        totalLikes,
      },
      info: {
        email,
        socialMedia,
        contact,
      },
    });

  } catch (error) {
    ConsoleError(`[ FAILED TO GET PROFILE STATS ]: ${error.message}`, log);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    db.Close();
  }
}

export default GetProfileStats;
