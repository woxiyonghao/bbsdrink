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
    this.shakeInterval = setInterval(() => {
      // 左右轻微抖动动画，吸引用户点击
      animateTo({ duration: 100, curve: Curve.Linear, iterations: 3, playMode: PlayMode.Alternate }, () => {
        this.shakeAngle = 15;
      })
      setTimeout(() => {
        animateTo({ duration: 100, curve: Curve.Linear }, () => {
          this.shakeAngle = 0;
        })
      }, 300);
    }, 2000); // 每2秒抖动一次
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
      .padding({ left: 25, top: 40, bottom: 20 })

      // 中心打卡大按钮
      Column() {
        Image(this.isCheckedIn ? $r('app.media.ic_ding_checked') : $r('app.media.ic_ding_uncheck'))
          .width(130)
          .height(130)
          .objectFit(ImageFit.Contain)
          .rotate({ angle: this.shakeAngle })
          .onClick(() => {
            this.handleCheckIn();
          })
          .animation({ duration: 300, curve: Curve.Friction })
        
        Text(this.isCheckedIn ? '今日已打卡' : '点击打卡')
          .fontSize(16)
          .fontColor(this.isCheckedIn ? '#07C160' : '#888888')
          .margin({ top: 20 })
          .fontWeight(FontWeight.Medium)
      }
      .margin({ top: 50, bottom: 80 })

      // 底部精美双拼小卡片
      Row({ space: 15 }) {
        // 喝水卡片
        Row() {
          Text('喝水')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)
            .margin({ left: 20 })
          
          Image($r('app.media.ic_water_glass_white'))
            .width(45)
            .height(45)
            .margin({ right: 15 })
            .opacity(0.9)
        }
        .layoutWeight(1)
        .height(110)
        .borderRadius(20)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]] // 浅蓝色高质感渐变
        })
        .shadow({ radius: 10, color: '#4D219EBC', offsetY: 5 })
        .onClick(() => {
          promptAction.showToast({ message: '功能未开发，请稍等。' });
        })

        // 久坐运动卡片
        Row() {
          Text('起来走走')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)
            .margin({ left: 20 })
          
          Image($r('app.media.ic_sport_white'))
            .width(45)
            .height(45)
            .margin({ right: 15 })
            .opacity(0.9)
        }
        .layoutWeight(1)
        .height(110)
        .borderRadius(20)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#A8E063', 0.0], ['#56AB2F', 1.0]] // 浅绿色高质感渐变
        })
        .shadow({ radius: 10, color: '#4D56AB2F', offsetY: 5 })
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
    .backgroundColor('#F5F7FA') // 浅灰背景，凸显卡片层级
  }
}
