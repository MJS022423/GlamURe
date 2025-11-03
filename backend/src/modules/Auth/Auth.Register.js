import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import Database from '../modules.connection.js';

const db = new Database();
const log = true;

async function userSchema(req) {
  const { username, email, password } = req.body;
  return { Username: `${username}`, Email: `${email}`, Password: `${password}`, Bookmark: null, notification: null, Post: null};
};

async function Register(req, res) {

  if (!req.body) {
    return res.status(400).json({ error: "Register Failed Parameter is Empty" });
  }

  try {

    const collection = await db.Collection('Account');
    const doc = await userSchema(req)
    await collection.insertOne(doc);
    ConsoleLog('[ USER REGISTERED SUCCESSFULLY ]', log);
    return res.status(200).json({ message: 'Register Successful' });

  } catch (error) {
    if (error.code === 11000) {
      ConsoleError(`[ FAILED REGISTER ACCOUNT ]: ${error.message}`, log);
      return res.status(409).json({ error: "There was an error with your registration" })
    }
    return res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    ConsoleLog('[ CLOSING REGISTER CONNECTION ]', log);
    await db.Close();
  }

};

export default Register;