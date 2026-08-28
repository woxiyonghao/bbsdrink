import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Define Bubble interface
interface_bubble = """interface Bubble {
  id: number;
  x: number;
  y: number;
  size: number;
  opacity: number;
}

@Entry"""
content = content.replace("@Entry", interface_bubble)

# 2. Add bubbles state
state_bubbles = """  @State bubbles: Bubble[] = [];
  @State todayCategoryAmount: number = 0;"""
content = content.replace("  @State todayCategoryAmount: number = 0;", state_bubbles)

# 3. Add spawnBubbles method
spawn_method = """  spawnBubbles() {
    const newBubbles: Bubble[] = [];
    const now = Date.now();
    for (let i = 0; i < 20; i++) {
      newBubbles.push({
        id: now + i,
        x: Math.random() * 90 + 5, // 5% 到 95%
        y: 100, // 从底部开始
        size: Math.random() * 15 + 10,
        opacity: Math.random() * 0.4 + 0.3
      });
    }
    this.bubbles = [...this.bubbles, ...newBubbles];
    
    setTimeout(() => {
      animateTo({ duration: 2500, curve: Curve.EaseOut }, () => {
        this.bubbles = this.bubbles.map(b => {
          if (b.id >= now) {
            return { ...b, y: -20 }; // 飘出屏幕顶部
          }
          return b;
        });
      });
      
      setTimeout(() => {
        this.bubbles = this.bubbles.filter(b => b.id > now + 30);
      }, 3000);
    }, 50);
  }

  async playDrinkAnimation() {"""
content = content.replace("  async playDrinkAnimation() {", spawn_method)

# 4. Call spawnBubbles in handleDrink
handle_old = "this.playDrinkAnimation();"
handle_new = "this.playDrinkAnimation();\n      this.spawnBubbles();"
content = content.replace(handle_old, handle_new)

# 5. Remove waves and add bubbles in build
# Replace the top background and wave part:
wave_regex = re.compile(r"      // 1\. 全局背景：浅蓝色 \(未喝水\).*?\.align\(Alignment\.BottomStart\) // 波浪贴紧底部开始", re.DOTALL)
new_bg_and_bubbles = """      // 全局纯色背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#29C5F6')

      // 汽水气泡层
      ForEach(this.bubbles, (b: Bubble) => {
        Circle({ width: b.size, height: b.size })
          .fill('rgba(255, 255, 255, 0.6)') // 白色气泡
          .position({ x: `${b.x}%`, y: `${b.y}%` })
          .opacity(b.opacity)
      }, (b: Bubble) => b.id.toString())"""
content = wave_regex.sub(new_bg_and_bubbles, content)

# 6. Update selected icon style
old_icon_style = """                  Image(item.icon)
                    .width(28) 
                    .height(28)
                    .fillColor(this.selectedIndex === index ? 'rgba(7, 193, 96, 0.6)' : '#FFFFFF') // 选中更淡的绿，未选中白
                    .animation({ duration: 200 })

                  Text(item.name)
                    .fontSize(this.selectedIndex === index ? 14 : 11)
                    .fontColor(this.selectedIndex === index ? 'rgba(7, 193, 96, 0.6)' : '#FFFFFF')"""

new_icon_style = """                  Image(item.icon)
                    .width(this.selectedIndex === index ? 44 : 28) 
                    .height(this.selectedIndex === index ? 44 : 28)
                    .fillColor(this.selectedIndex === index ? '#80FFBB' : 'rgba(255, 255, 255, 0.6)') // 选中大+淡绿色，未选中半透明白
                    .animation({ duration: 200 })

                  Text(item.name)
                    .fontSize(this.selectedIndex === index ? 16 : 12)
                    .fontColor(this.selectedIndex === index ? '#80FFBB' : 'rgba(255, 255, 255, 0.6)')"""
content = content.replace(old_icon_style, new_icon_style)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
