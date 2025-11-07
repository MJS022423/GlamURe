import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import { generateKey } from './Auth.js';

import Database from '../modules.connection.js';
import bcrypt from 'bcrypt';

const db = new Database();
const log = false;

async function Login(req, res) {
  ConsoleLog('[ LOGIN ROUTER ]', log);
  if (!req.body) {
    return res.status(400).json({ error: "Login Request Failed Parameter is Empty" });
  }

  try {

    const collection = await db.Collection();
    const { username, password } = req.body;
    const user = await collection.findOne({ Username: username });

    if (!user) {
      return res.status(401).json({ error: "Account not found" });
    }

    const match = await bcrypt.compare(password, user.Password);
    if (!match) {
      return res.status(401).json({ error: "Invalid Credential" });
    }

    const token = generateKey(user._id.toString());

    return res.status(200).json(
      {
        message: "Login Successful",
        token,
        userid: user._id.toString()
      }
    );

  } catch (error) {
    if (error.code === 11000) {
      ConsoleError(`[ FAILED TO LOGIN ACCOUNT ]: ${error.message}`, log);
      return res.status(409).json({ error: "Login error please try again" });
    }
    return res.status(500).json({ error: "Internal Server Error" });
  } finally {
    await db.Close();
  }
};

export default Login; 