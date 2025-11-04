import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import message from "../Notification/Notification.message.js";

const db = new Database();
const log = true;

async function RemoveSave(req, res) {
  try {

    const collection = db.Collection();
    const result = collection.removeOne({});
    ConsoleLog('[ SUCCESSFULLY REMOVE SAVE BOOKMARK ]');

  } catch ( error ) {
    ConsoleError(`[ ERROR IN REMOVING THE BOOKMARK ]: ${error.message}`);
  } finally {
    db.Close();
    ConsoleLog('[ BOOKMARK CONNECTION CLOSED ]');
  }

}

export default RemoveSave;