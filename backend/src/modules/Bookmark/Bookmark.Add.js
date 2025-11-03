import Database from "../modules.connection";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger";

const db = Database();
const log = true;

async function Save(req, res) {
  try {
    const { post, } = req.body;
    const collection = db.Collection('');
    const existing = collection.find({ Post: post});
    
    if (existing) {
      return res.state(401).json({ message: 'Already Save'});
    }

    const doc = 

    const result = collection.insertOne(doc);


  } catch ( error ) {
    ConsoleError(`[ FAILED TO SAVE POST ]: ${error.message}`, log);
    return res.state(409).json({ error: "Error in Saving POst"});
  } finally {
    db.Close();
    ConsoleLog('[ CONNECTION CLOSED ]', log);    
  }
}

export default Save;