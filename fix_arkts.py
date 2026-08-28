import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Fix spread error in bubbles array
content = content.replace("this.bubbles = [...this.bubbles, ...newBubbles];", "this.bubbles = this.bubbles.concat(newBubbles);")

# 2. Fix spread error in map
old_map = "return { ...b, y: -20 };"
new_map = "return { id: b.id, x: b.x, y: -20, size: b.size, opacity: b.opacity };"
content = content.replace(old_map, new_map)

# 3. Fix filter condition
old_filter = "this.bubbles = this.bubbles.filter(b => b.id > now + 30);"
new_filter = "this.bubbles = this.bubbles.filter(b => b.id < now || b.id >= now + 20);"
content = content.replace(old_filter, new_filter)

# 4. Make bubbles bigger
content = content.replace("size: Math.random() * 15 + 10,", "size: Math.random() * 40 + 15,")

# 5. Enhance bubble UI to look like soap bubbles
old_circle = """      ForEach(this.bubbles, (b: Bubble) => {
        Circle({ width: b.size, height: b.size })
          .fill('rgba(255, 255, 255, 0.6)') // 白色气泡
          .position({ x: `${b.x}%`, y: `${b.y}%` })
          .opacity(b.opacity)
      }, (b: Bubble) => b.id.toString())"""

new_circle = """      // 汽水气泡层 (升级为肥皂泡质感)
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
content = content.replace(old_circle, new_circle)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
