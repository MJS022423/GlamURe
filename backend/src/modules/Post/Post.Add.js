import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";
import Database from "../modules.connection.js";
import crypto from 'crypto';
import fs from 'fs';

const db = new Database();
const log = true;

async function ProductSchema(req) {
  const { image, Product_name } = req.body;
  const imageHash = crypto.createHash('sha256').update(Product_name).digest('hex');
  const imagebuffer = fs.readFileSync( image )
  return { Image: imagebuffer, Product: Product_name, FileHash: imageHash};
}

async function AddProduct(req, res) {
  try {

    const collection = await db.Collection('Product');
    const doc = await ProductSchema(req);
    const existingfile = await collection.findOne(doc.FileHash);

    if (existingfile) {
      ConsoleError('[ IMAGES IS DUPLICATE ]');
      return { success: false, message: "Duplicate Image product" };
    }

    const result = await collection.insertOne(doc);
    fs.unlink(doc.image);

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