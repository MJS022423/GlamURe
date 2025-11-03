import Database from "../modules.connection";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger";
import Message from "./Notification.message";

const db = Database();
const log = true;

async function AddNotif(user) {
  try {

    const collection = db.Collecion('Notification');

    const message = Message.Added_post(user);

    if (!result) {
      ConsoleLog("[ FAILED TO RETRIEVE RESULT ]", log);
    }

    const doc = {User: user, Messages: message};

    const result = await collection.insertOne(doc);
    ConsoleLog("[ NOTIFICATION RETRIEVE ]", log);

  } catch (error) {
    ConsoleError(`[ FAILED TO ADD NOTIFICATION ]: ${error.message}`, log);
  } finally {
    await db.Close();
  }
}
