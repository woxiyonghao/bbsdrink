import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
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
      // No automatic stop! User must click stop.
    }, 10);
  }

  handleStopClick() {
    if (this.milliseconds < this.targetSeconds * 1000) {
      // Early stop
      promptAction.showDialog({
        title: '提示',
        message: '运动进行中，确认停止吗？',
        buttons: [
          { text: '取消', color: '#999999' },
          { text: '确认', color: '#FF5E5E' }
        ]
      }).then(data => {
        if (data.index === 1) {
          // Confirm stop -> Reset
          if (this.timerId !== -1) {
            clearInterval(this.timerId);
            this.timerId = -1;
          }
          this.isRunning = false;
          this.isFinished = false;
          this.milliseconds = 0;
        }
      });
    } else {
      // Finished
      this.finishTimer();
    }
  }

  async finishTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
    this.isFinished = true;
    this.showFirework = true;
    
    if (this.userId > 0) {
      await RdbHelper.insertRecord({
        userId: this.userId,
        type: 5,
        value: Math.floor(this.milliseconds / 1000), // save actual elapsed seconds
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
              if (this.isRunning) return;
              router.back();
            })
          
          Text(this.activityName)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            
          Blank().width(24) // To balance the back icon for absolute center
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 50, bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        
        Blank().height(40)

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

        // Action Button
        Button(this.isRunning ? '停止' : (this.isFinished ? '已完成' : '开始'))
          .width(200)
          .height(50)
          .backgroundColor(Color.Transparent)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: this.isRunning 
              ? [['#FFB6C1', 0.0], ['#FF9AA2', 1.0]] as [ResourceColor, number][] // Light Pink for Stop
              : (this.isFinished 
                  ? [['#A8E063', 0.0], ['#56AB2F', 1.0]] as [ResourceColor, number][] // Light Green for Completed
                  : [['#8ECAE6', 0.0], ['#219EBC', 1.0]] as [ResourceColor, number][]) // Light Blue for Start
          })
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .type(ButtonType.Capsule)
          .onClick(() => {
            if (!this.isRunning && !this.isFinished) {
              this.startTimer();
            } else if (this.isRunning) {
              this.handleStopClick();
            }
          })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      // 3. Firework overlay
      if (this.showFirework) {
        Stack() {
          // 黑色半透明蒙层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.6)')
            
          Image($r('app.media.firework'))
            .width('100%')
            .height('100%')
            .blendMode(BlendMode.SCREEN)
            .objectFit(ImageFit.Cover)
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }
}
