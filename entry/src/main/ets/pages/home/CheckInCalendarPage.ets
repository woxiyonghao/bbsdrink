import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';

const CALENDAR_QUOTES = [
  "每一个不曾起舞的日子，都是对生命的辜负。", "健康不是一切，但没有健康就没有一切。", "流水不腐，户枢不蠹，动也。", "投资健康，是回报率最高的一笔交易。", "你的身体是一座神庙，请好好供奉它。",
  "生活的美好，建立在充沛的精力之上。", "坚持打卡不是为了炫耀，而是为了遇见更好的自己。", "改变从今天开始，从此刻的一杯水开始。", "日积月累，滴水穿石。", "把健康当成一种习惯，而不是一种任务。",
  "最好的医生是自己，最好的药物是时间。", "早睡早起，精神百倍。", "生命在于运动，活力在于坚持。", "给时间一点时间，让习惯成为自然。", "今天流下的汗水，是明天闪耀的光芒。",
  "你的每一次坚持，都在重塑你的基因。", "与其仰望星空，不如先走好脚下的健康之路。", "自律给我自由。", "照顾好身体，灵魂才愿意在其中栖息。", "别让未来的你，讨厌现在透支健康的自己。",
  "健康的生活方式，是对自己最深沉的爱。", "放慢脚步，感受每一次呼吸和心跳。", "饮食有节，起居有常，不妄作劳。", "保持微笑，保持水分，保持健康。", "与其把钱交给医院，不如把时间交给运动。",
  "好习惯就像存款，时间越久复利越高。", "别把忙碌当成不顾身体的借口。", "每一滴汗水，都是对抗衰老的子弹。", "健康是每天一点一滴的积累。", "身体的舒适，带来灵魂的宁静。",
  "在追求梦想的路上，别忘了带上健康。", "规律的作息，是治愈一切焦虑的良药。", "喝水、运动、早睡，健康的底层逻辑其实很简单。", "不要等口渴了才喝水，不要等病了才后悔。", "每天进步一点点，健康生活在眼前。",
  "身体是你唯一可以居住的地方，请保持它的整洁。", "养生不是老年人的专利，而是年轻人的觉醒。", "好好吃饭，好好睡觉，这是人生的大智慧。", "管理好自己的身体，就是管理好自己的人生。", "汗水是脂肪在哭泣。",
  "每一次运动，都是对平庸生活的越狱。", "睡个好觉，比什么都重要。", "健康，是人生的第一财富。", "把运动融入生活，就像呼吸一样自然。", "少坐多动，延年益寿。",
  "吃得清淡，活得灿烂。", "身体和灵魂，总有一个要在健康的路上。", "不要用健康去换取身外之物。", "你今天的选择，决定了你十年后的模样。", "打卡不仅是记录，更是一种自我承诺。",
  "健康是一种责任，不仅是对自己，也是对家人。", "保持活力，方能应对生活的风风雨雨。", "运动不仅能改变体型，更能改变心态。", "充足的水分，是生命之树长青的源泉。", "每一天都是重塑健康的最佳时机。",
  "累了就休息，渴了就喝水，倾听身体的声音。", "健康不是百米冲刺，而是一场马拉松。", "善待身体，就是善待生命。", "愿你拥有健康的体魄，去感受世间所有的美好。", "今日的自律，铸就明日的自由。"
];

@Entry
@Component
export struct CheckInCalendarPage {
  @State checkInDays: Set<number> = new Set(); // 存储当月已签到的日期
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth(); // 0-11
  @State daysInMonth: number[] = [];
  @State firstDayOfWeek: number = 0; // 0 是周日
  @State dailyQuote: string = '';

  async aboutToAppear() {
    this.generateCalendar();
    this.generateDailyQuote();
    await this.loadCheckInData();
  }

  generateDailyQuote() {
    const today = new Date();
    // 使用 年+月+日 组合作为一个简单的哈希种子，确保每天的句子不一样，但同一天内固定
    const seed = today.getFullYear() * 10000 + (today.getMonth() + 1) * 100 + today.getDate();
    const index = seed % CALENDAR_QUOTES.length;
    this.dailyQuote = CALENDAR_QUOTES[index];
  }

  generateCalendar() {
    const firstDay = new Date(this.currentYear, this.currentMonth, 1);
    this.firstDayOfWeek = firstDay.getDay();
    const lastDay = new Date(this.currentYear, this.currentMonth + 1, 0);
    const totalDays = lastDay.getDate();
    
    let days: number[] = [];
    for (let i = 1; i <= totalDays; i++) {
      days.push(i);
    }
    this.daysInMonth = days;
  }

  async loadCheckInData() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      const timestamps = await RdbHelper.queryAllCheckInTimestamps(userId);
      let daysSet = new Set<number>();
      for (const ts of timestamps) {
        const d = new Date(ts);
        if (d.getFullYear() === this.currentYear && d.getMonth() === this.currentMonth) {
          daysSet.add(d.getDate());
        }
      }
      this.checkInDays = daysSet;
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24)
          .onClick(() => router.back())
        Text('签到记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 日历卡片
      Column() {
        // 月份 Header
        Row() {
          Text(`${this.currentYear}年 ${this.currentMonth + 1}月`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 24, bottom: 20 })
        .justifyContent(FlexAlign.Center)

        // 星期栏
        Row() {
          ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
            Text(day)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          })
        }.width('100%').margin({ bottom: 20 })

        // 日期网格
        Grid() {
          // 填充第一周的空白天数
          ForEach(new Array(this.firstDayOfWeek).fill(0), () => {
            GridItem() {
              Text('').width(36).height(36)
            }
          })
          
          // 实际天数
          ForEach(this.daysInMonth, (day: number) => {
            GridItem() {
              Text(`${day}`)
                .width(36)
                .height(36)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.checkInDays.has(day) ? '#FFFFFF' : '#333333')
                .backgroundColor(this.checkInDays.has(day) ? '#07C160' : 'transparent')
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .lineHeight(36)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(16)
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 32 })
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .margin({ top: 24, bottom: 30 })
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.04)', offsetY: 8 })

      // 每日金句
      Column() {
        Image($r('app.media.ic_about')) // 可以用类似引号或者信息的图标，这里先借用一个
          .width(24)
          .height(24)
          .fillColor('#D3D3D3')
          .margin({ bottom: 12 })
          
        Text(this.dailyQuote)
          .fontSize(16)
          .fontColor('#666666')
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .lineHeight(26)
          .padding({ left: 30, right: 30 })
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
