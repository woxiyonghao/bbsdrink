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
  @State selectedDrink: number = 0;
  @State currentAmount: number = 250;
  @State waveOffsetX: number = 0;
  @State waveOffsetY: number = 0;
  
  readonly DRINKS: DrinkOption[] = [
    new DrinkOption(0, '水', $r('app.media.ic_drink_water')),
    new DrinkOption(1, '咖啡', $r('app.media.ic_drink_coffee')),
    new DrinkOption(2, '茶', $r('app.media.ic_drink_tea')),
    new DrinkOption(3, '牛奶', $r('app.media.ic_drink_milk')),
    new DrinkOption(5, '果汁', $r('app.media.ic_drink_juice'))
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
    if (userId > 0) {
      await RdbHelper.insertRecord({
        userId: userId,
        type: 0,
        value: this.currentAmount,
        timestamp: new Date().getTime()
      });
      promptAction.showToast({ message: `吨吨吨！成功补充 ${this.currentAmount}ml 水分！` });
      router.back();
    } else {
      promptAction.showToast({ message: '请先登录' });
    }
  }

  build() {
    Stack() {
      // 整体深色背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#2C2C34')

      // 右侧弧线 (装饰)
      Path()
        .commands('M0,0 Q-80,200 0,400')
        .stroke('#07C160')
        .strokeWidth(3)
        .fill('transparent')
        .width(80)
        .height(400)
        .position({ right: 0, top: 120 })
        .opacity(0.6)

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
            .fontColor('#FF6B6B') // 草图中是红色的 drink 字样
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })

        // 刻度和杯子区域
        Row() {
          // 左侧文本
          Text(`${this.currentAmount} ml`)
            .fontColor('#F6D365')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ right: 10, top: -140 })

          // 中央杯子容器
          Stack({ alignContent: Alignment.Bottom }) {
            // 背景
            Column().width('100%').height('100%').backgroundColor('rgba(255, 255, 255, 0.05)')

            // 动态波浪水位 (根据容量计算高度比例，假设最大 1000ml)
            Stack({ alignContent: Alignment.Bottom }) {
              // 后置浅色波浪
              Path()
                .commands('M0,30 Q50,0 100,30 T200,30 T300,30 T400,30 L400,500 L0,500 Z')
                .fill('rgba(33, 158, 188, 0.5)')
                .offset({ x: this.waveOffsetX, y: 0 })
              
              // 前置深色波浪 (不同速度和相位)
              Path()
                .commands('M0,30 Q50,60 100,30 T200,30 T300,30 T400,30 L400,500 L0,500 Z')
                .fill('rgba(142, 202, 230, 0.8)')
                .offset({ x: this.waveOffsetX * 1.5, y: 0 })
            }
            .width('300%') // 足够宽以平移
            .height(`${Math.max(10, (this.currentAmount / 1000) * 100)}%`)
            .animation({ duration: 800, curve: Curve.FastOutSlowIn })

            // 中央文字提示
            Text(this.DRINKS.find(d => d.type === this.selectedDrink)?.name || '水')
              .fontSize(24)
              .fontColor('#F6D365')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 120 })

          }
          .width(180)
          .height(320)
          .border({ width: 3, color: '#F6D365', radius: 10 })
          .clip(true)
          
          Blank()
          
          // 右侧选择菜单
          Column({ space: 16 }) {
            ForEach(this.DRINKS, (item: DrinkOption) => {
              Column() {
                Image(item.icon)
                  .width(28)
                  .height(28)
                  .fillColor(this.selectedDrink === item.type ? '#2C2C34' : '#F6D365')
              }
              .width(50)
              .height(50)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.selectedDrink === item.type ? '#F6D365' : 'transparent')
              .border({ width: 2, color: '#FF6B6B', radius: 10 }) // 红色边框如草图
              .onClick(() => {
                this.selectedDrink = item.type;
              })
            })
          }
          .margin({ right: 20 })
          
        }
        .width('100%')
        .padding({ left: 20 })
        .margin({ top: 40 })

        // 底部容量滑块
        Slider({
          value: this.currentAmount,
          min: 50,
          max: 1000,
          step: 50,
          style: SliderStyle.OutSet
        })
        .blockColor('#F6D365')
        .trackColor('rgba(255,255,255,0.2)')
        .selectedColor('#07C160')
        .showSteps(true)
        .onChange((value: number) => {
          this.currentAmount = value;
        })
        .margin({ top: 40, left: 30, right: 30 })

        Blank()

        // 底部“喝”按钮
        Button('喝')
          .width(240)
          .height(70)
          .backgroundColor('transparent')
          .border({ width: 3, color: '#F6D365', radius: 35 })
          .fontColor('#F6D365')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 40 })
          .onClick(() => {
            this.handleDrink();
          })

      }
      .width('100%')
      .height('100%')
    }
  }
}
