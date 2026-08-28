import router from '@ohos.router';

@Entry
@Component
export struct AboutPage {
  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24)
          .onClick(() => router.back())
        Text('关于应用')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 图标与版本信息
      Column() {
        Image($r('app.media.app_icon'))
          .width(100)
          .height(100)
          .borderRadius(20)
          .margin({ top: 60, bottom: 24 })
          .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.1)', offsetY: 4 })

        Text('健康打卡 (Drink App)')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text('Version 1.0.0')
          .fontSize(14)
          .fontColor('#888888')
          .margin({ bottom: 40 })
      }
      .width('100%')

      // 其他信息
      Column() {
        Text('本项目是一个基于 HarmonyOS 开发的纯本地健康习惯打卡应用，致力于帮助用户养成按时喝水、避免久坐的良好生活习惯。')
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(22)
          .textAlign(TextAlign.Center)
          .padding({ left: 32, right: 32 })
      }
      
      Blank()

      Text('Copyright © 2026. All Rights Reserved.')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .margin({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
