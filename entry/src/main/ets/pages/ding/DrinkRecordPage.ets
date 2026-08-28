import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

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

@Entry
@Component
export struct DrinkRecordPage {
  @State selectedIndex: number = 0;
  @State currentAmount: number = 250;
  @State waveOffsetX: number = 0;
  @State isAdjusting: boolean = false; 
  @State currentYOffset: number = 0; 
  
  private scroller: Scroller = new Scroller();

  readonly DRINKS: DrinkOption[] = [
    new DrinkOption(0, '水', $r('app.media.ic_drink_water')),
    new DrinkOption(1, '咖啡', $r('app.media.ic_drink_coffee')),
    new DrinkOption(2, '绿茶', $r('app.media.ic_drink_tea')),
    new DrinkOption(3, '牛奶', $r('app.media.ic_drink_milk')),
    new DrinkOption(4, '果汁', $r('app.media.ic_drink_juice')),
    new DrinkOption(5, '可乐', $r('app.media.ic_drink_cola')),
    new DrinkOption(6, '啤酒', $r('app.media.ic_drink_beer')),
    new DrinkOption(7, '红酒', $r('app.media.ic_drink_wine')),
    new DrinkOption(8, '马黛茶', $r('app.media.ic_drink_mate')),
    new DrinkOption(9, '鸡尾酒', $r('app.media.ic_drink_cocktail')),
    new DrinkOption(10, '清酒', $r('app.media.ic_drink_sake')),
    new DrinkOption(11, '补剂', $r('app.media.ic_drink_bottle'))
  ];

  aboutToAppear() {
    this.startWaveAnimation();
  }

  startWaveAnimation() {
    animateTo({ duration: 3000, curve: Curve.Linear, iterations: -1 }, () => {
      this.waveOffsetX = -200;
    })
  }

  async handleDrink() {
    const userId = await PreferencesUtil.getCurrentUserId();
    const drink = this.DRINKS[this.selectedIndex];
    if (userId > 0) {
      await RdbHelper.insertRecord({
        userId: userId,
        type: 0,
        value: this.currentAmount,
        timestamp: new Date().getTime()
      });
      promptAction.showToast({ message: `吨吨吨！成功记录 ${this.currentAmount}ml ${drink.name}！` });
      router.back();
    } else {
      promptAction.showToast({ message: '请先登录' });
    }
  }

  build() {
    Stack() {
      // 整体白底色
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
            .onClick(() => router.back())
          Text('Drink')
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })

        // 刻度和杯子区域
        Row() {
          // 中央杯子容器
          Stack({ alignContent: Alignment.Bottom }) {
            // 背景
            Column().width('100%').height('100%').backgroundColor('#F5F7FA')

            // 动态波浪水位
            Stack({ alignContent: Alignment.Bottom }) {
              Path()
                .commands('M0,30 Q50,0 100,30 T200,30 T300,30 T400,30 L400,500 L0,500 Z')
                .fill('rgba(33, 158, 188, 0.5)')
                .offset({ x: this.waveOffsetX, y: 0 })
              
              Path()
                .commands('M0,30 Q50,60 100,30 T200,30 T300,30 T400,30 L400,500 L0,500 Z')
                .fill('rgba(142, 202, 230, 0.8)')
                .offset({ x: this.waveOffsetX * 1.5, y: 0 })
            }
            .width('300%')
            .height(`${Math.max(10, (this.currentAmount / 1000) * 100)}%`)
            .animation({ duration: 800, curve: Curve.FastOutSlowIn })

            // 顶部显示的容量文本
            Text(`${this.currentAmount} ml`)
              .fontColor('#333333')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: '100%' })

