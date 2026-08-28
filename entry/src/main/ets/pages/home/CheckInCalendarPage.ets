import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';

@Entry
@Component
export struct CheckInCalendarPage {
  @State checkInDays: Set<number> = new Set(); // 存储当月已签到的日期
  @State currentYear: number = new Date().getFullYear();
  @State currentMonth: number = new Date().getMonth(); // 0-11
  @State daysInMonth: number[] = [];
  @State firstDayOfWeek: number = 0; // 0 是周日

  async aboutToAppear() {
    this.generateCalendar();
    await this.loadCheckInData();
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
      .margin({ top: 24 })
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.04)', offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
