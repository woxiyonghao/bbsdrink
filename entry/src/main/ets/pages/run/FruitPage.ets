import router from '@ohos.router';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

/** 60 分钟内重置冷却时间（毫秒） */
const COOLDOWN_MS = 60 * 60 * 1000;

/**
 * 吃点水果打卡页面
 */
@Entry
@Component
export struct FruitPage {
  @State activityName: string = '吃点水果';
  @State targetSeconds: number = 300;
  private activityType: number = 204;

  @State isRunning: boolean = false;
  @State isFinished: boolean = false;
  @State showFirework: boolean = false;

  private userId: number = -1;
  @State milliseconds: number = 0;
  private timerId: number = -1;
  private startTime: number = 0;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string | number>;
    if (params) {
      if (params.activityName)  this.activityName  = params.activityName as string;
      if (params.targetSeconds) this.targetSeconds = params.targetSeconds as number;
      if (params.activityType)  this.activityType  = params.activityType as number;
    }
    this.userId = await PreferencesUtil.getCurrentUserId();
    if (this.userId <= 0) return;

    const lastTime = await RdbHelper.queryLastRecordTime(this.userId, this.activityType);
    if (lastTime > 0 && Date.now() - lastTime < COOLDOWN_MS) {
      this.isFinished = true;
      this.milliseconds = this.targetSeconds * 1000;
    }
  }

  /** 格式化毫秒为 MM:SS:ms */
  formatTime(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const mm = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    const ss = (totalSeconds % 60).toString().padStart(2, '0');
    const millis = Math.floor((ms % 1000) / 10).toString().padStart(2, '0');
    return `${mm}:${ss}:${millis}`;
  }

  /** 开始计时 */
  startTimer() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.startTime = Date.now() - this.milliseconds;
    this.timerId = setInterval(() => {
      this.milliseconds = Date.now() - this.startTime;
    }, 10);
  }

  /** 处理停止按钮 */
  handleStopClick() {
    if (this.milliseconds < this.targetSeconds * 1000) {
      AlertDialog.show({
        title: '提示',
        message: '运动进行中，确认停止吗？',
        primaryButton: { value: '取消', action: () => {} },
        secondaryButton: {
          value: '确认',
          fontColor: '#FF5E5E',
          action: () => { this.stopAndReset(); }
        }
      });
      return;
    }
    this.finishTimer();
  }

  /** 中途放弃 */
  stopAndReset() {
    if (this.timerId !== -1) { clearInterval(this.timerId); this.timerId = -1; }
    this.isRunning = false;
    this.isFinished = false;
    this.milliseconds = 0;
  }

  /** 完成计时 */
  async finishTimer() {
    if (this.timerId !== -1) { clearInterval(this.timerId); this.timerId = -1; }
    this.isRunning = false;
    this.isFinished = true;
    this.showFirework = true;

    if (this.userId > 0) {
      await RdbHelper.insertRecord({
        userId: this.userId,
        type: this.activityType,
        value: Math.floor(this.milliseconds / 1000),
        timestamp: Date.now()
      });
    }
    setTimeout(() => { this.showFirework = false; }, 3000);
  }

  aboutToDisappear() {
    if (this.timerId !== -1) clearInterval(this.timerId);
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column().width('100%').height('100%').backgroundColor('#F5F5F5')
      Column().width('100%').height('100%')
        .backgroundColor('rgba(7, 193, 96, 0.05)').backdropBlur(30)

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_back')).width(24).height(24).fillColor(Color.Black)
            .onClick(() => { if (!this.isRunning) router.back(); })
          Text(this.activityName).fontSize(20).fontWeight(FontWeight.Bold)
          Blank().width(24)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 50, bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Blank().height(40)

        // 三态图片
        Stack() {
          if (this.isFinished) {
            Image($r('app.media.zan')).width('75%').aspectRatio(1).objectFit(ImageFit.Contain)
          } else if (this.isRunning) {
            Image($r('app.media.fruit')).width('75%').aspectRatio(1).objectFit(ImageFit.Contain)
              .borderRadius(1000).clip(true)
          } else {
            Image($r('app.media.fruit_static')).width('75%').aspectRatio(1).objectFit(ImageFit.Contain)
              .borderRadius(1000).clip(true)
          }
        }.width('100%').height(300).alignContent(Alignment.Center)

        // 计时
        Text(this.formatTime(this.milliseconds))
          .fontSize(48).fontWeight(FontWeight.Bold).fontColor('#333333')
          .margin({ top: 40, bottom: 60 })

        // 按钮
        Button(this.isRunning ? '停止' : (this.isFinished ? '已完成' : '开始'))
          .width(200).height(50).backgroundColor(Color.Transparent)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: this.isRunning
              ? [['#FFB6C1', 0.0], ['#FF9AA2', 1.0]] as [ResourceColor, number][]
              : (this.isFinished
                  ? [['#A8E063', 0.0], ['#56AB2F', 1.0]] as [ResourceColor, number][]
                  : [['#EF476F', 0.0], ['#D90429', 1.0]] as [ResourceColor, number][])
          })
          .fontColor(Color.White).fontSize(18).fontWeight(FontWeight.Bold)
          .type(ButtonType.Capsule)
          .onClick(() => {
            if (!this.isRunning && !this.isFinished) { this.startTimer(); return; }
            if (this.isRunning) { this.handleStopClick(); }
          })
      }.width('100%').height('100%').alignItems(HorizontalAlign.Center)

      // 烟花
      if (this.showFirework) {
        Stack() {
          Column().width('100%').height('100%').backgroundColor('rgba(0, 0, 0, 0.6)')
          Image($r('app.media.firework')).width('100%').height('100%')
            .blendMode(BlendMode.SCREEN).objectFit(ImageFit.Cover)
        }.width('100%').height('100%').hitTestBehavior(HitTestMode.None)
      }
    }.width('100%').height('100%')
  }
}
