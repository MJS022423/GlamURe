import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database();
const log = true;

function convertImage(base64Str) {
  if (!base64Str) return null;

  const matches = base64Str.match(/^data:image\/(\w+);base64,(.+)$/);
  if (!matches) return null;

  const ext = matches[1]; // png, jpeg, etc.
  const data = matches[2];
  const buffer = Buffer.from(data, "base64");

  return { buffer, ext };
}

async function DisplayPost(req, res) {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const collection = await db.Collection();
    const totalDocs = await collection.countDocuments();
    const totalPages = Math.ceil(totalDocs / limit);

    const posts = await collection.find({})
      .skip(skip)
      .limit(limit)
      .toArray();

    res.status(200).json({
      success: true,
      page, 
      totalPages,
      totalDocs,
      results: posts,
    });

  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE POSTS ]: ${error.message}`, log);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    db.Close();
  }
}

export default DisplayPost;