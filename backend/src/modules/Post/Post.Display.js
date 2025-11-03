import Database from "../modules.connection";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger";

const db = Database();
const log = true;
const page = 1;
const limit = 30;
const skip = (page - 1) * limit;

function convertImage(doc) {

}

function shuffle(array) {
  for(let i = array.length - 1; i > 0; --i) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array
}

async function DisplayProduct(req, res) {
  
  try {

    const collection = await db.Collection('Product');
    const result = await collection.find({}).skip(skip).limit(limit).toArray();
    
    return res.status(200).json(result);

  } catch ( error ) {
    ConsoleError(`[ FAILED TO RETRIEVE DATA ]: ${error.message}`, log);
  } finally {
    db.Close();
    ConsoleLog('[ CONNECTION CLOSED ]', log);
  }

}

export default DisplayProduct;