import image from '@ohos.multimedia.image';
import componentSnapshot from '@ohos.arkui.componentSnapshot';
import { ImageSaveUtil } from '../../tools/ImageSaveUtil';

@CustomDialog
export struct AchievementPosterDialog {
  controller?: CustomDialogController;
  @Prop nickname: string;
  @Prop totalDays: number;
  @Prop totalWater: number;
  @Prop totalActivity: number;

  build() {
    Column() {
      Column() {
        // 海报主体
        Column() {
          Text('健康成就墙')
            .fontSize(28)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
            .margin({ top: 30, bottom: 20 })

          Image($r('app.media.ic_trophy'))
            .width(80)
            .height(80)
            .fillColor('#FFD700')
            .margin({ bottom: 20 })

          Text(`亲爱的 ${this.nickname}`)
            .fontSize(18)
            .fontColor('#EEEEEE')
            .margin({ bottom: 30 })

          Row() {
            Column() {
              Text('累计打卡').fontSize(14).fontColor('#AAAAAA')
              Text(`${this.totalDays} 天`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#07C160').margin({ top: 8 })
            }.layoutWeight(1)

            Column() {
              Text('累计饮水').fontSize(14).fontColor('#AAAAAA')
              Text(`${this.totalWater} ml`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#8ECAE6').margin({ top: 8 })
            }.layoutWeight(1)

            Column() {
              Text('累计运动').fontSize(14).fontColor('#AAAAAA')
              Text(`${this.totalActivity} 分钟`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FF7F50').margin({ top: 8 })
            }.layoutWeight(1)
          }.width('100%').padding({ left: 10, right: 10 })
          
          Blank()
          
          Text('每一滴汗水与水分，都在塑造更好的你')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ bottom: 20 })
        }
        .width('100%')
        .height(400)
        .backgroundColor('#1C1C1E')
        .borderRadius(16)
        .id('achievement_poster_id')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.Transparent)

      Button('保存到系统相册')
        .width('80%')
        .height(45)
        .backgroundColor('#07C160')
        .margin({ top: 10, bottom: 20 })
        .onClick(() => {
          componentSnapshot.get('achievement_poster_id', (error: Error, pixmap: image.PixelMap) => {
            if (pixmap) {
              ImageSaveUtil.savePixelMapToGallery(pixmap);
            }
          })
        })
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
  }
}

@CustomDialog
export struct DailyPosterDialog {
  controller?: CustomDialogController;
  @Prop nickname: string;
  @Prop dateStr: string;
  @Prop todayWater: number;
  @Prop todayActivityDuration: number;
  @Prop todayActivityCount: number;

  build() {
    Column() {
      Column() {
        // 海报主体
        Column() {
          Text('每日健康报告')
            .fontSize(28)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
            .margin({ top: 30, bottom: 10 })

          Text(this.dateStr)
            .fontSize(16)
            .fontColor('#07C160')
            .margin({ bottom: 30 })

          Row() {
            Column() {
              Image($r('app.media.ic_drink_water')).width(40).height(40).fillColor('#8ECAE6')
              Text('今日饮水').fontSize(14).fontColor('#AAAAAA').margin({ top: 10 })
              Text(`${this.todayWater} ml`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').margin({ top: 8 })
            }.layoutWeight(1)

            Column() {
              Image($r('app.media.ic_sport_white')).width(40).height(40).fillColor('#34C759')
              Text('今日运动').fontSize(14).fontColor('#AAAAAA').margin({ top: 10 })
              Text(`${this.todayActivityDuration} 分钟`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').margin({ top: 8 })
            }.layoutWeight(1)
          }.width('100%')
          
          Row() {
            Text(`共计活动 ${this.todayActivityCount} 次`)
              .fontSize(14)
              .fontColor('#AAAAAA')
          }.margin({ top: 20 })
          
          Blank()
          
          Text(`${this.nickname}，今天也辛苦啦！`)
            .fontSize(14)
            .fontColor('#888888')
            .margin({ bottom: 20 })
        }
        .width('100%')
        .height(400)
        .backgroundColor('#1C1C1E')
        .borderRadius(16)
        .id('daily_poster_id')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.Transparent)

      Button('保存到系统相册')
        .width('80%')
        .height(45)
        .backgroundColor('#07C160')
        .margin({ top: 10, bottom: 20 })
        .onClick(() => {
          componentSnapshot.get('daily_poster_id', (error: Error, pixmap: image.PixelMap) => {
            if (pixmap) {
              ImageSaveUtil.savePixelMapToGallery(pixmap);
            }
          })
        })
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
  }
}
