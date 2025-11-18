import { MongoClient } from 'mongodb';
import { ConsoleLog, ConsoleError, Logger } from '../utils/utils.logger.js';
import dotenv from 'dotenv';

dotenv.config();

class Database {
  constructor(online = true) {

    this.localconnectionString = process.env.localhostUrl || 'mongodb://localhost:27017';
    this.atlasconnectionString = process.env.AtlasUrl || 'mongodb://localhost:27017';
    this.DBname = process.env.DB_name || 'GlamURe';
    this.Log = false;

    const url = online ? this.atlasconnectionString : this.localconnectionString;

    this.client = new MongoClient(url);
    ConsoleLog(`[ USING ${online ? 'ATLAS' : 'LOCAL'} CONNECTION STRING ]`, this.Log);

  }

  async Connection() {
    try {
      await this.client.connect();
      const db = this.client.db(this.DBname);
      return db
    } catch (error) {
      ConsoleError('[ CONNECTION FAILED TO ESTABLISHED ]', this.Log);
    }
  }

  async Collection(collection = process.env.DB_collection_name || 'posts') {
    if (collection) {
      try {
        const db = await this.Connection();
        const Collection = db.collection(collection);
        return Collection;
      } catch (error) {
        ConsoleError('[ FAILED TO CONNECT COLLECTION ]', this.Log);
      }
    } else {
      ConsoleLog('[ COLLECTION STRING IS NULL ]', this.Log);
      return null;
    }
  }

  async Close() {
    try {
      await this.client.close();
    } catch ( error ) {
      ConsoleError('[ FAILED TO CLOSE CONNECTION ]', this.Log);
    }
  }
}

export default Database;