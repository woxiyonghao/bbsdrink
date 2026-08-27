import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { User, Task, CheckInRecord } from '../types';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'DrinkAppRdb.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_USER_TABLE = 'CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT, nickname TEXT NOT NULL, avatar TEXT, gender INTEGER, birthday INTEGER, createTime INTEGER)';
const SQL_SEED_USER_ID = "INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('user', 9999)";
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
      await this.rdbStore.executeSql(SQL_SEED_USER_ID);
      await this.rdbStore.executeSql(SQL_CREATE_TASK_TABLE);
      await this.rdbStore.executeSql(SQL_CREATE_RECORD_TABLE);
    } catch (err) {
      console.error(`RdbHelper init failed. Code:${err.code}, message:${err.message}`);
    }
  }

  /**
   * 插入新用户
   */
  public async insertUser(user: User): Promise<number> {
    if (!this.rdbStore) { return -1; }
    const valueBucket: relationalStore.ValuesBucket = {
      'nickname': user.nickname,
      'avatar': user.avatar || '',
      'gender': user.gender,
      'birthday': user.birthday,
      'createTime': user.createTime
    };
    return await this.rdbStore.insert('user', valueBucket);
  }

  /**
   * 根据 ID 查询用户
   */
  public async queryUserById(id: number): Promise<User | null> {
    if (!this.rdbStore) { return null; }
    let predicates = new relationalStore.RdbPredicates('user');
    predicates.equalTo('id', id);
    let resultSet = await this.rdbStore.query(predicates, ['id', 'nickname', 'avatar', 'gender', 'birthday', 'createTime']);
    if (resultSet.goToFirstRow()) {
      const user: User = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        nickname: resultSet.getString(resultSet.getColumnIndex('nickname')),
        avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
        gender: resultSet.getLong(resultSet.getColumnIndex('gender')),
        birthday: resultSet.getLong(resultSet.getColumnIndex('birthday')),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
      };
      resultSet.close();
      return user;
    }
    resultSet.close();
    return null;
  }

  /**
   * 更新用户信息
   */
  public async updateUser(user: User): Promise<number> {
    if (!this.rdbStore || !user.id) { return -1; }
    const valueBucket: relationalStore.ValuesBucket = {
      'nickname': user.nickname,
      'avatar': user.avatar || '',
      'gender': user.gender,
      'birthday': user.birthday,
      'createTime': user.createTime
    };
    let predicates = new relationalStore.RdbPredicates('user');
    predicates.equalTo('id', user.id);
    return await this.rdbStore.update(valueBucket, predicates);
  }

  /**
   * 获取所有用户
   */
  public async queryAllUsers(): Promise<User[]> {
    if (!this.rdbStore) { return []; }
    let predicates = new relationalStore.RdbPredicates('user');
    let resultSet = await this.rdbStore.query(predicates, ['id', 'nickname', 'avatar', 'gender', 'birthday', 'createTime']);
    let users: User[] = [];
    while (resultSet.goToNextRow()) {
      users.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        nickname: resultSet.getString(resultSet.getColumnIndex('nickname')),
        avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
        gender: resultSet.getLong(resultSet.getColumnIndex('gender')),
        birthday: resultSet.getLong(resultSet.getColumnIndex('birthday')),
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
