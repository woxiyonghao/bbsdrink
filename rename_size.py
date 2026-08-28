import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Rename @Prop size to @Prop bubbleSize in BubbleView
old_prop = "@Prop size: number;"
new_prop = "@Prop bubbleSize: number;"
content = content.replace(old_prop, new_prop)

# 2. Update usage in BubbleView
old_usage = "Circle({ width: this.size, height: this.size })"
new_usage = "Circle({ width: this.bubbleSize, height: this.bubbleSize })"
content = content.replace(old_usage, new_usage)

old_stroke = "this.size > 30 ? 1.5 : 1"
new_stroke = "this.bubbleSize > 30 ? 1.5 : 1"
content = content.replace(old_stroke, new_stroke)

# 3. Update ForEach instantiation
old_inst = "BubbleView({ x: b.x, y: b.y, size: b.size, bubbleOpacity: b.opacity })"
new_inst = "BubbleView({ x: b.x, y: b.y, bubbleSize: b.size, bubbleOpacity: b.opacity })"
content = content.replace(old_inst, new_inst)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
