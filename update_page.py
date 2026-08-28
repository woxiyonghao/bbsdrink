import re

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "r") as f:
    content = f.read()

# 1. Add todayCategoryAmount state
states_replace = """  @State todayCategoryAmount: number = 0;
  
  // 动画状态"""
content = content.replace("  // 动画状态", states_replace)

# 2. Update handleDrink
old_handle = """      await RdbHelper.insertRecord({
        userId: userId,
        type: 0,
        value: this.currentAmount,
        timestamp: new Date().getTime()
      });
      promptAction.showToast({ message: `吨吨吨！成功记录 ${this.currentAmount}ml ${drink.name}！` });
      this.playDrinkAnimation();"""

new_handle = """      await RdbHelper.insertRecord({
        userId: userId,
        type: drink.type,
        value: this.currentAmount,
        timestamp: new Date().getTime()
      });
      this.todayCategoryAmount += this.currentAmount; // Update local state for wave animation
      promptAction.showToast({ message: `吨吨吨！成功记录 ${this.currentAmount}ml ${drink.name}！` });
      this.playDrinkAnimation();"""
content = content.replace(old_handle, new_handle)

# 3. Add loadCategoryData
load_method = """  async loadCategoryData() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      const type = this.DRINKS[this.selectedIndex].type;
      const total = await RdbHelper.queryTodayTotalByType(userId, type);
      animateTo({ duration: 600, curve: Curve.EaseInOut }, () => {
        this.todayCategoryAmount = total;
      });
    }
  }

  startWaveAnimation() {"""
content = content.replace("  startWaveAnimation() {", load_method)

# 4. Call loadCategoryData on appear and onScrollStop
content = content.replace("this.startWaveAnimation();", "this.startWaveAnimation();\n    this.loadCategoryData();")
content = content.replace("this.scroller.scrollTo({ xOffset: this.selectedIndex * 80, yOffset: 0, animation: { duration: 200, curve: Curve.EaseOut } });", "this.scroller.scrollTo({ xOffset: this.selectedIndex * 80, yOffset: 0, animation: { duration: 200, curve: Curve.EaseOut } });\n            this.loadCategoryData();")

# 5. Build method structure: Top Light Blue, Big Label, Wave, Dial
# We replace the top structure.
old_build_top = """  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 全局纯色背景：Tabs的淡绿 + blur，防止白色的icon跟白色的底层看不清
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(7, 193, 96, 0.15)')
        .backgroundBlurStyle(BlurStyle.Thin)

      Column() {"""

new_build_top = """  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 全局背景：浅蓝色 (未喝水)
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#29C5F6')

      // 2. 波浪 (已喝水)，深蓝色
      Stack({ alignContent: Alignment.Top }) {
        Path()
          .commands('M0,30 Q50,0 100,30 T200,30 T300,30 T400,30 T500,30 T600,30 T700,30 T800,30 T900,30 T1000,30 T1100,30 T1200,30 T1300,30 T1400,30 L1400,2000 L0,2000 Z')
          .fill('#00A3FF')
          .offset({ x: this.waveOffsetX, y: 0 })
      }
      .width('400%')
      .height(`${Math.min(100, (this.todayCategoryAmount / 2000) * 100)}%`) // 随喝水量上涨
      .animation({ duration: 800, curve: Curve.EaseInOut })
      .align(Alignment.BottomStart) // 波浪贴紧底部开始

      Column() {"""
content = content.replace(old_build_top, new_build_top)

# 6. Insert Big Label
old_nav = """        // 顶部导航
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor('#FFFFFF') // Update back icon color since background is blue
            .onClick(() => router.back())
          Text('Drink')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })"""

# In current code it is `#333333`, let's just replace the whole row
old_nav_regex = re.compile(r"        // 顶部导航.*?padding\(\{ left: 20, right: 20 \}\)", re.DOTALL)

new_nav = """        // 顶部导航
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor('#FFFFFF')
            .onClick(() => router.back())
          Text('Drink')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })

        // 大大的Label
        Row({ space: 4 }) {
          Text(this.todayCategoryAmount.toLocaleString())
            .fontSize(72)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
          Text('ml')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .margin({ bottom: 12 })
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: 40 })"""

content = old_nav_regex.sub(new_nav, content)

with open("entry/src/main/ets/pages/ding/DrinkRecordPage.ets", "w") as f:
    f.write(content)
