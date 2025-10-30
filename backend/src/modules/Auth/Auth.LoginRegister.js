import express from 'express';
import { ConsoleLog, ConsoleError } from '../../utils/utils.logger.js';
import Database from '../modules.connection.js';
import { userSchema } from '../Auth/Auth.Constructor.js';

const router = express.Router();
const db = Database();
const log = true;

router.post('/Register', async (req, res) => {

  if (!req.data) {
    return res.status(400).json({ error: "Register Failed Parameter is Empty" });
  }

  try {
    await db.Connection();

    const collection = await db.Collection('Account');
    const doc = userSchema(req)
    await collection.insertOne(doc);
    ConsoleLog('[ USER REGISTERED SUCCESSFULLY ]', log);
    return res.status(200).json({ message: 'Register Successful' });

  } catch (error) {
    if (error.code === 11000) {
      ConsoleError('[ FAILED REGISTER ACCOUNT ]', log);
      return res.status(409).json({ error: "There was an error with your registration" })
    }
  } finally {
    ConsoleLog('[ CLOSING REGISTER CONNECTION ]', log);
    await db.Coonection.close();
  }

});

router.get('/Login', async (req, res) => {

  if (!req.data) {
    return res.status(400).json({ error: "Login Request Failed Parameter is Empty" });
  }

  try {
    await db.Connection();

    const collection = await db.collection('Account');
    const doc = userSchema(req);
    await collection.find(doc)
    return res.status(200).json({ error: "Login Successful" });

  } catch (error) {
    if (error.code === 11000) {
      ConsoleLog('[ FAILED TO LOGIN ACCOUNT ]', log);
      return res.status(409).json({ error: "Login error please try again" });
    }
  } finally {
    ConsoleLog('[ CLOSING LOGIN CONNECTION ]', log);
    await db.Connection.close();
  }
});

