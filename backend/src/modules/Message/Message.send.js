import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = Database();

async function MessageSend(req, res) {
  try {
    const { sender, receiver, text } = req.body;

    if (!sender || !receiver || !text) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const conversation_id = [sender, receiver].sort().join("_");

    const collection = await db.Collection("Message");

    await collection.updateOne(
      { conversation_id },
      {
        $push: {
          messages: {
            sender,
            text,
            timestamp: new Date(),
          },
        },
      },
      { upsert: true }
    );

    ConsoleLog(`[ MESSAGE SENT ] conversation_id=${conversation_id}`);
    return res.status(200).json({ success: true, conversation_id });
  } catch (error) {
    ConsoleError(`[ FAILED TO SEND MESSAGE ]: ${error.message}`);
    return res.status(500).json({ error: "Failed to send message" });
  } finally {
    await db.Close();
    ConsoleLog("[ MESSAGE CONNECTION CLOSED ]");
  }
}

export default MessageSend;
