import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
@Entry
@Component
export struct DingPage {
  @State userId: number = -1;
  @State isCheckedIn: boolean = false;
  @State shakeAngle: number = 0;
  
  // 动效：泼洒飞溅的液滴 (更加写实的轨迹)
  @State splashLeftX: number = 0;
  @State splashLeftY: number = 0;
  @State splashLeftOpacity: number = 0;

  @State splashRightX: number = 0;
  @State splashRightY: number = 0;
  @State splashRightOpacity: number = 0;
  
  private shakeInterval: number = -1;

  async aboutToAppear() {
    this.userId = await PreferencesUtil.getCurrentUserId();
    if (this.userId > 0) {
      this.isCheckedIn = await RdbHelper.hasCheckedInToday(this.userId);
    }
    this.startShakeAnimation();
  }

  aboutToDisappear() {
    this.stopShakeAnimation();
  }

  startShakeAnimation() {
    if (this.isCheckedIn) return;
    
    // 定时循环：杯子抖动 + 飞溅
    this.shakeInterval = setInterval(() => {
      if (this.isCheckedIn) return;
      
      // 准备阶段：重置水滴位置 (藏在杯口)
      this.splashRightX = 0;
      this.splashRightY = -30;
      this.splashRightOpacity = 0;
      
      this.splashLeftX = 0;
      this.splashLeftY = -30;
      this.splashLeftOpacity = 0;
      
      // ==========================================
      // 1. 杯子极速左右摇摆 (快)
      // ==========================================
      animateTo({ duration: 50, curve: Curve.EaseInOut }, () => { this.shakeAngle = -25; })
      setTimeout(() => {
        animateTo({ duration: 100, curve: Curve.EaseInOut }, () => { this.shakeAngle = 25; })
      }, 50);
      setTimeout(() => {
        animateTo({ duration: 100, curve: Curve.EaseInOut }, () => { this.shakeAngle = -25; })
      }, 150);
      setTimeout(() => {
        animateTo({ duration: 50, curve: Curve.EaseInOut }, () => { this.shakeAngle = 0; })
      }, 250);

      // ==========================================
      // 2. 抛物线水滴泼洒 (完整上升与下落)
      // ==========================================
      // 右侧水滴飞出 (当杯子向左摇时触发)
      this.splashRightOpacity = 1;
      
      // X轴匀速向外飞 (总时长 600ms)
      animateTo({ duration: 600, curve: Curve.Linear }, () => {
        this.splashRightX = 140;
      })
      // Y轴上升阶段 (前半段，减速抗拒重力到达最高点)
      animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.splashRightY = -100;
      })
      // Y轴下落阶段 (后半段，加速坠落)
      animateTo({ duration: 300, delay: 300, curve: Curve.EaseIn }, () => {
        this.splashRightY = 30; // 跌落到比起始点更低的位置
      })
      // 在坠落过程中渐隐消失
      animateTo({ duration: 200, delay: 400, curve: Curve.Linear }, () => {
        this.splashRightOpacity = 0;
      })

      // 左侧水滴飞出 (延迟 100ms 匹配杯子向右摇的时机)
      setTimeout(() => {
        this.splashLeftOpacity = 1;
        
        animateTo({ duration: 600, curve: Curve.Linear }, () => {
          this.splashLeftX = -140;
        })
        animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
          this.splashLeftY = -100;
        })
        animateTo({ duration: 300, delay: 300, curve: Curve.EaseIn }, () => {
          this.splashLeftY = 30;
        })
        animateTo({ duration: 200, delay: 400, curve: Curve.Linear }, () => {
          this.splashLeftOpacity = 0;
        })
      }, 100);

    }, 1500); // 间隔时间拉长，让慢速的泼洒下落动画能完整展示完毕
  }

  stopShakeAnimation() {
    if (this.shakeInterval !== -1) {
      clearInterval(this.shakeInterval);
      this.shakeInterval = -1;
      this.shakeAngle = 0;
    }
  }

  async handleCheckIn() {
    if (!this.isCheckedIn) {
      if (this.userId > 0) {
        await RdbHelper.insertRecord({
          userId: this.userId,
          type: 4, // 每日签到
          value: 1,
          timestamp: new Date().getTime()
        });
      }
      this.isCheckedIn = true;
      this.stopShakeAnimation();
      animateTo({ duration: 300, curve: Curve.Friction }, () => {
        this.shakeAngle = 0;
        this.splashLeftOpacity = 0;
        this.splashRightOpacity = 0;
      })
      promptAction.showToast({ message: '今日签到成功！' });
    } else {
      router.pushUrl({ url: 'pages/home/CheckInCalendarPage' });
    }
  }

  build() {
    Column() {
      // 顶部 Nav
      Row() {
        Text('Ding')
          .fontSize(32)
          .fontWeight(FontWeight.Bolder)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 25, top: 40, bottom: 10 })

      // 中心打卡大按钮
      Column() {
        Stack() {
          // 左侧飞溅的写实水滴
          Row({ space: 4 }) {
            Circle().width(6).height(6).fill('#8ECAE6')
            Circle().width(10).height(10).fill('#8ECAE6').margin({ top: -10 })
            Circle().width(4).height(4).fill('#8ECAE6')
          }
          .opacity(this.splashLeftOpacity)
          .translate({ x: this.splashLeftX, y: this.splashLeftY })
          
          // 右侧飞溅的写实水滴
          Row({ space: 4 }) {
            Circle().width(4).height(4).fill('#8ECAE6')
            Circle().width(10).height(10).fill('#8ECAE6').margin({ top: -10 })
            Circle().width(6).height(6).fill('#8ECAE6')
          }
          .opacity(this.splashRightOpacity)
          .translate({ x: this.splashRightX, y: this.splashRightY })

          // 核心玻璃杯
          Image($r('app.media.ic_cup_water'))
            .width(140)
            .height(140)
            .objectFit(ImageFit.Contain)
            .fillColor(this.isCheckedIn ? '#07C160' : '#D3D3D3') // 未打卡为浅灰，打卡为微信绿
            .rotate({ angle: this.shakeAngle })
            .onClick(() => {
              this.handleCheckIn();
            })
        }
        .width(200)
        .height(180)
        .alignContent(Alignment.Center)
        
        Text(this.isCheckedIn ? '今日已打卡' : '点击打卡')
          .fontSize(16)
          .fontColor(this.isCheckedIn ? '#07C160' : '#888888')
          .margin({ top: 20 })
          .fontWeight(FontWeight.Medium)
      }
      .margin({ top: 40, bottom: 50 })

      // 底部精美卡片 (各占一行)
      Column({ space: 20 }) {
        // 喝水卡片
        Row() {
          Text('喝水')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)
            .margin({ left: 25 })
          
          Image($r('app.media.ic_water_glass_white'))
            .width(50)
            .height(50)
            .margin({ right: 25 })
            .opacity(0.9)
        }
        .width('100%')
        .height(120) // 增高，占满单行
        .borderRadius(20)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]] // 浅蓝色渐变
        })
        .shadow({ radius: 12, color: '#4D219EBC', offsetY: 6 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/ding/DrinkRecordPage' });
        })

        // 久坐运动卡片
        Row() {
          Text('起来走走')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)
            .margin({ left: 25 })
          
          Image($r('app.media.ic_sport_white'))
            .width(50)
            .height(50)
            .margin({ right: 25 })
            .opacity(0.9)
        }
        .width('100%')
        .height(120) // 增高，占满单行
        .borderRadius(20)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#A8E063', 0.0], ['#56AB2F', 1.0]] // 浅绿色渐变
        })
        .shadow({ radius: 12, color: '#4D56AB2F', offsetY: 6 })
        .onClick(() => {
          promptAction.showToast({ message: '功能未开发，请稍等。' });
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
