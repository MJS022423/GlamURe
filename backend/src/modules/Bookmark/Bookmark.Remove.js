import { ObjectId } from "mongodb";
import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = false;

async function Remove(req, res) {
  ConsoleLog("[ REMOVE BOOKMARK ROUTER ]", log);
  try {
    const userid = req.query.userId;
    const { postId } = req.body;

    const collection = await db.Collection();
    const result = await collection.updateOne(
      { _id: new ObjectId(userid) },
      { $pull: { Bookmark: { Post_id: String(postId) } } }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ success: false, message: "Bookmark not found" });
    }

    ConsoleLog('[ SUCCESSFULLY REMOVE SAVE BOOKMARK ]', log);
    res.status(201).json({ success: true, message: "successfully remove bookmark" });

  } catch (error) {
    ConsoleError(`[ ERROR IN REMOVING THE BOOKMARK ]: ${error.message}`, log);
  } finally {
    db.Close();
  }
}

export default Remove;