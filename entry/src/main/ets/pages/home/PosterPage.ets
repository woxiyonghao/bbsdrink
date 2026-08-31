import router from '@ohos.router';
import componentSnapshot from '@ohos.arkui.componentSnapshot';
import { ImageSaveUtil } from '../../tools/ImageSaveUtil';
import image from '@ohos.multimedia.image';

@Entry
@Component
export struct PosterPage {
  @State type: string = 'daily';
  
  @State nickname: string = '';
  @State dateStr: string = '';
  
  // Daily data
  @State todayWater: number = 0;
  @State todayActivityDuration: number = 0;
  @State todayActivityCount: number = 0;

  // Achievement data
  @State totalDays: number = 0;
  @State totalWater: number = 0;
  @State totalActivity: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number>;
    if (params) {
      if (params.type) this.type = params.type as string;
      if (params.nickname) this.nickname = params.nickname as string;
      if (params.dateStr) this.dateStr = params.dateStr as string;
      if (params.todayWater !== undefined) this.todayWater = params.todayWater as number;
      if (params.todayActivityDuration !== undefined) this.todayActivityDuration = params.todayActivityDuration as number;
      if (params.todayActivityCount !== undefined) this.todayActivityCount = params.todayActivityCount as number;
      if (params.totalDays !== undefined) this.totalDays = params.totalDays as number;
      if (params.totalWater !== undefined) this.totalWater = params.totalWater as number;
      if (params.totalActivity !== undefined) this.totalActivity = params.totalActivity as number;
    }
  }
  build() {
    Column() {
      // Top Navigation Bar
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Text(this.type === 'achievement' ? '健康成就墙' : '每日健康报告')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, top: 20, bottom: 20 })
      .alignItems(VerticalAlign.Center)

      // Content
      if (this.type === 'achievement' && this.totalDays === 0 && this.totalWater === 0 && this.totalActivity === 0) {
        this.EmptyState()
      } else if (this.type === 'daily' && this.todayWater === 0 && this.todayActivityDuration === 0) {
        this.EmptyState()
      } else {
        this.PosterContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder EmptyState() {
    Column() {
      Image($r('app.media.run_empty'))
        .width(180)
        .height(180)
        .margin({ bottom: 20, top: 100 })
      
      Text('当前还没有任何数据喔~')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 30 })

      Button('去运动')
        .width(200)
        .height(45)
        .backgroundColor('#07C160')
        .fontColor('#FFFFFF')
        .borderRadius(22.5)
        .onClick(() => {
          // 跳转到打卡模块下的运动一下
          router.replaceUrl({ url: 'pages/run/RunPage' });
        })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder PosterContent() {
    Column() {
      Column() {
        if (this.type === 'achievement') {
          // Achievement UI
          Column() {
            Text('健康成就墙')
              .fontSize(28)
              .fontWeight(FontWeight.Bolder)
              .fontColor('#333333')
              .margin({ top: 30, bottom: 20 })

            Image($r('app.media.ic_trophy'))
              .width(80)
              .height(80)
              .fillColor('#07C160')
              .margin({ bottom: 20 })

            Text(`亲爱的 ${this.nickname}`)
              .fontSize(18)
              .fontColor('#666666')
              .margin({ bottom: 30 })

            Row() {
              Column() {
                Text('累计打卡').fontSize(14).fontColor('#999999')
                Text(`${this.totalDays}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
                Text('天').fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column() {
                Text('累计饮水').fontSize(14).fontColor('#999999')
                Text(`${this.totalWater}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
                Text('ml').fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column() {
                Text('累计运动').fontSize(14).fontColor('#999999')
                Text(`${this.totalActivity}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
                Text('分钟').fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }.width('100%').padding({ left: 10, right: 10 })
            
            Blank()
            
            Text('每一滴汗水与水分，都在塑造更好的你')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ bottom: 20 })
          }
          .width('100%')
          .height(400)
          .backgroundColor('#F5F7FA')
          .borderRadius(16)
        } else {
          // Daily UI
          Column() {
            Text('每日健康报告')
              .fontSize(28)
              .fontWeight(FontWeight.Bolder)
              .fontColor('#333333')
              .margin({ top: 30, bottom: 10 })

            Text(this.dateStr)
              .fontSize(16)
              .fontColor('#07C160')
              .margin({ bottom: 30 })

            Row() {
              Column() {
                Image($r('app.media.ic_drink_water')).width(40).height(40).fillColor('#07C160')
                Text('今日饮水').fontSize(14).fontColor('#999999').margin({ top: 10 })
                Text(`${this.todayWater}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
                Text('ml').fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column() {
                Image($r('app.media.ic_sport_white')).width(40).height(40).fillColor('#07C160')
                Text('今日运动').fontSize(14).fontColor('#999999').margin({ top: 10 })
                Text(`${this.todayActivityDuration}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
                Text('分钟').fontSize(12).fontColor('#999999').margin({ top: 4 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }.width('100%')
            
            Row() {
              Text(`共计活动 ${this.todayActivityCount} 次`)
                .fontSize(14)
                .fontColor('#999999')
            }.margin({ top: 20 })
            
            Blank()
            
            Text(`${this.nickname}，今天也辛苦啦！`)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 20 })
          }
          .width('100%')
          .height(400)
          .backgroundColor('#F5F7FA')
          .borderRadius(16)
        }
      }
      .id('poster_card_id')
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .shadow({ radius: 15, color: 'rgba(0, 0, 0, 0.1)', offsetY: 5 })
      .margin({ top: 20 })

      Blank()

      Button('保存到系统相册')
        .width('80%')
        .height(45)
        .backgroundColor('#07C160')
        .margin({ bottom: 40 })
        .onClick(() => {
          componentSnapshot.get('poster_card_id', (error: Error, pixmap: image.PixelMap) => {
            if (pixmap) {
              ImageSaveUtil.savePixelMapToGallery(pixmap);
            }
          })
        })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}
