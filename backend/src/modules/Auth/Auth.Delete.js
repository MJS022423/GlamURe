import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from 'mongodb';

const db = new Database();
const log = false;

async function Delete(req, res) {

  ConsoleLog("[ DELETE ROUTER ]" ,log);
  
  if (!req.body || !req.body.userid) {
    return res.status(400).json({ error: "Register Failed Parameter is Empty" });
  }

  try {

    const collection = await db.Collection();
    await collection.deleteOne({ _id: new ObjectId(req.body.userid) });

    ConsoleLog("[ ACCOUNT SUCESSFULLY DELETED ]");
    return res.status(200).json({ success: true, message: "Account Deleted Successfully" });

  } catch (error) {
    ConsoleError(`[ FAILED TO DELETE THE ACCOUNT ]: ${error.message}`, log);
  } finally {
    db.Close();
  }
}

export default Delete;