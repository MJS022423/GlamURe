import { ObjectId } from "mongodb";
import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = true;

async function Display(req, res) {
  ConsoleLog("[ BOOKMARK DISPLAY ROUTER ]", log);
  try {
    const { userId } = req.query;

    const collection = await db.Collection();
    const user = await collection.findOne({ _id: new ObjectId(userId) });

    const bookmarks = (user?.Bookmark || []).map(b => ({
      id: b.Post_id,
      savedAt: b.SavedAt || null,
    }));

    ConsoleLog("[ SUCCESSFULLY RETRIEVE BOOKMARK ]",log);
    return res.status(200).json({ success: true, bookmarks });
  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE BOOKMARK ]: ${error.message}`, log);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    db.Close();
  }
}

export default Display;