            // 中央显示的当前饮品图标
            Image(this.DRINKS[this.selectedIndex].icon)
              .width(60)
              .height(60)
              .fillColor('#333333')
              .opacity(0.8)
              .margin({ bottom: 100 })

          }
          .width(180)
          .height(320)
          .border({ width: 3, color: '#E0E0E0', radius: 10 })
          .clip(true)
          .margin({ left: 40 })
          
          Blank()
          
        }
        .width('100%')
        .margin({ top: 40 })

        // 底部容量滑块
        Slider({
          value: this.currentAmount,
          min: 50,
          max: 1000,
          step: 50,
          style: SliderStyle.OutSet
        })
        .blockColor('#07C160')
        .trackColor('#E0E0E0')
        .selectedColor('#07C160')
        .showSteps(true)
        .onChange((value: number) => {
          this.currentAmount = value;
        })
        .margin({ top: 60, left: 30, right: 30 })

        Blank()

        // 底部“喝”按钮
        Button('喝')
          .width(240)
          .height(70)
          .backgroundColor('#07C160')
          .fontColor('#FFFFFF')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 40 })
          .shadow({ radius: 15, color: 'rgba(7,193,96,0.3)', offsetY: 8 })
          .onClick(() => {
            this.handleDrink();
          })

      }
      .width('100%')
      .height('100%')

      // ==========================================
      // 右侧相机级变焦滚轮 (绝对定位，靠右居中)
      // ==========================================
      Stack({ alignContent: Alignment.End }) {
        // 调焦时的黑色半透明毛玻璃底板
        if (this.isAdjusting) {
          Ellipse()
            .width(240)
            .height(480) // 上下长度大幅度增加，包住所有图标
            .fill('rgba(0, 0, 0, 0.1)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .opacity(0.7)
            .margin({ right: -120 })
            .animation({ duration: 200 })
        }

        // 中心红线指示器
        Row()
          .width(16)
          .height(2)
          .backgroundColor('#FF6B6B')
          .margin({ right: 80 })
          .opacity(this.isAdjusting ? 1 : 0)
          .animation({ duration: 200 })

        // 垂直滚轮列表
        List({ scroller: this.scroller }) {
          // 顶部占位 110px
          ListItem().height(110)
          
          ForEach(this.DRINKS, (item: DrinkOption, index: number) => {
            ListItem() {
              Column() {
                Image(item.icon)
                  .width(this.selectedIndex === index ? 36 : 24)
                  .height(this.selectedIndex === index ? 36 : 24)
                  .fillColor(this.selectedIndex === index ? '#07C160' : '#888888')
                  .animation({ duration: 200 })

                // 调焦时或选中时显示文字
                if (this.isAdjusting || this.selectedIndex === index) {
                  Text(item.name)
                    .fontSize(this.selectedIndex === index ? 14 : 11)
                    .fontColor(this.selectedIndex === index ? '#07C160' : '#999999')
                    .margin({ top: 4 })
                    .transition({ type: TransitionType.All, opacity: 0 })
                }
              }
              .width(80)
              .height(80)
              .justifyContent(FlexAlign.Center)
              .translate({ x: 0.0015 * Math.pow(index * 80 - this.currentYOffset, 2) - 10 })
            }
            .onClick(() => {
              this.scroller.scrollTo({ xOffset: 0, yOffset: index * 80, animation: { duration: 300, curve: Curve.EaseInOut } });
              this.selectedIndex = index;
            })
          })
          
          // 底部占位 110px
          ListItem().height(110)
        }
        .width(120)
        .height(300)
        .scrollBar(BarState.Off)
        .onScrollStart(() => {
          animateTo({ duration: 200 }, () => {
            this.isAdjusting = true;
          })
        })
        .onScroll(() => {
          const yOffset = this.scroller.currentOffset().yOffset;
          this.currentYOffset = yOffset;
          const index = Math.round(yOffset / 80);
          if (index !== this.selectedIndex && index >= 0 && index < this.DRINKS.length) {
            this.selectedIndex = index;
          }
        })
        .onScrollStop(() => {
          animateTo({ duration: 200 }, () => {
            this.isAdjusting = false;
          })
          this.scroller.scrollTo({ xOffset: 0, yOffset: this.selectedIndex * 80, animation: { duration: 200, curve: Curve.EaseOut } });
        })
      }
      .width(120)
      .height(300)
      .position({ right: -30, top: 150 }) // 整体向屏幕右侧缩进 30px

    }
  }
}
