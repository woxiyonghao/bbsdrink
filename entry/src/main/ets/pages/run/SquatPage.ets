import router from '@ohos.router';
import { ActivityItem } from '../../types';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

/**
 * 深蹲打卡页面
 * 逻辑与 StretchPage 一致，仅图片资源和默认时长不同
 */
@Entry
@Component
export struct SquatPage {
  /** 活动名称，由路由参数传入 */
  @State activityName: string = '深蹲一下';
  /** 目标秒数，由路由参数传入，默认 180 秒（3 分钟） */
  @State targetSeconds: number = 180;

  @State isRunning: boolean = false;
  @State isFinished: boolean = false;
  @State showFirework: boolean = false;

  private userId: number = -1;
  @State milliseconds: number = 0;
  private timerId: number = -1;
  private startTime: number = 0;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string | number>;
    if (params && params.activityName) {
      this.activityName = params.activityName as string;
      this.targetSeconds = (params.targetSeconds as number) || 180;
    }

    this.userId = await PreferencesUtil.getCurrentUserId();
    if (this.userId <= 0) return;

    // 查询上次深蹲记录时间（type=6 代表深蹲）
    const lastTime = await RdbHelper.queryLastRecordTime(this.userId, 6);
    if (Date.now() - lastTime < 60 * 60 * 1000) {
      // 距上次打卡不足 1 小时，直接显示已完成状态
      this.isFinished = true;
      this.milliseconds = this.targetSeconds * 1000;
    }
  }

  /**
   * 格式化毫秒数为 MM:SS:ms 字符串
   * @param ms 毫秒数
   */
  formatTime(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const mm = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    const ss = (totalSeconds % 60).toString().padStart(2, '0');
    const millis = Math.floor((ms % 1000) / 10).toString().padStart(2, '0');
    return `${mm}:${ss}:${millis}`;
  }

  /** 开始计时器 */
  startTimer() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.startTime = Date.now() - this.milliseconds;
    this.timerId = setInterval(() => {
      this.milliseconds = Date.now() - this.startTime;
      // 不自动停止，等待用户主动点击停止
    }, 10);
  }

  /** 处理停止按钮点击：未达标则询问，已达标则完成 */
  handleStopClick() {
    if (this.milliseconds < this.targetSeconds * 1000) {
      // 未达目标，弹窗确认是否中途放弃
      AlertDialog.show({
        title: '提示',
        message: '运动进行中，确认停止吗？',
        primaryButton: {
          value: '取消',
          action: () => {}
        },
        secondaryButton: {
          value: '确认',
          fontColor: '#FF5E5E',
          action: () => {
            this.stopAndReset();
          }
        }
      });
      return;
    }
    // 已达目标，直接完成
    this.finishTimer();
  }

  /** 停止计时并重置状态 */
  stopAndReset() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
    this.isFinished = false;
    this.milliseconds = 0;
  }

  /** 完成计时：保存记录并展示烟花动效 */
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
        type: 6, // 6 代表深蹲
        value: Math.floor(this.milliseconds / 1000),
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
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')

      // 绿色半透明磨砂层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(7, 193, 96, 0.05)')
        .backdropBlur(30)

      // 主内容层
      Column() {
        // 顶部导航栏
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

          // 占位，使标题居中
          Blank().width(24)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 50, bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Blank().height(40)

        // 中央图片区域
        Stack() {
          if (this.isFinished) {
            // 完成后展示点赞图
            Image($r('app.media.zan'))
              .width('75%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
          } else if (this.isRunning) {
            // 运动中展示深蹲 GIF
            Image($r('app.media.squat'))
              .width('75%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .borderRadius(1000)
              .clip(true)
          } else {
            // 待开始展示深蹲 GIF（静止帧）
            Image($r('app.media.squat'))
              .width('75%')
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .borderRadius(1000)
              .clip(true)
          }
        }
        .width('100%')
        .height(300)
        .alignContent(Alignment.Center)

        // 计时器数字
        Text(this.formatTime(this.milliseconds))
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 40, bottom: 60 })

        // 操作按钮
        Button(this.isRunning ? '停止' : (this.isFinished ? '已完成' : '开始'))
          .width(200)
          .height(50)
          .backgroundColor(Color.Transparent)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: this.isRunning
              ? [['#FFB6C1', 0.0], ['#FF9AA2', 1.0]] as [ResourceColor, number][] // 粉红色：停止中
              : (this.isFinished
                  ? [['#A8E063', 0.0], ['#56AB2F', 1.0]] as [ResourceColor, number][] // 绿色：已完成
                  : [['#FFB75E', 0.0], ['#ED8F03', 1.0]] as [ResourceColor, number][]) // 橙色：待开始
          })
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .type(ButtonType.Capsule)
          .onClick(() => {
            if (!this.isRunning && !this.isFinished) {
              this.startTimer();
              return;
            }
            if (this.isRunning) {
              this.handleStopClick();
            }
          })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      // 烟花动效蒙层
      if (this.showFirework) {
        Stack() {
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
