import { MongoClient } from 'mongodb';
import { ConsoleLog, ConsoleError, Logger } from '../utils/utils.logger';

@Logger
class Database {
  constructor(online = true) {

    this.connectionString = 'mongodb://localhost:27017/';
    this.atlasconnectionString = 'mongodb+srv://szzsan8_db_user:XGg1MaZBy6ZmZOpM@cluster0.9pygfc3.mongodb.net/';
    this.DBname = 'GlamURe';
    this.Log = true;

    try {
      if (online) {
        this.client = new MongoClient(this.connectionString);
        ConsoleLog(' [ CONNECTION STRING RECEIVE ] ', this.Log);
      } else {
        this.client = new MongoClient(this.atlasconnectionString);
        ConsoleLog(' [ ATLAS CONNECTION STRING RECEIVE ] ', this.Log);
      }
    } catch (error) {
      ConsoleError('[ FAILED TO RETRIEVE CONNECTION STRING ]');
      throw error
    }


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