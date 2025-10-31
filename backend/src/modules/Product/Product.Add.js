import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import Database from "../modules.connection.js";
import crypto from 'crypto';

const db = new Database(true);
const log = true;

async function aProductSchema(req) {
  const { image, Product_name } = req.body;
  return { Image: image, Product: Product_name };
}

async function AddProduct(req) {
  try {

    const collection = await db.Collection('Product');
    const doc = await ProductSchema(req)
    const imageHash = crypto.createHash('sha256').update(doc.Image).digest('hex');
    const existingfile = await collection.findOne(imageHash);

    if (existingfile) {
      ConsoleError('[ IMAGES IS DUPLICATE ]');
      return { success: false, message: "Duplicate Image product" };
    }

    const result = await collection.insertOne(doc);

    if (result) {
      ConsoleLog("[ PRODUCT SUCCESSFULLY ADDED ]", log);
      return { success: true,  message: "Product has been added" };
    }

  } catch (error) {
    ConsoleError(`[ FAILED TO ADD DESIGNER PRODUCT ]: ${error.message}`, log);
    return { success: false, message: "Failed to add Product"};

  } finally {
    db.Close();
    ConsoleLog("[ CONNECTION CLOSED ]");
  }
}

export default AddProduct;