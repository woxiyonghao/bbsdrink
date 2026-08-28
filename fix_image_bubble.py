import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Update BubbleView to use the image and BlendMode (to make the white background of the JPEG transparent, if possible? ArkUI has blendMode(BlendMode.Screen) which makes black transparent, but for white background, Multiply makes white transparent. So `.blendMode(BlendMode.Multiply)`!)
old_bubble_view = """  build() {
    Circle({ width: this.bubbleSize, height: this.bubbleSize })
      .fill('transparent')
      .stroke('rgba(255, 255, 255, 0.8)')
      .strokeWidth(this.bubbleSize > 30 ? 1.5 : 1)
      .radialGradient({
        center: ['30%', '30%'],
        radius: '70%',
        colors: [
          ['rgba(255, 255, 255, 0.9)', 0.0],
          ['rgba(100, 255, 255, 0.2)', 0.2],
          ['rgba(200, 150, 255, 0.3)', 0.7],
          ['rgba(255, 255, 255, 0.8)', 1.0]
        ]
      })
      .position({ x: `${this.x}%`, y: `${this.y}%` })
      .opacity(this.bubbleOpacity)
      .hitTestBehavior(HitTestMode.None)
  }"""

new_bubble_view = """  build() {
    Image($r('app.media.paopao'))
      .width(this.bubbleSize)
      .height(this.bubbleSize)
      .position({ x: `${this.x}%`, y: `${this.y}%` })
      .opacity(this.bubbleOpacity)
      .blendMode(BlendMode.Multiply) // 如果是白底图片，Multiply可以让白色变透明！
      .hitTestBehavior(HitTestMode.None)
  }"""
content = content.replace(old_bubble_view, new_bubble_view)

# 2. Wrap ForEach in a full-screen top-left aligned Stack so percentages work correctly
old_foreach = """      // 汽水气泡层 (升级为肥皂泡质感)
      ForEach(this.bubbles, (b: Bubble) => {
        BubbleView({ x: b.x, y: b.y, bubbleSize: b.size, bubbleOpacity: b.opacity })
      }, (b: Bubble) => b.id.toString())"""

new_foreach = """      // 汽水气泡层 (全屏容器，确保百分比坐标正确)
      Stack({ alignContent: Alignment.TopStart }) {
        ForEach(this.bubbles, (b: Bubble) => {
          BubbleView({ x: b.x, y: b.y, bubbleSize: b.size, bubbleOpacity: b.opacity })
        }, (b: Bubble) => b.id.toString())
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.None)"""
content = content.replace(old_foreach, new_foreach)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
