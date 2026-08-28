with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    lines = f.readlines()

# Find the line with "// 底部圆形矢量图按钮 (喝)"
idx = 0
for i, line in enumerate(lines):
    if "底部圆形矢量图按钮 (喝)" in line:
        idx = i
        break

tail_content = """          // 底部圆形矢量图按钮 (喝)
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_action_drink2')) // 极简抽象喝水侧颜
              .width(36)
              .height(36)
          }
          .width(72)
          .height(72)
          .backgroundColor('rgba(7, 193, 96, 0.5)') // 背景色再绿一点
          .margin({ top: 10, bottom: 30 })
          .shadow({ radius: 10, color: 'rgba(7, 193, 96, 0.1)', offsetY: 4 })
          .onClick(() => {
            this.handleDrink();
          })
        } // 结束 Column (dial items)
      } // 结束 Stack (dial)
      .width('100%')
    } // 结束 Column (nav + dial)
    .width('100%')
    .height('100%') // 关键：让这个Column撑满屏幕，Blank才能生效
  } // 结束 Stack (全局根组件)
  .width('100%')
  .height('100%')
} // 结束 build()
} // 结束 struct
"""

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.writelines(lines[:idx])
    f.write(tail_content)
