import router from '@ohos.router';
import { User } from '../../types';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';

@Entry
@Component
export struct SettingPage {
  @State currentUser: User | null = null;

  async aboutToAppear() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.currentUser = await RdbHelper.queryUserById(userId);
    }
  }

  // 格式化时间戳为 YYYY-MM-DD
  formatDate(timestamp: number): string {
    const d = new Date(timestamp);
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 格式化性别
  formatGender(gender: number): string {
    if (gender === 1) return '男生';
    if (gender === 0) return '女生';
    return '未知';
  }

  // 列表行组件 (文字类型)
  @Builder TextRow(title: string, value: string) {
    Row() {
      Text(title).fontSize(16).fontColor('#333333').layoutWeight(1)
      Text(value).fontSize(16).fontColor('#888888')
    }
    .width('100%').height(60)
  }

  build() {
    Column() {
      // 自定义头部导航栏
      Row() {
        Image($r('app.media.ic_back')).width(28).height(28)
          .onClick(() => { router.back(); })
        Text('个人信息').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .margin({ left: 15 })
        Blank()
      }
      .width('100%').height(56).padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')

      // 内容列表区
      if (this.currentUser) {
        Column() {
          // 头像行 (特殊处理)
          Row() {
            Text('头像').fontSize(16).fontColor('#333333').layoutWeight(1)
            if (this.currentUser.avatar) {
              Image(this.currentUser.avatar).width(48).height(48).borderRadius(24).objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.ic_avatar_placeholder')).width(48).height(48).borderRadius(24)
            }
          }
          .width('100%').height(80)
          
          Divider().color('#F5F5F5')
          this.TextRow('昵称', this.currentUser.nickname)
          Divider().color('#F5F5F5')
          this.TextRow('健康 ID', this.currentUser.id?.toString() || '--')
          Divider().color('#F5F5F5')
          this.TextRow('性别', this.formatGender(this.currentUser.gender))
          Divider().color('#F5F5F5')
          this.TextRow('生日', this.formatDate(this.currentUser.birthday))
        }
        .width('100%').padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')
        .margin({ top: 15 })
      } else {
        Text('正在加载用户信息...').margin({ top: 50 }).fontColor('#888888')
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 浅灰背景色
  }
}
