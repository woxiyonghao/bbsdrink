import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { CheckInRecord, DrinkOption, GLOBAL_DRINKS } from '../../types';


@Entry
@Component
export struct DrinkHistoryPage {
  private scroller: Scroller = new Scroller();
  @State scrollY: number = 0;
  @State listHeight: number = 0;

  @State records: CheckInRecord[] = [];

  readonly DRINKS: DrinkOption[] = GLOBAL_DRINKS;

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.records = await RdbHelper.queryDrinkRecords(userId);
    }
  }

  getDrinkInfo(type: number): DrinkOption {
    const found = this.DRINKS.find(d => d.type === type);
    return found || this.DRINKS[0]; // fallback
  }

  formatDate(timestamp: number): string {
    const d = new Date(timestamp);
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    const h = d.getHours().toString().padStart(2, '0');
    const min = d.getMinutes().toString().padStart(2, '0');
    return `${m}-${day} ${h}:${min}`;
  }

  getTranslateY(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 120; // 100 height + 20 space
    let cardBottom = cardTop + 100;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0) return deltaTop * 0.9;
    if (deltaBottom > 0 && listHeight > 0) return -deltaBottom * 0.9;
    return 0;
  }

  getScale(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 120;
    let cardBottom = cardTop + 100;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0) return Math.max(0.8, 1 - deltaTop * 0.0005);
    if (deltaBottom > 0 && listHeight > 0) return Math.max(0.8, 1 - deltaBottom * 0.0005);
    return 1;
  }

  getOpacity(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 120;
    let cardBottom = cardTop + 100;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0) return Math.max(0, 1 - deltaTop * 0.002);
    if (deltaBottom > 0 && listHeight > 0) return Math.max(0, 1 - deltaBottom * 0.002);
    return 1;
  }

  getShadowRadius(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 120;
    let cardBottom = cardTop + 100;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0 || (deltaBottom > 0 && listHeight > 0)) return 20;
    return 12;
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

      List({ space: 20, scroller: this.scroller }) {
        ForEach(this.records, (item: CheckInRecord, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(`${this.getDrinkInfo(item.type).name} ${item.value}ml`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                
                Text(this.formatDate(item.timestamp))
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Start)
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
              colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]]
            })
            .shadow({ 
               radius: this.getShadowRadius(index, this.scrollY, this.listHeight), 
               color: this.getShadowRadius(index, this.scrollY, this.listHeight) > 12 ? 'rgba(0,0,0,0.3)' : '#4D219EBC', 
               offsetY: this.getShadowRadius(index, this.scrollY, this.listHeight) > 12 ? 10 : 6 
            })
          }
          .zIndex(index)
          .translate({ y: this.getTranslateY(index, this.scrollY, this.listHeight) })
          .scale({
             x: this.getScale(index, this.scrollY, this.listHeight),
             y: this.getScale(index, this.scrollY, this.listHeight)
          })
          .opacity(this.getOpacity(index, this.scrollY, this.listHeight))
        }, (item: CheckInRecord) => item.id?.toString() || item.timestamp.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 20, right: 20, bottom: 20, top: 10 })
      .scrollBar(BarState.Off)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.listHeight = newValue.height as number;
      })
      .onScroll(() => {
        this.scrollY = this.scroller.currentOffset().yOffset;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // 页面转场动画定义
  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 400, curve: Curve.Linear })
      .opacity(0)
      .scale({ x: 1.0, y: 1.0 })
    
    PageTransitionExit({ type: RouteType.Pop, duration: 400, curve: Curve.Linear })
      .opacity(0)
      .scale({ x: 0.8, y: 0.8 })
  }
}
