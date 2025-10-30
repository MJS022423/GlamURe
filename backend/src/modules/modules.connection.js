import { MongoClient } from 'mongodb';
import { ConsoleLog, ConsoleError, Logger } from '../utils/utils.logger';

@Logger
class Database {
  constructor() {

    this.connectionString = 'mongodb://localhost:27017/';
    this.DBname = 'GlamURe';
    this.Log = true;
    this.client = new MongoClient(this.connectionString);

  }

  async Connection() {
    try {
      await this.client.connect();
      const db = db.Database(this.DBname);
      ConsoleLog('[ CONNECTION ESTABLISHED ]', this.Log);
      return 
    } catch (error) {
      ConsoleError('[ CONNECTION FAILED TO ESTABLISHED ]', this.Log);
    }
  }

  async Collection(collection = null) {
    if (collection) {
      try {
        const db = this.Connection();
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
}

export default MongoConnection;