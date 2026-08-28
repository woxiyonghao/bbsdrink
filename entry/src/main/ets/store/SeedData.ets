import RdbHelper from './RdbHelper';
import PreferencesUtil from './PreferencesUtil';

export class SeedData {
  public static async seedMockCheckIns() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId <= 0) return;
    
    // We only want to seed if we haven't already. We can check if we have a lot of records.
    const timestamps = await RdbHelper.queryAllCheckInTimestamps(userId);
    if (timestamps.length > 2) return; // already seeded or has some data
    
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth(); // 0-based
    
    const daysToSeed = [1,2,3,4,5,6,7,8,9, 20,21,22,23,24,25,26,27,28];
    
    for (let day of daysToSeed) {
      const d = new Date(year, month, day, 10, 0, 0); // 10:00 AM
      await RdbHelper.insertRecord({
        userId: userId,
        type: 4, // 签到
        value: 1,
        timestamp: d.getTime()
      });
    }
  }
}
