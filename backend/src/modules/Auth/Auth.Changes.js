import Database from "../modules.connection.js";
import { ObjectId } from "mongodb";
import fs from 'fs';
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = true;

export async function UpdateProfile(req, res) {
  ConsoleLog("[ UPDATE PROFILE ROUTER ]", log);

  if (!req.body || !req.body.userid || !req.body.name || !req.body.username || !req.body.profilePicture) {
    return res.status(400).json({ error: "Update Request Failed Parameter is Empty" });
  }
  const { userid, name, username, profilePicture } = req.body;

  try {
    const collection = await db.Collection();
    const user = await collection.findOne({ _id: new ObjectId(userid) });

    if (!user) {
      return res.status(404).json({ error: "Username not found" });
    }
    const userDoc = {
      $set: {
        Username: username,
        Profile_name: name,
        Profile_pic: profilePicture,
      }
    }
    await collection.updateOne({ _id: new ObjectId(userid) }, userDoc);
    // fs.unlink(profilePicture);

    ConsoleLog('[ SUCCESSFULLY UPDATE PROFILE ]', log);
    return res.status(200).json({ success: true });

  } catch (error) {
    ConsoleError(`[ FAILED TO PROFILE PICTURE ACCOUNT ]: ${error.message}`, log);
  } finally {
    db.Close();
  }
}

export async function UpdatePassword(req, res) {
  ConsoleLog("[ UPDATE PASSWORD ROUTER ]", log);

  if (!req.body || !req.body.userid || !req.body.newPassword) {
    return res.status(400).json({ error: "Update Request Failed Parameter is Empty" });
  }

  const { userid, newPassword } = req.body;

  try {
    const collection = await db.Collection();
    const user = await collection.findOne({ _id: new ObjectId(userid) });

    if (!user) {
      return res.status(404).json({ error: "Username not found" });
    }

    const userDoc = {
      $set: {
        Password: newPassword
      }
    }

    await collection.updateOne({ _id: new ObjectId(userid) }, userDoc);

    ConsoleLog("[ SUCCESSFULLY UPDATED PASSWORD ]", log);

  } catch (error) {
    ConsoleError(`[ FAILED TO UPDATE ACCOUNT ]: ${error.message}`, log);
  } finally {
    db.Close();
  }
}