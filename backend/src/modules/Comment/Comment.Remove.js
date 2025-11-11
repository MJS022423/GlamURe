import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";

const db = new Database();
const log = true;

async function Remove(req, res) {
  try {
    const userid = req.query.Userid;
    const postid = req.query.Postid;
    const commentid = req.query.Commentid;

    if (!userid || !postid || !commentid) {
      return res.status(400).json({ error: "Userid, Postid, and Commentid are required" });
    }

    const collection = await db.Collection();
    const result = await collection.updateOne(
      { _id: new ObjectId(postid) },
      { $pull: { "comments": { _id: new ObjectId(commentid), user_id: new ObjectId(userid) } } }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ error: "Comment not found or not authorized to remove" });
    }

    ConsoleLog("[ SUCCESSFULLY REMOVED COMMENT ]", log);
    res.status(200).json({ success: true, message: "Comment removed successfully" });

  } catch (error) {
    ConsoleError(`[ FAILED TO REMOVE COMMENT ]: ${error.message}`);
    return res.status(500).json({ error: "Failed to remove comment" });
  } finally {
    await db.Close();
  }
}

export default Remove;
