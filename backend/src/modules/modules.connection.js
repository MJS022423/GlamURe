import { MongoClient } from 'mongodb';
import { ConsoleLog, ConsoleError, Logger } from '../utils/utils.logger';
import dotenv from 'dotenv';

@Logger
class Database {
  constructor(online = true) {

    this.config = JSON.parse(fs.readFileSync('./DatabaseKey.json', 'utf-8'));
    this.localconnectionString = process.env.localhostUrl;
    this.atlasconnectionString = process.env.AtlasUrl;
    this.DBname = process.env.DBname;
    this.Log = true;

    const url = online ? this.atlasconnectionString : this.localconnectionString;

    this.client = new MongoClient(url);
    ConsoleLog(`[ USING ${online ? 'ATLAS' : 'LOCAL'} CONNECTION STRING ]`, this.Log);

  }

  async Connection() {
    try {
      await this.client.connect();
      const db = this.client.db(this.DBname);
      ConsoleLog('[ CONNECTION ESTABLISHED ]', this.Log);
      return db
    } catch (error) {
      ConsoleError('[ CONNECTION FAILED TO ESTABLISHED ]', this.Log);
    }
  }

  async Collection(collection = null) {
    if (collection) {
      try {
        const db = await this.Connection();
        const Collection = db.collection(collection);
        ConsoleLog('[ COLLECTION CONNECTION ESTABLISHED ]', this.Log);
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
      ConsoleLog('[ CONNECTION CLOSED ]', this.Log);
    } catch ( error ) {
      ConsoleError('[ FAILED TO CLOSE CONNECTION ]', this.Log);
    }
  }
}

export default Database;