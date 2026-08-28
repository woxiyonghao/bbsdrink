import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { CheckInRecord } from '../../types';

class DrinkOption {
  type: number;
  name: string;
  icon: Resource;
  
  constructor(type: number, name: string, icon: Resource) {
    this.type = type;
    this.name = name;
    this.icon = icon;
  }
}

interface GroupedRecord {
  date: string;
  records: CheckInRecord[];
}

@Entry
@Component
export struct DrinkHistoryPage {
  @State records: CheckInRecord[] = [];

  readonly DRINKS: DrinkOption[] = [
    new DrinkOption(0, '水', $r('app.media.ic_drink_water')),
    new DrinkOption(1, '咖啡', $r('app.media.ic_drink_coffee')),
    new DrinkOption(2, '绿茶', $r('app.media.ic_drink_tea')),
    new DrinkOption(3, '牛奶', $r('app.media.ic_drink_milk')),
    new DrinkOption(4, '果汁', $r('app.media.ic_drink_juice')),
    new DrinkOption(5, '柠檬茶', $r('app.media.ic_drink_lemon')),
    new DrinkOption(6, '运动饮料', $r('app.media.ic_drink_sports')),
    new DrinkOption(7, '气泡水', $r('app.media.ic_drink_sparkling')),
    new DrinkOption(8, '椰子水', $r('app.media.ic_drink_coconut')),
    new DrinkOption(9, '花茶', $r('app.media.ic_drink_herbal')),
    new DrinkOption(10, '热可可', $r('app.media.ic_drink_cocoa')),
    new DrinkOption(11, '补剂', $r('app.media.ic_drink_bottle'))
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.records = await RdbHelper.queryDrinkRecords(userId);
    }
  }

  getGroupedRecords(): GroupedRecord[] {
    const map = new Map<string, CheckInRecord[]>();
    for (const r of this.records) {
      const d = new Date(r.timestamp);
      const dateStr = `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`;
      if (!map.has(dateStr)) {
        map.set(dateStr, []);
      }
      map.get(dateStr)!.push(r);
    }
    const result: GroupedRecord[] = [];
    map.forEach((records, date) => {
      result.push({ date, records });
    });
    return result;
  }

  getDrinkInfo(type: number): DrinkOption {
    const found = this.DRINKS.find(d => d.type === type);
    return found || this.DRINKS[0]; // fallback
  }

  @Builder itemHead(text: string) {
    Row() {
      Text(text)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ left: 20, top: 20, bottom: 10 })
    .backgroundColor('#F5F7FA')
  }

  @Builder RecordCard(item: CheckInRecord) {
    Row() {
      Text(`${this.getDrinkInfo(item.type).name} ${item.value}ml`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .margin({ left: 25 })
      
      Image(this.getDrinkInfo(item.type).icon)
        .width(50)
        .height(50)
        .margin({ right: 25 })
        .opacity(0.9)
        .fillColor(Color.White)
    }
    .width('100%')
    .height(100)
    .borderRadius(20)
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]] // 浅蓝色渐变 (同喝水卡片)
    })
    .shadow({ radius: 12, color: '#4D219EBC', offsetY: 6 })
    .margin({ top: 10, bottom: 10 })
  }

  build() {
    Column() {
      // Top nav
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
        Text('喝水记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })

      List() {
        ForEach(this.getGroupedRecords(), (group: GroupedRecord) => {
          ListItemGroup({ header: this.itemHead(group.date) }) {
            ForEach(group.records, (item: CheckInRecord) => {
              ListItem() {
                this.RecordCard(item)
              }
              .padding({ left: 20, right: 20 })
            }, (item: CheckInRecord) => item.id?.toString() || item.timestamp.toString())
          }
        }, (group: GroupedRecord) => group.date)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
