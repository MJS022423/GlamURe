import Database from "../modules.connection.js";
import { ConsoleLog, ConsoleError } from "../../utils/utils.logger.js";

const db = new Database(true);
const log = true;

async function RemoveProduct(Product_name) {
  try {

    const collection = await db.Collection('Product');
    const result = await collection.deleteOne({ Product: Product_name});

    if (result.deleteCount > 0) {
      ConsoleLog(`[ PRODUCT ${Product_name} REMOVED ]`, log);
      return { success: true, message: "Product remove Successfully"};
    } else {
      ConsoleError(`[ PRODUCT ${Product_name} NOT FOUND]`, log);
      return { success: false, message: "Product not found"};
    }

  } catch ( error ) {
    ConsoleError(`[ FAILED TO REMOVE PRODUCT ]: ${error.message}`, log);
    return { success: false, message: "Error Removing product"};
  } finally {
    db.Close();
    ConsoleLog("[ CONNECTION CLOSED ]");
  }
}

export default RemoveProduct;