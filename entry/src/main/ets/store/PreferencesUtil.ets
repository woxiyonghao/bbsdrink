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

  /**
   * 初始化首选项
   */
  public async init(context: common.UIAbilityContext | common.Context): Promise<void> {
    try {
      this.pref = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
    } catch (err) {
      console.error(`Failed to get preferences. Code:${err.code}, message:${err.message}`);
    }
  }

  /**
   * 设置当前登录用户的 ID
   */
  public async setCurrentUserId(userId: number): Promise<void> {
    if (!this.pref) { return; }
    await this.pref.put(KEY_CURRENT_USER_ID, userId);
    await this.pref.flush();
  }

  /**
   * 获取当前登录用户的 ID
   * @returns 用户的 ID，若不存在返回 -1
   */
  public async getCurrentUserId(): Promise<number> {
    if (!this.pref) { return -1; }
    const userId = await this.pref.get(KEY_CURRENT_USER_ID, -1);
    return userId as number;
  }

  /**
   * 设置是否同意隐私政策
   */
  public async setPrivacyAgreed(agreed: boolean): Promise<void> {
    if (!this.pref) { return; }
    await this.pref.put('is_privacy_agreed', agreed);
    await this.pref.flush();
  }

  /**
   * 获取是否同意隐私政策
   */
  public async getPrivacyAgreed(): Promise<boolean> {
    if (!this.pref) { return false; }
    const agreed = await this.pref.get('is_privacy_agreed', false);
    return agreed as boolean;
  }
}

export default PreferencesUtil.getInstance();
