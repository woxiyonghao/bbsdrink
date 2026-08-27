import router from '@ohos.router';

interface ActivityItem {
  name: string;
  duration: string;
  color1: string;
  color2: string;
  progress: number;
  icon: ResourceStr;
}

@Entry
@Component
export struct RunPage {
  private scroller: Scroller = new Scroller();
  @State scrollY: number = 0;
  @State listHeight: number = 0;

  @State activities: ActivityItem[] = [
    { name: '伸懒腰', duration: '1分钟', color1: '#FFB75E', color2: '#ED8F03', progress: 0, icon: $r('app.media.ic_sport_white') },
    { name: '接杯水', duration: '3分钟', color1: '#8ECAE6', color2: '#219EBC', progress: 0, icon: $r('app.media.ic_cup_water') },
    { name: '颈椎操', duration: '5分钟', color1: '#A8E063', color2: '#56AB2F', progress: 0, icon: $r('app.media.ic_sit_record') },
    { name: '眼保健操', duration: '5分钟', color1: '#FFD166', color2: '#F4A261', progress: 0, icon: $r('app.media.ic_sport_white') },
    { name: '喝杯咖啡', duration: '5分钟', color1: '#D4A373', color2: '#A98467', progress: 0, icon: $r('app.media.ic_drink_coffee') },
    { name: '闭目养神', duration: '3分钟', color1: '#FF758C', color2: '#FF7EB3', progress: 0, icon: $r('app.media.ic_home_filled') },
    { name: '喝杯果汁', duration: '3分钟', color1: '#FF9A9E', color2: '#FECFEF', progress: 0, icon: $r('app.media.ic_drink_juice') },
    { name: '楼下走走', duration: '10分钟', color1: '#06D6A0', color2: '#00A896', progress: 0, icon: $r('app.media.ic_sport_white') },
    { name: '喝杯茶', duration: '10分钟', color1: '#90E0EF', color2: '#0077B6', progress: 0, icon: $r('app.media.ic_drink_tea') },
    { name: '跑一下', duration: '15分钟', color1: '#118AB2', color2: '#073B4C', progress: 0, icon: $r('app.media.ic_sport_white') }
  ];

  aboutToAppear() {
    setTimeout(() => {
      for (let i = 0; i < this.activities.length; i++) {
        setTimeout(() => {
          animateTo({ duration: 1000, curve: Curve.EaseOut }, () => {
            this.activities[i].progress = Math.random() * 60 + 20; 
          })
        }, i * 100);
      }
    }, 300);
  }

  getTranslateY(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 140;
    let cardBottom = cardTop + 120;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0) return deltaTop * 0.9;
    if (deltaBottom > 0 && listHeight > 0) return -deltaBottom * 0.9;
    return 0;
  }

  getScale(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 140;
    let cardBottom = cardTop + 120;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0) return Math.max(0.8, 1 - deltaTop * 0.0005);
    if (deltaBottom > 0 && listHeight > 0) return Math.max(0.8, 1 - deltaBottom * 0.0005);
    return 1;
  }

  getOpacity(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 140;
    let cardBottom = cardTop + 120;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0) return Math.max(0, 1 - deltaTop * 0.002);
    if (deltaBottom > 0 && listHeight > 0) return Math.max(0, 1 - deltaBottom * 0.002);
    return 1;
  }

  getShadowRadius(index: number, scrollY: number, listHeight: number): number {
    let cardTop = index * 140;
    let cardBottom = cardTop + 120;
    let deltaTop = scrollY - cardTop;
    let deltaBottom = cardBottom - (scrollY + listHeight);

    if (deltaTop > 0 || (deltaBottom > 0 && listHeight > 0)) return 20;
    return 12;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
        
        Text('起来走走')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, top: 40, bottom: 20 })
      .alignItems(VerticalAlign.Center)

      // 运动列表 (双向层叠堆栈效果)
      List({ space: 20, scroller: this.scroller }) {
        ForEach(this.activities, (item: ActivityItem, index: number) => {
          ListItem() {
            Row() {
              // 左侧信息
              Column() {
                Text(item.name)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                
                Text(item.duration)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 25 })

              // 右侧：类似手表运动的环形进度 + 高清图标
              Stack() {
                Progress({ value: item.progress, total: 100, type: ProgressType.Ring })
                  .width(60) // 增大圆环
                  .height(60)
                  .color(Color.White)
                  .style({ strokeWidth: 5 })
                
                // 专属高清 SVG 图标，增大尺寸并填充白色
                Image(item.icon)
                  .width(32)
                  .height(32)
                  .fillColor(Color.White)
              }
              .margin({ right: 25 })
            }
            .width('100%')
            .height(120)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [[item.color1, 0.0], [item.color2, 1.0]]
            })
            // 动态阴影，产生层叠变化
            .shadow({ 
               radius: this.getShadowRadius(index, this.scrollY, this.listHeight), 
               color: this.getShadowRadius(index, this.scrollY, this.listHeight) > 12 ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.15)', 
               offsetY: this.getShadowRadius(index, this.scrollY, this.listHeight) > 12 ? 10 : 6 
            })
            .stateStyles({
              pressed: {
                .scale({ x: 0.95, y: 0.95 })
                .opacity(0.9)
              },
              normal: {
                .scale({ x: 1.0, y: 1.0 })
                .opacity(1.0)
              }
            })
            .animation({ duration: 200, curve: Curve.Friction })
            .onClick(() => {
              animateTo({ duration: 500 }, () => {
                this.activities[index].progress = 100;
              })
            })
          }
          .zIndex(index) // 保证层叠顺序正确
          // 核心重叠缩放逻辑：双向吸附粘滞
          .translate({ y: this.getTranslateY(index, this.scrollY, this.listHeight) })
          .scale({
             x: this.getScale(index, this.scrollY, this.listHeight),
             y: this.getScale(index, this.scrollY, this.listHeight)
          })
          .opacity(this.getOpacity(index, this.scrollY, this.listHeight))
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 20, right: 20, bottom: 20 })
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
