import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = Database();

async function MessageReceive(req, res) {
  try {
    const { userA, userB } = req.body;

    if (!userA || !userB) {
      return res.status(400).json({ error: "Missing required users" });
    }

    const conversation_id = [userA, userB].sort().join("_"); // same logic

    const collection = await db.Collection("Message");

    const conversation = await collection.findOne({ conversation_id });

    if (!conversation) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    return res.status(200).json({ messages: conversation.messages });
  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE MESSAGES ]: ${error.message}`);
    return res.status(500).json({ error: "Failed to retrieve messages" });
  } finally {
    await db.Close();
    ConsoleLog("[ MESSAGE CONNECTION CLOSED ]");
  }
}

export default MessageReceive;
