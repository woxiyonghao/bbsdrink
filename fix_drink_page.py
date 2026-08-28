import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Remove white stroke from Ellipse
content = content.replace("          .strokeWidth(0.5)\n          .stroke('rgba(255, 255, 255, 0.8)') // 边缘高光\n", "")
# Just in case it's slightly different
content = re.sub(r"\s*\.strokeWidth\(.*?\)", "", content)
content = re.sub(r"\s*\.stroke\('.*?'\).*?\n", "\n", content)

# 2. Add hitTestBehavior to floating Image
old_float = """      .rotate({ angle: this.flyRotate })
      .opacity(this.flyOpacity)"""
new_float = """      .rotate({ angle: this.flyRotate })
      .opacity(this.flyOpacity)
      .hitTestBehavior(HitTestMode.None) // 防止隐形图标拦截底部按钮的点击事件！"""
content = content.replace(old_float, new_float)

# 3. Update wave height calculation
old_wave_height = r"\.height\(`\$\{Math\.min\(100, \(this\.todayCategoryAmount / 2000\) \* 100\)\}%`\)"
new_wave_height = r".height(`${35 + Math.min(65, (this.todayCategoryAmount / 2000) * 65)}%`)"
content = re.sub(old_wave_height, new_wave_height, content)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
