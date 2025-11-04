import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";

const db = new Database();
const log = true;

async function Save(req, res) {
  try {

    const { userId } = req.params;
    const { post, } = req.body;
    if (!post || !post.id) {
      return res.status(400).json({ error: 'Invalid post data' });
    }

    const collection = db.Collection('Account');
    const existing = collection.findOne({
      _id: new ObjectId(userId),
      'Bookmark.Saved.Post_id': post.Post_id,
    });

    if (existing) {
      return res.state(401).json({ message: 'Already Save' });
    }

    const result = await collection.updateOne(
      { _id: new ObjectId(userId) },
      {
        $push: {
          "Bookmark.Saved": {
            Post_id: post.Post_id,
            Title: post.Title || "Untitled",
            Category: post.Category || null,
            SavedAt: new Date(),
          },
        },
        $set: {
          "Bookmark.BookmarkLastupdate": new Date(),
        },
      }
    );

    ConsoleLog("[ BOOKMARK SAVED SUCCESSFULLY ]", log);
    return res.status(404).json({ message: "Post bookmarked successfully" });

  } catch (error) {
    ConsoleError(`[ FAILED TO SAVE POST ]: ${error.message}`, log);
    return res.state(409).json({ error: "Error in Saving POst" });
  } finally {
    db.Close();
    ConsoleLog('[ CONNECTION CLOSED ]', log);
  }
}

export default Save;