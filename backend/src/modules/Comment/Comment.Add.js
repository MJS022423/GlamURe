import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";

const db = new Database(false);
const log = true

async function Add(req, res) {
  try {

    const userid = req.query.Userid;
    const postid = req.query.postid;
    const { comment, username } = req.body;

    if (!comment || !userid || !postid) {
      return res.status(400).json({ error: "Failed to add comment missing parameter" });
    }

    const commentDocs = {
      user_id: new ObjectId(userid),
      text: comment,
      username: username || 'Anonymous',
      createdAt: new Date(),
    }

    const collection = await db.Collection();
    const result = await collection.updateOne(
      { _id: new ObjectId(postid)},
      { $push: { "comments":  commentDocs } },
    )

    ConsoleLog("[ SUCCESSFULLY ADDED COMMENT ]", log);
    res.status(200).json({ success: true, message: "successfully added comment in post" });

  } catch (error) {
    ConsoleError(`[ FAILED TO ADD COMMENT ]: ${error.message}`, log)
  } finally {
    await db.Close();
  }
}

export default Add;
