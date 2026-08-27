import { THEME_COLOR } from '../../tools/Theme';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { User } from '../../types';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
export struct MinePage {
  @State currentUser: User | null = null;
  
  async aboutToAppear() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.currentUser = await RdbHelper.queryUserById(userId);
    }
  }

  // 自定义单片卡片式列表项
  @Builder MenuItem(icon: Resource, text: string, onClickAction: () => void) {
    Row() {
      Image(icon).width(24).height(24).margin({ right: 15 })
      Text(text).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333').layoutWeight(1)
      Image($r('app.media.ic_arrow_right')).width(20).height(20)
    }
    .width('90%')
    .height(70)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .shadow({ radius: 20, color: '#0D000000', offsetX: 0, offsetY: 5 })
    .margin({ bottom: 15 })
    .onClick(onClickAction)
  }

  build() {
    Column() {
      // 1. 顶部 Header 区域
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          // 右上角设置图标
          Row() {
            Text('我的')
              .fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').layoutWeight(1)
            Image($r('app.media.ic_settings_white')).width(26).height(26)
              .onClick(() => { promptAction.showToast({message: '设置待开发', bottom: 60}); })
          }
          .width('100%').padding({ left: 20, right: 20, top: 20, bottom: 30 })
          
          // 用户信息区
          Row() {
            if (this.currentUser && this.currentUser.avatar) {
              Image(this.currentUser.avatar)
                .width(70).height(70).borderRadius(35)
                .border({ width: 2, color: '#FFFFFF' })
            } else {
              Image($r('app.media.ic_avatar_placeholder'))
                .width(70).height(70).borderRadius(35)
            }
            
            Column({ space: 8 }) {
              Text(this.currentUser?.nickname || '未登录')
                .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
              Text(`健康 ID: ${this.currentUser?.id || '--'}`)
                .fontSize(14).fontColor('#E0E0E0')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 15 })
          }
          .width('100%').padding({ left: 20, right: 20, bottom: 80 })
        }
        .width('100%').height(260)
        .backgroundColor(THEME_COLOR) // 微信绿主色调
        .borderRadius({ bottomLeft: 30, bottomRight: 30 })
      }
      .width('100%')

      // 3. 菜单列表区 (向上偏移，覆盖在绿色背景上)
      Column() {
        this.MenuItem($r('app.media.ic_drink_record'), '喝水记录', () => { promptAction.showToast({message: '喝水记录待开发', bottom: 60}); })
        
        this.MenuItem($r('app.media.ic_check_record'), '打卡记录', () => { promptAction.showToast({message: '打卡记录待开发', bottom: 60}); })
        
        this.MenuItem($r('app.media.ic_sit_record'), '久坐记录', () => { promptAction.showToast({message: '久坐记录待开发', bottom: 60}); })
        
        this.MenuItem($r('app.media.ic_about'), '关于', () => { promptAction.showToast({message: '关于健康打卡 v1.0.0', bottom: 60}); })

        this.MenuItem($r('app.media.ic_logout'), '退出登录', async () => {
          await PreferencesUtil.setCurrentUserId(-1);
          router.replaceUrl({ url: 'pages/login/LoginPage' });
        })
      }
      .width('100%')
      .offset({ y: -40 }) // 让整个列表卡片悬浮在 Header 上
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 浅灰背景色
  }
}
