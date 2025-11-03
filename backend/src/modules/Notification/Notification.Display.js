import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = Database();
const log = true;

async function DisplayNotif() {
  try {
    
    const collection = db.Collection('Notification');
    const result = await collection.find({}).toArray();
    ConsoleLog('[ NOTIFICATION RETRIEVE ]');
    return result;
     
  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE NOTIFICATION ]: ${error.message}`,log);
  } finally {
    db.Close();
  }
}

export default DisplayNotif;