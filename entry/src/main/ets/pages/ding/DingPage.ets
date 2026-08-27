import promptAction from '@ohos.promptAction';

@Entry
@Component
export struct DingPage {
  @State isCheckedIn: boolean = false;
  @State shakeAngle: number = 0;
  private shakeInterval: number = -1;

  aboutToAppear() {
    this.startShakeAnimation();
  }

  aboutToDisappear() {
    this.stopShakeAnimation();
  }

  startShakeAnimation() {
    if (this.isCheckedIn) return;
    // 使用精准的状态翻转来实现持续的高频抖动
    this.shakeInterval = setInterval(() => {
      if (this.isCheckedIn) return;
      
      // 更高频率的左右晃动
      animateTo({ duration: 40, curve: Curve.Linear }, () => { this.shakeAngle = -15; })
      
      setTimeout(() => {
        animateTo({ duration: 80, curve: Curve.Linear }, () => { this.shakeAngle = 15; })
      }, 40);
      
      setTimeout(() => {
        animateTo({ duration: 80, curve: Curve.Linear }, () => { this.shakeAngle = -15; })
      }, 120);
      
      setTimeout(() => {
        animateTo({ duration: 40, curve: Curve.Linear }, () => { this.shakeAngle = 0; })
      }, 200);
      
    }, 800); // 抖动间隔缩短，频率变高
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
        Image($r('app.media.ic_cup_water'))
          .width(140)
          .height(140)
          .objectFit(ImageFit.Contain)
          .fillColor(this.isCheckedIn ? '#07C160' : '#D3D3D3') // 未打卡为浅灰，打卡为微信绿
          .rotate({ angle: this.shakeAngle })
          .onClick(() => {
            this.handleCheckIn();
          })
        
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
