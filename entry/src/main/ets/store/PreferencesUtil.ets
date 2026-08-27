import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

const PREFERENCES_NAME = 'DrinkAppPreferences';
const KEY_CURRENT_USER_ID = 'current_user_id';

export class PreferencesUtil {
  private static instance: PreferencesUtil;
  private pref: dataPreferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  public async init(context: common.UIAbilityContext | common.Context): Promise<void> {
    try {
      this.pref = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
    } catch (err) {
      console.error(`Failed to get preferences. Code:${err.code}, message:${err.message}`);
    }
  }

  public async setCurrentUserId(userId: number): Promise<void> {
    if (this.pref) {
      await this.pref.put(KEY_CURRENT_USER_ID, userId);
      await this.pref.flush();
    }
  }

  public async getCurrentUserId(): Promise<number> {
    if (this.pref) {
      const id = await this.pref.get(KEY_CURRENT_USER_ID, -1);
      return id as number;
    }
    return -1;
  }
}

export default PreferencesUtil.getInstance();
