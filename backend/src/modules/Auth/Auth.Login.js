import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import Database from '../modules.connection.js';

const db = new Database();
const log = true;


async function Login(req, res) {
  ConsoleLog('[ LOGIN ROUTER ]', log);
  if (!req.body) {
    return res.status(400).json({ error: "Login Request Failed Parameter is Empty" });
  }

  try {

    const collection = await db.Collection('Account');
    const { username, password } = req.body;
    const user = await collection.findOne({Username: username, Password: password});

    if (!user) {
      return res.status(401).json({ error: "Account not found"});
    } 

    return res.status(200).json({ error: "Login Successful" });

  } catch (error) {
    if (error.code === 11000) {
      ConsoleError(`[ FAILED TO LOGIN ACCOUNT ]: ${error.message}`, log);
      return res.status(409).json({ error: "Login error please try again" });
    }
    return res.status(500).json({ error: "Internal Server Error"});
  } finally {
    await db.Close();
    ConsoleLog('[ CLOSING LOGIN CONNECTION ]', log);
  }
};

export default Login;

