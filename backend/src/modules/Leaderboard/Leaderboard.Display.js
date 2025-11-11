import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = true;

async function Display() {
  try {
    
    const collection = db.Collection();
    const result = await collection.find({}).toArray();
     
  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE NOTIFICATION ]: ${error.message}`,log);
  } finally {
    db.Close();
  }
}

export default Display;