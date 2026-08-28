import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

target = "    .height('100%') // 关键：让这个Column撑满屏幕，Blank才能生效\\n  } // 结束 Stack (全局根组件)"
# Use regex to find the end of the Column block and insert before the Stack closes
pattern = r"    \.height\('100%'\) // 关键：让这个Column撑满屏幕，Blank才能生效\n  \} // 结束 Stack \(全局根组件\)"

floating_layer = """    .height('100%') // 关键：让这个Column撑满屏幕，Blank才能生效

    // 悬浮飞出动画层
    if (this.flyOpacity > 0) {
      Image(this.DRINKS[this.selectedIndex].icon)
        .width(36)
        .height(36)
        .fillColor('#FFFFFF')
        .margin({ bottom: 48 }) // 与底部Button的中心对齐 (30 + 72/2 - 36/2 = 48)
        .translate({ y: this.flyY })
        .scale({ x: this.flyScale, y: this.flyScale })
        .rotate({ angle: this.flyRotate })
        .opacity(this.flyOpacity)
    }
  } // 结束 Stack (全局根组件)"""

content = re.sub(pattern, floating_layer, content)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
