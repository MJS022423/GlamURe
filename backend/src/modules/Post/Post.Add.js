import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import { ObjectId } from "mongodb";
import crypto from 'crypto';
import Database from "../modules.connection.js";

const db = new Database();
const log = false;


async function AddPost(req, res) {

  let { userid, caption, tags } = req.body;
  let files = req.files;

  if (!userid || !caption || !tags || !files) {
    return res.status(400).json({ error: "Register Failed Parameter is Empty" });
  }

  try {

    try {
      tags = JSON.parse(tags);
    } catch {
      tags = Array.isArray(tags) ? tags : [];
    }

    const collection = await db.Collection(); 

    const uniqueId = crypto.randomUUID();
    const imagesArray =
      files && files.length > 0
        ? files.map((file) => file.buffer)
        : [];

    const postDoc = {
      Post_id: uniqueId,
      Caption: caption,
      Tags: tags,
      Images: imagesArray,
      likes: null,
      comments: null,
      createdDate: new Date(),
    };
    const result = await collection.updateOne({
      _id: new ObjectId(userid)
    },
      { $push: { Post: postDoc } });

    if (result) {
      ConsoleLog("[ PRODUCT SUCCESSFULLY ADDED ]", log);

      // Fetch the updated user document to get the newly added post
      const updatedUser = await collection.findOne({ _id: new ObjectId(userid) });
      const addedPost = updatedUser.Post.find(p => p.Post_id === uniqueId);

      // Format the post similar to DisplayPost
      const formattedPost = {
        id: addedPost.Post_id,
        userId: updatedUser._id,
        username: updatedUser.Username || "Unknown User",
        profile_pic: updatedUser.Profile_pic || null,
        caption: addedPost.Caption || "",
        tags: addedPost.Tags || [],
        likes: addedPost.likes || 0,
        comments: addedPost.comments || [],
        createdDate: addedPost.createdDate || new Date(),
        images: (addedPost.Images || []).map(img => {
          const buffer = Buffer.isBuffer(img) ? img : img.buffer ? Buffer.from(img.buffer) : Buffer.from([]);
          return `data:image/jpeg;base64,${buffer.toString('base64')}`;
        }),
        gender: addedPost.Gender || "Unisex",
        style: addedPost.Style || "Casual",
      };

      return { success: true, message: "Product has been added", post: formattedPost };
    }

  } catch (error) {
    ConsoleError(`[ FAILED TO ADD DESIGNER PRODUCT ]: ${error.message}`, log);
    return { success: false, message: "Failed to add Product" };

  } finally {
    db.Close();
  }
}

export default AddPost;