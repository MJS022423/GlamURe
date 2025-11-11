import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = true;

async function Display(req, res) {
  try {

    const collection = db.Collection();
    
    ConsoleLog("[ SUCCESSFULLY RETRIEVE COMMENT ]", log);
    return res.status(200).json({ messages: conversation.messages });

  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE MESSAGES ]: ${error.message}`);
    return res.status(500).json({ error: "Failed to retrieve messages" });
  } finally {
    await db.Close();
  }
}

export default Display;
