import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";

const db = new Database();
const log = true;

async function Display(req, res) {
  try {
    const postid = req.query.Postid;

    if (!postid) {
      return res.status(400).json({ error: "Postid is required" });
    }

    const collection = await db.Collection();
    const post = await collection.findOne({ _id: new ObjectId(postid) });

    if (!post) {
      return res.status(404).json({ error: "Post not found" });
    }

    const comments = post.comments || [];

    ConsoleLog("[ SUCCESSFULLY RETRIEVED COMMENTS ]", log);
    return res.status(200).json({ success: true, comments });

  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE COMMENTS ]: ${error.message}`);
    return res.status(500).json({ error: "Failed to retrieve comments" });
  } finally {
    await db.Close();
  }
}

export default Display;
