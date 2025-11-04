import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = Database();
const log = true;
const page = 1;
const limit = 30;
const skip = (page - 1) * limit;

function convertImage(base64Str) {
  if (!base64Str) return null;

  const matches = base64Str.match(/^data:image\/(\w+);base64,(.+)$/);
  if (!matches) return null;

  const ext = matches[1]; // png, jpeg, etc.
  const data = matches[2];
  const buffer = Buffer.from(data, "base64");

  return { buffer, ext };
}

async function DisplayProduct(req, res) {

  try {

    const collection = await db.Collection('Product');
    const result = await collection.find({}).skip(skip).limit(limit).toArray();

    if (!product || !product.image) {
      return res.status(404).send("Image not found");
    }

    const img = convertImage(product.image);
    if (!img) return res.status(400).send("Invalid image format");

    res.setHeader("Content-Type", `image/${img.ext}`);
    res.send(img.buffer);

  } catch (error) {
    ConsoleError(`[ FAILED TO RETRIEVE DATA ]: ${error.message}`, log);
  } finally {
    db.Close();
    ConsoleLog('[ CONNECTION CLOSED ]', log);
  }

}

export default DisplayProduct;