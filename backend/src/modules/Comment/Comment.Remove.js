import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = true;

async function Remove(req, res) {
  try {

    const collection = await db.Collection();
    const result = await collection.updateOne(
      { _id: new ObjectId(userid) },
      { $pull: { "Post.$.comments": commentDocs } },
    )

    

  } catch (error) {
    ConsoleError(`[ FAILED TO SEND MESSAGE ]: ${error.message}`);
    return res.status(500).json({ error: "Failed to send message" });
  } finally {
    await db.Close();
    ConsoleLog("[ MESSAGE CONNECTION CLOSED ]");
  }
}

export default Remove;
