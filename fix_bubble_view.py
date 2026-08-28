import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Define BubbleView component
bubble_view = """@Component
struct BubbleView {
  @Prop x: number;
  @Prop y: number;
  @Prop size: number;
  @Prop bubbleOpacity: number;

  build() {
    Circle({ width: this.size, height: this.size })
      .fill('transparent')
      .stroke('rgba(255, 255, 255, 0.8)')
      .strokeWidth(this.size > 30 ? 1.5 : 1)
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
  }
}

@Entry"""

content = content.replace("@Entry", bubble_view)

# 2. Update ForEach to use BubbleView
old_foreach = """      // 汽水气泡层 (升级为肥皂泡质感)
      ForEach(this.bubbles, (b: Bubble) => {
        Circle({ width: b.size, height: b.size })
          .fill('transparent')
          .stroke('rgba(255, 255, 255, 0.8)')
          .strokeWidth(b.size > 30 ? 1.5 : 1)
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
          .position({ x: `${b.x}%`, y: `${b.y}%` })
          .opacity(b.opacity)
          .hitTestBehavior(HitTestMode.None)
      }, (b: Bubble) => b.id.toString())"""

new_foreach = """      // 汽水气泡层 (升级为肥皂泡质感)
      ForEach(this.bubbles, (b: Bubble) => {
        BubbleView({ x: b.x, y: b.y, size: b.size, bubbleOpacity: b.opacity })
      }, (b: Bubble) => b.id.toString())"""

content = content.replace(old_foreach, new_foreach)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
