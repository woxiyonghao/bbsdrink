import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Add states
states = """  @State waveOffsetX: number = 0;
  
  // 动画状态
  @State flyY: number = 0;
  @State flyScale: number = 1;
  @State flyRotate: number = 0;
  @State flyOpacity: number = 0;"""
content = re.sub(r'@State waveOffsetX: number = 0;', states, content)

# 2. Add playDrinkAnimation method
anim_method = """
  async playDrinkAnimation() {
    this.flyOpacity = 1;
    this.flyY = 0;
    this.flyScale = 1;
    this.flyRotate = 0;

    // 1. 0-0.6秒 慢慢变大，往屏幕中间靠近，最大跟屏幕宽度一致 (放大10倍)
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.flyY = -350; // 屏幕中间
      this.flyScale = 10;
    });

    await new Promise<void>(resolve => setTimeout(resolve, 600));

    // 2. 0.6-1秒 抖动 (类似Ding模块0.4秒)
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = 15; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = -15; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = 15; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = 0; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));

    // 3. 1-1.6秒 原路返回
    animateTo({ duration: 600, curve: Curve.EaseIn }, () => {
      this.flyY = 0;
      this.flyScale = 1;
      this.flyOpacity = 0;
    });

    await new Promise<void>(resolve => setTimeout(resolve, 600));
    this.flyOpacity = 0;
  }

  async handleDrink() {"""
content = content.replace("  async handleDrink() {", anim_method)

# 3. Remove router.back() and add animation call
content = content.replace("router.back();", "this.playDrinkAnimation();")

# 4. Update Button icon
old_btn = """          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_action_drink2')) // 极简抽象喝水侧颜
              .width(36)
              .height(36)
          }"""
new_btn = """          Button({ type: ButtonType.Circle }) {
            Image(this.DRINKS[this.selectedIndex].icon) // 喝的icon换成是当前选择的
              .width(36)
              .height(36)
              .fillColor('#FFFFFF')
          }"""
content = content.replace(old_btn, new_btn)

# 5. Add floating Image layer
floating_layer = """      .width('100%')
      .height('100%') // 关键：让这个Column撑满屏幕，Blank才能生效

      // 悬浮飞出动画层
      Image(this.DRINKS[this.selectedIndex].icon)
        .width(36)
        .height(36)
        .fillColor('rgba(7, 193, 96, 0.8)') // 可以用绿色，或者白色
        .margin({ bottom: 48 }) // 与底部Button的中心对齐 (30 + 72/2 - 36/2 = 48)
        .translate({ y: this.flyY })
        .scale({ x: this.flyScale, y: this.flyScale })
        .rotate({ angle: this.flyRotate })
        .opacity(this.flyOpacity)

  } // 结束 Stack (全局根组件)"""
content = content.replace("      .height('100%') // 关键：让这个Column撑满屏幕，Blank才能生效\n  } // 结束 Stack (全局根组件)", floating_layer)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
