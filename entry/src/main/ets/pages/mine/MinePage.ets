import { THEME_COLOR } from '../../tools/Theme';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { User } from '../../types';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@CustomDialog
export struct LogoutDialog {
  controller: CustomDialogController
  cancel: () => void = () => {}
  confirm: () => void = () => {}

  build() {
    Column() {
      Text('退出登录')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ top: 24, bottom: 12 })
      
      Text('确认要退出当前账号吗？')
        .fontSize(15)
        .fontColor('#666666')
        .margin({ bottom: 24 })

      Divider().color('rgba(0, 0, 0, 0.05)')

      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#888888')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller.close()
            this.cancel()
          })
        
        Divider().vertical(true).height('100%').color('rgba(0, 0, 0, 0.05)')
        
        Text('退出')
          .fontSize(16)
          .fontColor('#ff4d4f')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller.close()
            this.confirm()
          })
      }
      .width('100%')
      .height(50)
    }
    .width(280)
    .backgroundColor('rgba(255, 255, 255, 0.6)') // 液态毛玻璃背景，较低透明度
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(20)
  }
}

@Entry
@Component
export struct MinePage {
  @State currentUser: User | null = null;
  @State scaleValue: number = 1;
  @State opacityValue: number = 1;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: LogoutDialog({
      cancel: () => {},
      confirm: () => {
        animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
          this.scaleValue = 0.8;
          this.opacityValue = 0;
        });
        setTimeout(async () => {
          await PreferencesUtil.setCurrentUserId(-1);
          router.replaceUrl({ url: 'pages/login/LoginPage' });
        }, 400);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  })
  
  @Prop @Watch('onTabChange') currentTabIndex: number = 0;

  async onTabChange() {
    if (this.currentTabIndex === 2) {
      const userId: number = await PreferencesUtil.getCurrentUserId();
      if (userId > 0) {
        this.currentUser = await RdbHelper.queryUserById(userId);
      }
    }
  }

  async aboutToAppear() {
    const userId: number = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.currentUser = await RdbHelper.queryUserById(userId);
    }
  }

  // 自定义列表项
  @Builder ListItem(icon: Resource, text: string, onClickAction: () => void) {
    Row() {
      Image(icon).width(22).height(22).margin({ right: 12 })
      Text(text).fontSize(15).fontColor('#333333').layoutWeight(1)
      Image($r('app.media.ic_arrow_right')).width(16).height(16)
    }
    .width('100%')
    .height(54)
    .padding({ left: 15, right: 15 })
    .backgroundColor('#FFFFFF')
    .onClick(onClickAction)
  }

  // 自定义宫格项 (健康记录)
  @Builder GridItem(icon: Resource, text: string, onClickAction: () => void) {
    Column({ space: 8 }) {
      Image(icon).width(32).height(32)
      Text(text).fontSize(13).fontColor('#666666')
    }
    .layoutWeight(1)
    .onClick(onClickAction)
  }

  build() {
    Column() {
      // 1. 顶部 Header 区域 (居中头像排版)
      Stack({ alignContent: Alignment.Top }) {
        // 设置按钮 (右上角单图标)
        Row() {
          Image($r('app.media.ic_settings_white')).width(20).height(20)
        }
        .width(36).height(36)
        .backgroundColor('#33000000') // 黑色半透明
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .position({ right: 12, top: 20 })
        .onClick(() => { router.pushUrl({ url: 'pages/mine/SettingPage' }); })

        // 居中头像与昵称
        Column() {
          if (this.currentUser && this.currentUser.avatar) {
            Image(this.currentUser.avatar)
              .width(84).height(84).borderRadius(42)
              .border({ width: 3, color: '#FFFFFF' })
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.ic_avatar_placeholder'))
              .width(84).height(84).borderRadius(42)
              .border({ width: 3, color: '#FFFFFF' })
          }
          
          Text(this.currentUser?.nickname || '未登录')
            .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
            .margin({ top: 15 })
        }
        .width('100%')
        .margin({ top: 80 })
      }
      .width('100%').height(240)
      .backgroundColor(THEME_COLOR) // 保持微信绿主色调

      // 2. 核心功能区 (宫格样式)
      Column() {
        Row() {
          Image($r('app.media.ic_check_record')).width(20).height(20).margin({ right: 10 })
          Text('健康记录').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333333').layoutWeight(1)
          // 移除了这里的向右箭头
        }
        .width('100%').height(50).padding({ left: 15, right: 15 })
        
        Divider().color('#F5F5F5').margin({ left: 15, right: 15 })
        
        Row() {
          this.GridItem($r('app.media.ic_drink_record'), '喝水记录', () => { router.pushUrl({ url: 'pages/mine/DrinkHistoryPage' }); })
          this.GridItem($r('app.media.ic_sport_record'), '运动记录', () => { router.pushUrl({ url: 'pages/mine/ActivityRecordPage' }); })
          this.GridItem($r('app.media.ic_check_record'), '打卡记录', () => { router.pushUrl({ url: 'pages/home/CheckInCalendarPage' }); })
        }
        .width('100%').padding({ top: 20, bottom: 20 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .margin({ top: 0 })

      // 3. 列表菜单区
      Column() {
        this.ListItem($r('app.media.ic_about'), '关于', () => { 
          router.pushUrl({ url: 'pages/mine/AboutPage' }) 
        })
        
        Divider().color('#F5F5F5').margin({ left: 45 })
        
        this.ListItem($r('app.media.ic_logout'), '退出登录', () => {
          this.dialogController.open()
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .margin({ top: 10 })
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 经典浅灰背景
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .opacity(this.opacityValue)
  }
}
