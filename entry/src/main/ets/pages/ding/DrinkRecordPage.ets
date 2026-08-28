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

@Observed
class Bubble {
  id: number;
  x: number;
  y: number;
  size: number;
  opacity: number;
  duration: number;
  constructor(id: number, x: number, y: number, size: number, opacity: number, duration: number) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.size = size;
    this.opacity = opacity;
    this.duration = duration;
  }
}

@Component
struct BubbleView {
  @ObjectLink bubble: Bubble;
  @State wobbleX: number = 0;

  aboutToAppear() {
    // 左右摇摆的随机幅度与周期
    const wobbleDistance = Math.random() * 30 + 10; // 10到40 vp
    const wobbleSpeed = Math.random() * 800 + 800; // 800到1600 ms

    // 初始随机偏移，打乱摇摆相位
    this.wobbleX = -wobbleDistance / 2;
    setTimeout(() => {
      animateTo({ duration: wobbleSpeed, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
        this.wobbleX = wobbleDistance / 2;
      });
    }, Math.random() * 500); // 随机延迟启动
  }

  build() {
    Image($r('app.media.paopao'))
      .width(this.bubble.size)
      .height(this.bubble.size)
      .position({ x: `${this.bubble.x}%`, y: `${this.bubble.y}%` })
      .opacity(this.bubble.opacity)
      .blendMode(BlendMode.LIGHTEN) // 关键：使用 LIGHTEN 模式，因为底图不是纯黑，LIGHTEN 可以完美过滤掉比背景暗的像素，只保留高光气泡
      .animation({
        duration: this.bubble.duration,
        curve: Curve.EaseOut // 或者 Curve.Linear
      })
      .translate({ x: this.wobbleX })
      .backgroundColor(Color.Transparent)
      .hitTestBehavior(HitTestMode.None)
  }
}

@Entry
@Component
export struct DrinkRecordPage {
  @State selectedIndex: number = 0;
  @State currentAmount: number = 250;
    @State waveOffsetX: number = 0;
  
  @State bubbles: Bubble[] = [];
  @State todayCategoryAmount: number = 0;
  
