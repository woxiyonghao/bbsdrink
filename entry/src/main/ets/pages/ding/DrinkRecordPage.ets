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
  @State currentXOffset: number = 0; 
  
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

      // 中央杯子区域 (占据上半部分剩余空间)
      Column() {
        // 顶部显示的容量文本
        Text(`${this.currentAmount} ml`)
          .fontColor('#333333')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        // 玻璃杯
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

          // 中央显示的当前饮品图标
          Image(this.DRINKS[this.selectedIndex].icon)
            .width(60)
            .height(60)
            .fillColor('#333333')
            .opacity(0.8)
            .margin({ bottom: 80 })
        }
        .width(160)
        .layoutWeight(1) // 自动伸展高度
        .border({ width: 3, color: '#E0E0E0', radius: 10 })
        .clip(true)
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 20, bottom: 20 })

      // 容量滑块
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
      .margin({ left: 30, right: 30, bottom: 20 })

      // ==========================================
      // 底部水平变焦表盘 (半圆形轨道)
      // ==========================================
      Stack({ alignContent: Alignment.Bottom }) {
        // 调焦时的浅灰色半圆形毛玻璃底板
        if (this.isAdjusting) {
          Ellipse()
            .width('120%')
            .height(200) // 让椭圆大一些，只露出上半部分
            .fill('rgba(230, 230, 230, 0.5)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .margin({ bottom: -60 }) // 向下偏移，露出一个完美的拱形
            .animation({ duration: 200 })
        }

        // 中心红线指示器 (类似相机对焦中间的准星)
        Column()
          .width(2)
          .height(16)
          .backgroundColor('#FF6B6B')
          .margin({ bottom: 70 }) // 对准处于最高点的图标中心
          .opacity(this.isAdjusting ? 1 : 0)
          .animation({ duration: 200 })

        // 水平滚轮列表
        List({ scroller: this.scroller }) {
          // 左侧占位 160px，使第0个元素正好居中 (360/2 - 80/2 = 140, 屏幕可能更宽，使用大约140-160的占位)
          // 为了适配所有屏幕，我们使用大约 40% 的视口宽度占位，这里写死140，实际运行在手机上大约居中
          ListItem().width(140)
          
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
                    .margin({ top: 8 })
                    .transition({ type: TransitionType.All, opacity: 0 })
                }
              }
              .width(80)
              .height(100)
              .justifyContent(FlexAlign.Center)
              // 关键抛物线上凸：中心 y 较小（靠上），两侧 y 较大（下沉）
              .translate({ y: 0.003 * Math.pow(index * 80 - this.currentXOffset, 2) - 20 })
            }
            .onClick(() => {
              this.scroller.scrollTo({ xOffset: index * 80, yOffset: 0, animation: { duration: 300, curve: Curve.EaseInOut } });
              this.selectedIndex = index;
            })
          })
          
          // 右侧占位 140px
          ListItem().width(140)
        }
        .listDirection(Axis.Horizontal)
        .width('100%')
        .height(120)
        .scrollBar(BarState.Off)
        .onScrollStart(() => {
          animateTo({ duration: 200 }, () => {
            this.isAdjusting = true;
          })
        })
        .onScroll(() => {
          const xOffset = this.scroller.currentOffset().xOffset;
          this.currentXOffset = xOffset;
          const index = Math.round(xOffset / 80);
          if (index !== this.selectedIndex && index >= 0 && index < this.DRINKS.length) {
            this.selectedIndex = index;
          }
        })
        .onScrollStop(() => {
          animateTo({ duration: 200 }, () => {
            this.isAdjusting = false;
          })
          this.scroller.scrollTo({ xOffset: this.selectedIndex * 80, yOffset: 0, animation: { duration: 200, curve: Curve.EaseOut } });
        })
      }
      .width('100%')
      .height(120)

      // 底部“喝”按钮
      Button('喝')
        .width(240)
        .height(60)
        .backgroundColor('#07C160')
        .fontColor('#FFFFFF')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 30 })
        .shadow({ radius: 15, color: 'rgba(7,193,96,0.3)', offsetY: 6 })
        .onClick(() => {
          this.handleDrink();
        })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
