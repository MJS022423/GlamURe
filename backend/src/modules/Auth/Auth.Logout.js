import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import Database from '../modules.connection.js';

const db = new Database();
const log = false;

async function Logout(req, res) {
  ConsoleLog('[ LOGOUT ROUTER ]', log);

  try {
    // Since JWT is stateless, logout is mainly client-side.
    // Here, we can log the logout event to the database if needed.
    // For now, just return success. In a production app, you might blacklist tokens or log sessions.

    const collection = await db.Collection();

    // Optional: Log logout event (you can create a logs collection)
    // await collection.insertOne({ action: 'logout', userId: req.userId, timestamp: new Date() });

    return res.status(200).json({ message: "Logout Successful" });

  } catch (error) {
    ConsoleError(`[ LOGOUT ERROR ]: ${error.message}`, log);
    return res.status(500).json({ error: "Internal Server Error" });
  } finally {
    await db.Close();
  }
};

export default Logout;