  // 动画状态
  @State flyY: number = 0;
  @State flyScale: number = 1;
  @State flyRotate: number = 0;
  @State flyOpacity: number = 0;
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
    this.loadCategoryData();
  }

  async loadCategoryData() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      const type = this.DRINKS[this.selectedIndex].type;
      const total = await RdbHelper.queryTodayTotalByType(userId, type);
      animateTo({ duration: 600, curve: Curve.EaseInOut }, () => {
        this.todayCategoryAmount = total;
      });
    }
  }

  startWaveAnimation() {
    animateTo({ duration: 3000, curve: Curve.Linear, iterations: -1 }, () => {
      this.waveOffsetX = -200;
    })
  }


  spawnBubbles() {
    let spawnCount = 0;
    const maxSpawns = 12; // 总共生成12批次气泡
    
    const intervalId = setInterval(() => {
      spawnCount++;
      if (spawnCount > maxSpawns) {
        clearInterval(intervalId);
        return;
      }

      // 每次随机生成 2 到 8 个气泡
      const count = Math.floor(Math.random() * 7) + 2; 
      const newBubbles: Bubble[] = [];
      const now = Date.now();
      
      for (let i = 0; i < count; i++) {
        const size = Math.random() * 70 + 8; // 尺寸 8 到 78，扩大大小的随机范围
        const depthFactor = (size - 8) / 70; // 0.0(最小) 到 1.0(最大)
        
        // 层次感：大的一般上浮快一点，小的一般上浮慢一点
        const duration = 4000 + (1 - depthFactor) * 3500; // 4秒 到 7.5秒
        const opacity = 0.25 + depthFactor * 0.55; // 0.25 到 0.8
        
        newBubbles.push(new Bubble(
          now + i + Math.random(), // 确保ID唯一
          Math.random() * 90 + 5, // X轴：5% 到 95%
          110, // Y轴：从屏幕下方开始
          size,
          opacity,
          duration
        ));
      }
      
      this.bubbles = this.bubbles.concat(newBubbles);
      
      // 等待组件挂载后，触发属性动画使其飘到屏幕外
      setTimeout(() => {
        newBubbles.forEach(b => {
          b.y = -20; // 目标位置：屏幕上方外侧
        });
      }, 50);

      // 动画结束后清理对应批次的气泡
      setTimeout(() => {
        const idsToRemove = new Set(newBubbles.map(b => b.id));
        this.bubbles = this.bubbles.filter(b => !idsToRemove.has(b.id));
      }, 8500); 
      
    }, 400); // 每 400 毫秒生成一批气泡
  }

  async playDrinkAnimation() {
    this.flyOpacity = 1;
    this.flyY = 0;
    this.flyScale = 1;
    this.flyRotate = 0;

    // 1. 0-0.6秒 慢慢变大，往屏幕中间靠近，最大跟屏幕宽度一致 (放大10倍)
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.flyY = -350; // 屏幕中间
      this.flyScale = 10;
    });

    await new Promise<void>(resolve => setTimeout(resolve, 600));

    // 2. 0.6-1秒 抖动 (类似Ding模块0.4秒)
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = 15; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = -15; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = 15; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));
    animateTo({ duration: 100, curve: Curve.Linear }, () => { this.flyRotate = 0; });
    await new Promise<void>(resolve => setTimeout(resolve, 100));

    // 3. 1-1.6秒 原路返回
    animateTo({ duration: 600, curve: Curve.EaseIn }, () => {
      this.flyY = 0;
      this.flyScale = 1;
      this.flyOpacity = 0;
    });

    await new Promise<void>(resolve => setTimeout(resolve, 600));
    this.flyOpacity = 0;
  }

  async handleDrink() {
    const userId = await PreferencesUtil.getCurrentUserId();
    const drink = this.DRINKS[this.selectedIndex];
    if (userId > 0) {
      await RdbHelper.insertRecord({
        userId: userId,
        type: drink.type,
        value: this.currentAmount,
        timestamp: new Date().getTime()
      });
      
      animateTo({ duration: 600, curve: Curve.EaseInOut }, () => {
        this.todayCategoryAmount += this.currentAmount; // Update local state for wave animation
      });
      
      promptAction.showToast({ message: `吨吨吨！成功记录 ${this.currentAmount}ml ${drink.name}！` });
      await this.playDrinkAnimation();
      this.spawnBubbles();
    } else {
      promptAction.showToast({ message: '请先登录' });
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 全局纯色背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#29C5F6')

      // 汽水气泡层
      // 汽水气泡层 (全屏容器，确保百分比坐标正确)
      Stack({ alignContent: Alignment.TopStart }) {
        ForEach(this.bubbles, (b: Bubble) => {
          BubbleView({ bubble: b })
        }, (b: Bubble) => b.id.toString())
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.None)
      .zIndex(999)

      Column() {
        // 顶部导航
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
        .margin({ top: 40 })

        Blank() // 核心改动：把下面的底座狠狠推到底部！

        // ==========================================
        // 下半部分：底部水平变焦表盘 (清透毛玻璃模式)
        // ==========================================
        Stack({ alignContent: Alignment.Bottom }) {
          // 更蓝的毛玻璃半圆形背景
          Ellipse()
          .width('150%')
          .height(400)
          .fill('rgba(80, 180, 255, 0.35)') // 更蓝一点
          .backgroundBlurStyle(BlurStyle.Thin) 
          .backdropBlur(40) // 增强原生模糊效果，模糊背景的波浪
          .margin({ bottom: -120 })

        Column() {
          // 水平滚轮列表
          List({ scroller: this.scroller }) {
            ListItem().width(140)
            
            ForEach(this.DRINKS, (item: DrinkOption, index: number) => {
              ListItem() {
                Column() {
                  Image(item.icon)
                    .width(this.selectedIndex === index ? 44 : 28) 
                    .height(this.selectedIndex === index ? 44 : 28)
                    .fillColor(this.selectedIndex === index ? '#80FFBB' : 'rgba(255, 255, 255, 0.6)') // 选中大+淡绿色，未选中半透明白
                    .animation({ duration: 200 })

                  Text(item.name)
                    .fontSize(this.selectedIndex === index ? 16 : 12)
                    .fontColor(this.selectedIndex === index ? '#80FFBB' : 'rgba(255, 255, 255, 0.6)')
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
            this.loadCategoryData();
          })

          // 底部圆形矢量图按钮 (喝)
          Button({ type: ButtonType.Circle }) {
            Image(this.DRINKS[this.selectedIndex].icon) // 喝的icon换成是当前选择的
              .width(36)
              .height(36)
              .fillColor('#FFFFFF')
          }
          .width(72)
          .height(72)
          .backgroundColor('rgba(7, 193, 96, 0.5)') // 背景色再绿一点
          .margin({ top: 10, bottom: 30 })
          .shadow({ radius: 10, color: 'rgba(7, 193, 96, 0.1)', offsetY: 4 })
          .onClick(() => {
            this.handleDrink();
          })
        } // 结束 Column (dial items)
      } // 结束 Stack (dial)
      .width('100%')
    } // 结束 Column (nav + dial)
    .width('100%')
    .height('100%') // 关键：让这个Column撑满屏幕，Blank才能生效

    // 悬浮飞出动画层 (不使用if条件包裹，防止动画还没播放就被销毁)
    Image(this.DRINKS[this.selectedIndex].icon)
      .width(36)
      .height(36)
      .fillColor('#FFFFFF')
      .margin({ bottom: 48 }) // 与底部Button的中心对齐
      .translate({ y: this.flyY })
      .scale({ x: this.flyScale, y: this.flyScale })
      .rotate({ angle: this.flyRotate })
      .opacity(this.flyOpacity)
      .hitTestBehavior(HitTestMode.None) // 防止隐形图标拦截底部按钮的点击事件！
  } // 结束 Stack (全局根组件)
  .width('100%')
  .height('100%')
} // 结束 build()
} // 结束 struct
