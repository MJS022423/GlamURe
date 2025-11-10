import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";

const db = new Database();
const log = false;

async function Save(req, res) {
  ConsoleLog("[ SAVE BOOKMARK ROUTER ]", log);
  try {

    const { userId } = req.query;
    const post  = req.body.newItem;
    
    if (!post || !post.id) {
      return res.status(400).json({ error: 'Invalid post data' });
    }

    const collection = await db.Collection();
    const existing = await collection.findOne({
      _id: new ObjectId(userId),
      Bookmark: { $elemMatch: { Post_id: post.id } }
    });

    if (existing) {
      ConsoleLog("[ POST ALREADY SAVED ]", log);      
      return 
    }

    await collection.updateOne(
      { _id: new ObjectId(userId) },
      {
        $push: { Bookmark: { Bookmark_id: new ObjectId(), Post_id: post.id, SavedAt: new Date() } }
      }
    );

    ConsoleLog("[ BOOKMARK SAVED SUCCESSFULLY ]", log);
    res.status(201).json({ message: "Post bookmarked successfully" });

  } catch (error) {
    ConsoleError(`[ FAILED TO SAVE POST ]: ${error.message}`, log);
    return res.status(409).json({ error: "Error in Saving Post" });
  } finally {
    db.Close();
  }
}

export default Save;