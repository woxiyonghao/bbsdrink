import router from '@ohos.router';
import { ActivityItem } from '../../types';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

@Entry
@Component
export struct StretchPage {
  @State activityName: string = '伸懒腰';
  @State targetSeconds: number = 60;
  
  @State isRunning: boolean = false;
  @State isFinished: boolean = false;
  @State showFirework: boolean = false;
  private userId: number = -1;
  
  @State milliseconds: number = 0;
  private timerId: number = -1;
  private startTime: number = 0;
  
  async aboutToAppear() {
    let params = router.getParams() as Record<string, string | number>;
    if (params && params.activityName) {
      this.activityName = params.activityName as string;
      this.targetSeconds = (params.targetSeconds as number) || 60;
    }
    this.userId = await PreferencesUtil.getCurrentUserId();
    if (this.userId > 0) {
      let lastTime = await RdbHelper.queryLastRecordTime(this.userId, 5); // 5 代表伸懒腰等运动
      if (Date.now() - lastTime < 60 * 60 * 1000) {
        // Less than 60 minutes
        this.isFinished = true;
        this.milliseconds = this.targetSeconds * 1000;
      }
    }
  }

  formatTime(ms: number): string {
    let totalSeconds = Math.floor(ms / 1000);
    let mm = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    let ss = (totalSeconds % 60).toString().padStart(2, '0');
    let millis = Math.floor((ms % 1000) / 10).toString().padStart(2, '0');
    return `${mm}:${ss}:${millis}`;
  }

  startTimer() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.startTime = Date.now() - this.milliseconds;
    
    this.timerId = setInterval(() => {
      this.milliseconds = Date.now() - this.startTime;
      if (this.milliseconds >= this.targetSeconds * 1000) {
        this.milliseconds = this.targetSeconds * 1000;
        this.stopTimer();
      }
    }, 10); // Update every 10ms for smooth millisecond display
  }

  async stopTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
    this.isFinished = true;
    this.showFirework = true;
    
    // 记录到数据库
    if (this.userId > 0) {
      await RdbHelper.insertRecord({
        userId: this.userId,
        type: 5,
        value: this.targetSeconds,
        timestamp: Date.now()
      });
    }

    setTimeout(() => {
      this.showFirework = false;
    }, 3000);
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 1. Background with blur effect similar to TabsPage
      Column() {
        // Just a nice background gradient to match the requested look
        Row().width('100%').height('100%')
          .backgroundColor('#F5F5F5')
      }.width('100%').height('100%')
      
      // We can add the glass effect layer
      Column().width('100%').height('100%')
        .backgroundColor('rgba(7, 193, 96, 0.05)')
        .backdropBlur(30)

      // 2. Main Content
      Column() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor(Color.Black)
            .onClick(() => {
              if (this.isRunning) {
                // Cannot stop while running
                return;
              }
              router.back();
            })
          Blank()
        }.width('100%').padding({ left: 20, right: 20, top: 40 })

        Text(this.activityName)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 40 })

        // Center Icon
        Stack() {
          if (this.isFinished) {
            Image($r('app.media.zan'))
              .width('75%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
          } else if (this.isRunning) {
            Image($r('app.media.stretch'))
              .width('75%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .borderRadius(1000) // Circular
              .clip(true)
          } else {
            Image($r('app.media.stretch_static'))
              .width('75%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .borderRadius(1000) // Circular
              .clip(true)
          }
        }
        .width('100%')
        .height(300)
        .alignContent(Alignment.Center)

        // Timer
        Text(this.formatTime(this.milliseconds))
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 40, bottom: 60 })

        // Start Button
        Button(this.isRunning ? '进行中...' : (this.isFinished ? '已完成' : '开始'))
          .width(200)
          .height(50)
          .backgroundColor(Color.Transparent)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]]
          })
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .type(ButtonType.Capsule)
          .opacity(this.isRunning || this.isFinished ? 0.6 : 1.0)
          .onClick(() => {
            if (!this.isRunning && !this.isFinished) {
              this.startTimer();
            }
          })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      // 3. Firework overlay
      if (this.showFirework) {
        Image($r('app.media.firework'))
          .width('100%')
          .height(400)
          .blendMode(BlendMode.SCREEN)
          .objectFit(ImageFit.Cover)
          .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }
}
