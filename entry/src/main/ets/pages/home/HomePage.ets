import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { User } from '../../types';

@Component
struct WaterStar {
  @Prop progress: number; // 0.0 to 1.0

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 灰色背景星星
      Polygon()
        .width(200)
        .height(200)
        .points([[100,0], [122,69], [195,69], [136,112], [159,181], [100,138], [41,181], [64,112], [5,69], [78,69]])
        .fill('#F5F7FA')

      // 2. 绿色上涨水面星星
      Column() {
        Polygon()
          .width(200)
          .height(200)
          .points([[100,0], [122,69], [195,69], [136,112], [159,181], [100,138], [41,181], [64,112], [5,69], [78,69]])
          .fill('#07C160')
          .position({ left: 0, bottom: 0 }) // 锁定底部，防止由于外层 Column 高度变化而导致顶部对齐
      }
      .width(200)
      .height(`${Math.min(100, this.progress * 100)}%`)
      .clip(true)
      .animation({ duration: 1000, curve: Curve.FastOutSlowIn }) // 平滑的水面上升动画
    }
    .width(200)
    .height(200)
  }
}

@Entry
@Component
export struct HomePage {
  @State todayDrank: number = 0;
  @State dailyGoal: number = 2000; // 默认2000ml

  async onPageShow() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      // 每次页面展示时，重新查询当天的喝水量，确保打卡返回后能实时刷新
      this.todayDrank = await RdbHelper.queryTodayWaterTotal(userId);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 头部标题
        Text('今日饮水')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 60, bottom: 60 })

        // 核心视觉：水位上涨的星星
        WaterStar({ progress: this.todayDrank / this.dailyGoal })
          .margin({ bottom: 50 })

        // 数据大字报
        Row() {
          Text(this.todayDrank.toString())
            .fontSize(56)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#07C160')
          Text(' / ' + this.dailyGoal + ' ml')
            .fontSize(20)
            .fontColor('#888888')
            .margin({ bottom: 10, left: 5 })
        }.alignItems(VerticalAlign.Bottom)

        // 鼓励语
        Text(this.todayDrank >= this.dailyGoal ? '太棒了！已达成今日目标 ✨' : '继续加油，补充水分哟 ~')
          .fontSize(16)
          .fontColor('#888888')
          .margin({ top: 15 })

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

      // 底部悬浮打卡按钮 (FAB)
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_water_white'))
          .width(32).height(32).objectFit(ImageFit.Contain)
      }
      .width(64)
      .height(64)
      .backgroundColor('#07C160')
      .shadow({ radius: 15, color: '#4D07C160', offsetY: 8 })
      .margin({ bottom: 50 })
      .onClick(() => {
        // 跳转到打卡页面
        router.pushUrl({ url: 'pages/ding/DingPage' })
      })
    }
    .width('100%')
    .height('100%')
  }
}
