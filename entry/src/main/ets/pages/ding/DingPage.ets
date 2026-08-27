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
    // 使用精准的状态翻转来实现持续抖动
    this.shakeInterval = setInterval(() => {
      if (this.isCheckedIn) return;
      
      // 快速向左
      animateTo({ duration: 50, curve: Curve.Linear }, () => { this.shakeAngle = -10; })
      
      // 向右
      setTimeout(() => {
        animateTo({ duration: 100, curve: Curve.Linear }, () => { this.shakeAngle = 10; })
      }, 50);
      
      // 再向左
      setTimeout(() => {
        animateTo({ duration: 100, curve: Curve.Linear }, () => { this.shakeAngle = -10; })
      }, 150);
      
      // 回正
      setTimeout(() => {
        animateTo({ duration: 50, curve: Curve.Linear }, () => { this.shakeAngle = 0; })
      }, 250);
      
    }, 2000);
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
        Stack() {
          // 未打卡时，显示一个高级质感的空心圆圈 + 水滴
          if (!this.isCheckedIn) {
            Circle()
              .width(130)
              .height(130)
              .fill(Color.White)
              .stroke('#07C160')
              .strokeWidth(3)
              .shadow({ radius: 15, color: '#3307C160', offsetY: 8 })
            
            // 使用系统自带的水滴图标组合，避免依赖网络图片
            Text('💧')
              .fontSize(50)
          } else {
            // 打卡成功显示实心大绿勾
            Circle()
              .width(130)
              .height(130)
              .fill('#07C160')
              .shadow({ radius: 15, color: '#4D07C160', offsetY: 8 })
            
            Image($r('app.media.ic_ding_checked')) // 实心勾
              .width(80)
              .height(80)
              .fillColor(Color.White)
          }
        }
        .width(130)
        .height(130)
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
