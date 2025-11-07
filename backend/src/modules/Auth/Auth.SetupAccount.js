import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import Database from '../modules.connection.js';

const db = new Database();
const log = true;

async function SetupAccount(req, res) {
  if (!req.body) {
    return res.status(400).json({ error: "Setup Account Failed: Parameter is Empty" });
  }

  try {
    const { username, displayName, gender, role, profileImage } = req.body;

    if (!username || !displayName || !gender || !role) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const collection = await db.Collection('Account');
    
    // Update user account with setup information
    const updateData = {
      DisplayName: displayName,
      Gender: gender,
      Role: role,
      ...(profileImage && { ProfileImage: profileImage })
    };

    const result = await collection.updateOne(
      { Username: username },
      { $set: updateData }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    ConsoleLog('[ ACCOUNT SETUP SUCCESSFULLY ]', log);
    return res.status(200).json({ message: 'Account setup successful' });

  } catch (error) {
    ConsoleError(`[ FAILED TO SETUP ACCOUNT ]: ${error.message}`, log);
    return res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    ConsoleLog('[ CLOSING SETUP ACCOUNT CONNECTION ]', log);
    await db.Close();
  }
}

export default SetupAccount;

