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

  /**
   * 查询指定用户当天的喝水总量
   */
  public async queryTodayTotalByType(userId: number, type: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const startOfDay = now.getTime();
    now.setHours(23, 59, 59, 999);
    const endOfDay = now.getTime();

    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId)
      .and()
      .equalTo('type', type)
      .and()
      .greaterThanOrEqualTo('timestamp', startOfDay)
      .and()
      .lessThanOrEqualTo('timestamp', endOfDay);
      
    let resultSet = await this.rdbStore.query(predicates, ['value']);
    let total = 0;
    while (resultSet.goToNextRow()) {
      total += resultSet.getLong(resultSet.getColumnIndex('value'));
    }
    resultSet.close();
    return total;
  }

  public async queryTodayWaterTotal(userId: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const startOfDay = now.getTime();
    now.setHours(23, 59, 59, 999);
    const endOfDay = now.getTime();

    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId)
      .and()
      .greaterThanOrEqualTo('timestamp', startOfDay)
      .and()
      .lessThanOrEqualTo('timestamp', endOfDay);
      
    let resultSet = await this.rdbStore.query(predicates, ['value']);
    let total = 0;
    while (resultSet.goToNextRow()) {
      total += resultSet.getLong(resultSet.getColumnIndex('value'));
    }
    resultSet.close();
    return total;
  }

  /**
   * 查询指定用户当天最后一次喝水的时间戳
   */
  public async queryLatestWaterRecordTime(userId: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const startOfDay = now.getTime();
    const endOfDay = new Date().getTime(); // up to current time

    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId)
      .and()
      .equalTo('type', 0) // 0: 喝水
      .and()
      .greaterThanOrEqualTo('timestamp', startOfDay)
      .and()
      .lessThanOrEqualTo('timestamp', endOfDay)
      .orderByDesc('timestamp');
      
    let resultSet = await this.rdbStore.query(predicates, ['timestamp']);
    let latestTime = 0;
    if (resultSet.goToFirstRow()) {
      latestTime = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
    }
    resultSet.close();
    return latestTime;
  }

  /**
   * 查询指定用户今天是否已经签到 (type=4)
   */
  public async hasCheckedInToday(userId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const startOfDay = now.getTime();
    now.setHours(23, 59, 59, 999);
    const endOfDay = now.getTime();

    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId)
      .and()
      .equalTo('type', 4)
      .and()
      .greaterThanOrEqualTo('timestamp', startOfDay)
      .and()
      .lessThanOrEqualTo('timestamp', endOfDay);
      
    let resultSet = await this.rdbStore.query(predicates, ['id']);
    const hasRecord = resultSet.rowCount > 0;
    resultSet.close();
    return hasRecord;
  }

  /**
   * 查询指定用户所有的签到记录时间戳
   */
  public async queryAllCheckInTimestamps(userId: number): Promise<number[]> {
    if (!this.rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId).and().equalTo('type', 4);
    let resultSet = await this.rdbStore.query(predicates, ['timestamp']);
    let timestamps: number[] = [];
    while (resultSet.goToNextRow()) {
      timestamps.push(resultSet.getLong(resultSet.getColumnIndex('timestamp')));
    }
    resultSet.close();
    return timestamps;
  }

  public async queryDrinkRecords(userId: number): Promise<CheckInRecord[]> {
    if (!this.rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates('record');
    predicates.equalTo('userId', userId).orderByDesc('timestamp');
    let resultSet = await this.rdbStore.query(predicates, ['id', 'userId', 'type', 'value', 'timestamp']);
    let records: CheckInRecord[] = [];
    while (resultSet.goToNextRow()) {
      const type = resultSet.getLong(resultSet.getColumnIndex('type'));
      const value = resultSet.getLong(resultSet.getColumnIndex('value'));
      // 过滤掉签到记录(type=4, value=1)，其他的认为是喝水记录
      if (type === 4 && value === 1) {
        continue;
      }
      records.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        userId: resultSet.getLong(resultSet.getColumnIndex('userId')),
        type: type,
        value: value,
        timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp'))
      });
    }
    resultSet.close();
    return records;
  }
}

export default RdbHelper.getInstance();
