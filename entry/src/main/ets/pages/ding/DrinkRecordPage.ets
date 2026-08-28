import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

class DrinkOption {
  type: number;
  name: string;
  emoji: string;
  
  constructor(type: number, name: string, emoji: string) {
    this.type = type;
    this.name = name;
    this.emoji = emoji;
  }
}

@Entry
@Component
export struct DrinkRecordPage {
  @State selectedIndex: number = 0; // 当前选中的饮品索引
  @State currentAmount: number = 250;
  @State waveOffsetX: number = 0;
  @State isAdjusting: boolean = false; // 调焦 (滚动) 状态
  @State currentYOffset: number = 0; // 实时滚动偏移，用于计算曲线轨道
  
  private scroller: Scroller = new Scroller();

  readonly DRINKS: DrinkOption[] = [
    new DrinkOption(0, '水', '💧'),
    new DrinkOption(1, '咖啡', '☕'),
    new DrinkOption(2, '绿茶', '🍵'),
    new DrinkOption(3, '牛奶', '🥛'),
    new DrinkOption(4, '果汁', '🧃'),
    new DrinkOption(5, '可乐', '🥤'),
    new DrinkOption(6, '啤酒', '🍺'),
    new DrinkOption(7, '红酒', '🍷'),
    new DrinkOption(8, '马黛茶', '🧉'),
    new DrinkOption(9, '鸡尾酒', '🍹'),
    new DrinkOption(10, '清酒', '🍶'),
    new DrinkOption(11, '补剂', '🍼')
  ];

  aboutToAppear() {
    this.startWaveAnimation();
  }

  startWaveAnimation() {
    // 匀速无限循环平移，制造波浪流动感
    animateTo({ duration: 3000, curve: Curve.Linear, iterations: -1 }, () => {
      this.waveOffsetX = -200; // 对应波浪路径的一个完整周期
    })
  }

  async handleDrink() {
    const userId = await PreferencesUtil.getCurrentUserId();
    const drink = this.DRINKS[this.selectedIndex];
    if (userId > 0) {
      await RdbHelper.insertRecord({
        userId: userId,
        type: 0, // 底层统称为喝水，后续可根据 drink.type 细化
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

            // 动态波浪水位 (根据容量计算高度比例)
            Stack({ alignContent: Alignment.Bottom }) {
              // 后置浅色波浪
              Path()
                .commands('M0,30 Q50,0 100,30 T200,30 T300,30 T400,30 L400,500 L0,500 Z')
                .fill('rgba(33, 158, 188, 0.5)')
                .offset({ x: this.waveOffsetX, y: 0 })
              
              // 前置深色波浪
              Path()
                .commands('M0,30 Q50,60 100,30 T200,30 T300,30 T400,30 L400,500 L0,500 Z')
                .fill('rgba(142, 202, 230, 0.8)')
                .offset({ x: this.waveOffsetX * 1.5, y: 0 })
            }
            .width('300%') // 足够宽以平移
            .height(`${Math.max(10, (this.currentAmount / 1000) * 100)}%`)
            .animation({ duration: 800, curve: Curve.FastOutSlowIn })

            // 顶部显示的容量文本 (紧贴水位上方)
            Text(`${this.currentAmount} ml`)
              .fontColor('#333333')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: '100%' }) // 让它飘在顶部附近

            // 中央显示的当前饮品 Emoji
            Text(this.DRINKS[this.selectedIndex].emoji)
              .fontSize(60)
              .opacity(0.8)
              .margin({ bottom: 100 })

          }
          .width(180)
          .height(320)
          .border({ width: 3, color: '#E0E0E0', radius: 10 })
          .clip(true)
          .margin({ left: 40 }) // 让杯子稍微偏左，给右侧滚轮留空间
          
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
      // 右侧 iPhone 变焦滚轮 (绝对定位)
      // ==========================================
      Stack({ alignContent: Alignment.End }) {
        // 绿色弧线轨道
        Path()
          .commands('M30,0 Q-90,150 30,300')
          .stroke('#07C160')
          .strokeWidth(3)
          .fill('transparent')
          .width(100)
          .height(300)
          .margin({ right: 30 })

        // 调焦时的毛玻璃椭圆特效
        if (this.isAdjusting) {
          Ellipse()
            .width(100)
            .height(180)
            .fill('rgba(255, 255, 255, 0.65)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .margin({ right: 5 })
            .animation({ duration: 200 })
        }

        // 滚轮列表
        List({ scroller: this.scroller }) {
          // 顶部占位 120px，使第0个元素正好居中 (300/2 - 60/2)
          ListItem().height(120)
          
          ForEach(this.DRINKS, (item: DrinkOption, index: number) => {
            ListItem() {
              Row() {
                // 只有在调焦时，或者被选中时，才显示文字
                if (this.isAdjusting || this.selectedIndex === index) {
                  Text(item.name)
                    .fontSize(this.selectedIndex === index ? 16 : 12)
                    .fontColor(this.selectedIndex === index ? '#07C160' : '#999')
                    .margin({ right: 12 })
                    .transition({ type: TransitionType.All, opacity: 0, translate: { x: 20 } })
                }

                Text(item.emoji)
                  .fontSize(this.selectedIndex === index ? 40 : 24)
                  .animation({ duration: 200 })
              }
              .width(140)
              .height(60)
              .justifyContent(FlexAlign.End)
              .padding({ right: 20 }) // 让 icon 贴近右侧
              .translate({ x: 0.001333 * Math.pow(index * 60 - this.currentYOffset, 2) - 30 }) // 抛物线偏移，模拟弧形轨道
            }
            .onClick(() => {
              // 点击直接滚动到对应位置
              this.scroller.scrollTo({ xOffset: 0, yOffset: index * 60, animation: { duration: 300, curve: Curve.EaseInOut } });
              this.selectedIndex = index;
            })
          })
          
          // 底部占位 120px
          ListItem().height(120)
        }
        .width(140)
        .height(300)
        .scrollBar(BarState.Off)
        .onScrollStart(() => {
          animateTo({ duration: 200 }, () => {
            this.isAdjusting = true;
          })
        })
        .onScroll(() => {
          // 实时更新当前选中的 index 和滚动偏移
          const yOffset = this.scroller.currentOffset().yOffset;
          this.currentYOffset = yOffset;
          const index = Math.round(yOffset / 60);
          if (index !== this.selectedIndex && index >= 0 && index < this.DRINKS.length) {
            this.selectedIndex = index;
          }
        })
        .onScrollStop(() => {
          animateTo({ duration: 200 }, () => {
            this.isAdjusting = false;
          })
          // 吸附到最近的元素
          this.scroller.scrollTo({ xOffset: 0, yOffset: this.selectedIndex * 60, animation: { duration: 200, curve: Curve.EaseOut } });
        })
      }
      .width(140)
      .height(300)
      .position({ right: 0, top: 150 })

    }
  }
}
