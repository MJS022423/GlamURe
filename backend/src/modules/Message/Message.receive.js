import Database from "../modules.connection";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger";

const db = Database();

async function MessageReceive(req, res) {
  try {

    const { id } = req.body;

    const collection = db.Connection('Message');
    const Conversation = collection.findOne({conversation_id: id});

    return res.status(200).json({message: `${Conversation}`})

  } catch ( error ) {
    ConsoleError(`[ FAILED TO RETRIEVE THE MESSAGE ]: ${error.message}`);
  } finally {
    db.Close();
    ConsoleLog('[ MESSAGE CONNECTION CLOSED ]');
  }
}