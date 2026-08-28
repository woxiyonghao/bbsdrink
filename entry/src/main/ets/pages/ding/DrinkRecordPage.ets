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
    new DrinkOption(5, '柠檬茶', $r('app.media.ic_drink_lemon')),
    new DrinkOption(6, '运动饮料', $r('app.media.ic_drink_sports')),
    new DrinkOption(7, '气泡水', $r('app.media.ic_drink_sparkling')),
    new DrinkOption(8, '椰子水', $r('app.media.ic_drink_coconut')),
    new DrinkOption(9, '花茶', $r('app.media.ic_drink_herbal')),
    new DrinkOption(10, '热可可', $r('app.media.ic_drink_cocoa')),
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
      // ==========================================
      // 上半部分：导航、杯子和滑块 (白色背景)
      // ==========================================
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

        // 中央杯子区域
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
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')


      // ==========================================
      // 下半部分：底部水平变焦表盘 (清透毛玻璃模式)
      // ==========================================
      Stack({ alignContent: Alignment.Bottom }) {
        // 天空淡蓝毛玻璃半圆形背景
        Ellipse()
          .width('150%')
          .height(400)
          .fill('rgba(135, 206, 235, 0.2)') // 天空淡蓝
          .strokeWidth(0.5)
          .stroke('rgba(255, 255, 255, 0.6)') // 边缘高光
          .backgroundBlurStyle(BlurStyle.Thin) 
          .backdropBlur(30) // 毛玻璃效果
          .margin({ bottom: -120 })

        Column() {
          // 水平滚轮列表
          List({ scroller: this.scroller }) {
            ListItem().width(140)
            
            ForEach(this.DRINKS, (item: DrinkOption, index: number) => {
              ListItem() {
                Column() {
                  Image(item.icon)
                    .width(28) 
                    .height(28)
                    .fillColor(this.selectedIndex === index ? 'rgba(7, 193, 96, 0.4)' : '#FFFFFF') // 选中更淡的绿，未选中白
                    .animation({ duration: 200 })

                  Text(item.name)
                    .fontSize(this.selectedIndex === index ? 14 : 11)
                    .fontColor(this.selectedIndex === index ? 'rgba(7, 193, 96, 0.4)' : '#FFFFFF')
                    .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Normal)
                    .margin({ top: 8 })
                    .animation({ duration: 200 })
                }
                .width(80)
                .height(80)
                .justifyContent(FlexAlign.Center)
                .translate({ y: 0.002 * Math.pow(index * 80 - this.currentXOffset, 2) })
              }
              .onClick(() => {
                this.scroller.scrollTo({ xOffset: index * 80, yOffset: 0, animation: { duration: 300, curve: Curve.EaseInOut } });
                this.selectedIndex = index;
              })
            })
            
            ListItem().width(140)
          }
          .listDirection(Axis.Horizontal)
          .width('100%')
          .height(100)
          .scrollBar(BarState.Off)
          .onScroll(() => {
            const xOffset = this.scroller.currentOffset().xOffset;
            this.currentXOffset = xOffset;
            const index = Math.round(xOffset / 80);
            if (index !== this.selectedIndex && index >= 0 && index < this.DRINKS.length) {
              this.selectedIndex = index;
            }
          })
          .onScrollStop(() => {
            this.scroller.scrollTo({ xOffset: this.selectedIndex * 80, yOffset: 0, animation: { duration: 200, curve: Curve.EaseOut } });
          })

          // 底部圆形矢量图按钮 (喝)
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_action_drink2')) // 新的喝水动作icon
              .width(36)
              .height(36)
              .fillColor('#FFFFFF') // 白色矢量图标
          }
          .width(72)
          .height(72)
          .backgroundColor('rgba(7, 193, 96, 0.2)') // 底座的淡绿作为背景色
          .margin({ top: 10, bottom: 30 })
          .shadow({ radius: 10, color: 'rgba(7, 193, 96, 0.1)', offsetY: 4 })
          .onClick(() => {
            this.handleDrink();
          })
        }
      }
      .width('100%')
      .backgroundColor('#FFFFFF') // 防止 Stack 外部漏出底色
    }
    .width('100%')
    .height('100%')
  }
}
