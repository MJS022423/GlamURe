import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import Database from '../modules.connection.js';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';

dotenv.config();

const db = new Database();
const log = false;
const salt = parseInt(process.env.salt);

async function userSchema(req) {
  const { username, email, password } = req.body;
  const hashedpassword = await bcrypt.hash(password, salt);
  return {
    Username: `${username}`,
    Email: `${email}`,
    Password: `${hashedpassword}`,
    Profile_pic: null,
    Profile_name: null,
    gender: null,

    Bookmark: [],
    Post: [],
    Role: 'user',
    Createdat: new Date(),
  }
};

async function Register(req, res) {
  ConsoleLog('[ REGISTER ROUTER ]', log);

  if (!req.body) {
    return res.status(400).json({ error: "Register Failed Parameter is Empty" });
  }

  try {

    const collection = await db.Collection();
    const doc = await userSchema(req)
    await collection.insertOne(doc);
    ConsoleLog('[ USER REGISTERED SUCCESSFULLY ]', log);
    return res.status(200).json({ success: true, message: 'Register Successful' });

  } catch (error) {
    if (error.code === 11000) {
      ConsoleError(`[ FAILED REGISTER ACCOUNT ]: ${error.message}`, log);
      return res.status(409).json({ error: "There was an error with your registration" })
    }
    return res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    await db.Close();
  }

};

export default Register;