import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { User, Task, CheckInRecord } from '../types';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'DrinkAppRdb.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_USER_TABLE = 'CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT, nickname TEXT NOT NULL, avatar TEXT, createTime INTEGER)';
const SQL_CREATE_TASK_TABLE = 'CREATE TABLE IF NOT EXISTS task (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, title TEXT NOT NULL, targetCount INTEGER, unit TEXT, createTime INTEGER)';
const SQL_CREATE_RECORD_TABLE = 'CREATE TABLE IF NOT EXISTS record (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, type INTEGER, taskId INTEGER, value INTEGER, timestamp INTEGER)';

export class RdbHelper {
  private static instance: RdbHelper;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {}

  public static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  public async init(context: common.UIAbilityContext | common.Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.rdbStore.executeSql(SQL_CREATE_USER_TABLE);
      await this.rdbStore.executeSql(SQL_CREATE_TASK_TABLE);
      await this.rdbStore.executeSql(SQL_CREATE_RECORD_TABLE);
    } catch (err) {
      console.error(`RdbHelper init failed. Code:${err.code}, message:${err.message}`);
    }
  }

  // ============== User APIs ==============
  public async insertUser(user: User): Promise<number> {
    if (!this.rdbStore) return -1;
    const valueBucket: relationalStore.ValuesBucket = {
      'nickname': user.nickname,
      'avatar': user.avatar || '',
      'createTime': user.createTime
    };
    return await this.rdbStore.insert('user', valueBucket);
  }

  public async queryUserById(id: number): Promise<User | null> {
    if (!this.rdbStore) return null;
    let predicates = new relationalStore.RdbPredicates('user');
    predicates.equalTo('id', id);
    let resultSet = await this.rdbStore.query(predicates, ['id', 'nickname', 'avatar', 'createTime']);
    if (resultSet.goToFirstRow()) {
      const user: User = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        nickname: resultSet.getString(resultSet.getColumnIndex('nickname')),
        avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
      };
      resultSet.close();
      return user;
    }
    resultSet.close();
    return null;
  }

  public async queryAllUsers(): Promise<User[]> {
    if (!this.rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('user');
    let resultSet = await this.rdbStore.query(predicates, ['id', 'nickname', 'avatar', 'createTime']);
    let users: User[] = [];
    while (resultSet.goToNextRow()) {
      users.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        nickname: resultSet.getString(resultSet.getColumnIndex('nickname')),
        avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
      });
    }
    resultSet.close();
    return users;
  }

  // ============== Record APIs (Check-ins) ==============
  public async insertRecord(record: CheckInRecord): Promise<number> {
    if (!this.rdbStore) return -1;
    const valueBucket: relationalStore.ValuesBucket = {
      'userId': record.userId,
      'type': record.type,
      'taskId': record.taskId || -1,
      'value': record.value,
      'timestamp': record.timestamp
    };
    return await this.rdbStore.insert('record', valueBucket);
  }
}

export default RdbHelper.getInstance();
