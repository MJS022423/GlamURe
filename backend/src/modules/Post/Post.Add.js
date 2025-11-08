import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";
import crypto from 'crypto';
import Database from "../modules.connection.js";

const db = new Database();
const log = true;


async function AddPost(req, res) {

  const { userid, caption , tags } = req.body;
  const files = req.files;

  if (!userid || !caption || !tags || !images ) {
    return res.status(400).json({ error: "Register Failed Parameter is Empty" });
  }

  try {

    const collection = await db.Collection();

    const uniqueId = crypto.randomUUID();
    const imagesbuffer = images.map((img) => ({  }))
    const postDoc = {
      Post_id: uniqueId,
      Caption: caption,
      Tags: tags,
      Images: imagesbuffer,
      likes: [],
      comments: [],
      createdDate: new Date(),
    };
    await collection.updateOne({
      _id: new ObjectId(userid)}, 
      {$push: {Post: postDoc}});

    if (result) {
      ConsoleLog("[ PRODUCT SUCCESSFULLY ADDED ]", log);
      return { success: true, message: "Product has been added" };
    }

  } catch (error) {
    ConsoleError(`[ FAILED TO ADD DESIGNER PRODUCT ]: ${error.message}`, log);
    return { success: false, message: "Failed to add Product" };

  } finally {
    db.Close();
    ConsoleLog("[ CONNECTION CLOSED ]");
  }
}

export default AddPost;