import promptAction from '@ohos.promptAction';

@Entry
@Component
export struct DingPage {
  @State isCheckedIn: boolean = false;
  @State shakeAngle: number = 0;
  
  // 动效：泼洒/飞溅的水滴
  @State splashOffsetLeft: number = -10;
  @State splashOffsetRight: number = 10;
  @State splashOpacityLeft: number = 0;
  @State splashOpacityRight: number = 0;
  
  private shakeInterval: number = -1;

  aboutToAppear() {
    this.startShakeAnimation();
  }

  aboutToDisappear() {
    this.stopShakeAnimation();
  }

  startShakeAnimation() {
    if (this.isCheckedIn) return;
    // 持续的高频抖动，并伴随水滴泼洒效果（日漫摇头感）
    this.shakeInterval = setInterval(() => {
      if (this.isCheckedIn) return;
      
      // 1. 杯子向左摇，右边水滴飞出
      animateTo({ duration: 40, curve: Curve.Linear }, () => { 
        this.shakeAngle = -20; 
        this.splashOpacityRight = 1;
        this.splashOffsetRight = 40;
      })
      
      // 2. 杯子向右摇，右边水滴消失，左边水滴飞出
      setTimeout(() => {
        animateTo({ duration: 80, curve: Curve.Linear }, () => { 
          this.shakeAngle = 20; 
          this.splashOpacityRight = 0;
          this.splashOffsetRight = 10;
          this.splashOpacityLeft = 1;
          this.splashOffsetLeft = -40;
        })
      }, 40);
      
      // 3. 杯子再向左摇，左边水滴消失，右边水滴再次飞出
      setTimeout(() => {
        animateTo({ duration: 80, curve: Curve.Linear }, () => { 
          this.shakeAngle = -20; 
          this.splashOpacityLeft = 0;
          this.splashOffsetLeft = -10;
          this.splashOpacityRight = 1;
          this.splashOffsetRight = 40;
        })
      }, 120);
      
      // 4. 回正，水滴收回隐藏
      setTimeout(() => {
        animateTo({ duration: 40, curve: Curve.Linear }, () => { 
          this.shakeAngle = 0; 
          this.splashOpacityRight = 0;
          this.splashOffsetRight = 10;
        })
      }, 200);
      
    }, 800); // 抖动间隔
  }

  stopShakeAnimation() {
    if (this.shakeInterval !== -1) {
      clearInterval(this.shakeInterval);
      this.shakeInterval = -1;
      this.shakeAngle = 0;
    }
  }

  handleCheckIn() {
    if (!this.isCheckedIn) {
      this.isCheckedIn = true;
      this.stopShakeAnimation();
      animateTo({ duration: 300, curve: Curve.Friction }, () => {
        this.shakeAngle = 0;
        this.splashOpacityLeft = 0;
        this.splashOpacityRight = 0;
      })
      promptAction.showToast({ message: '今日打卡成功！' });
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
          // 左侧飞溅水滴
          Text('💦')
            .fontSize(24)
            .opacity(this.splashOpacityLeft)
            .translate({ x: this.splashOffsetLeft, y: -20 })
          
          // 右侧飞溅水滴
          Text('💦')
            .fontSize(24)
            .opacity(this.splashOpacityRight)
            .translate({ x: this.splashOffsetRight, y: -20 })

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
          promptAction.showToast({ message: '功能未开发，请稍等。' });
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
