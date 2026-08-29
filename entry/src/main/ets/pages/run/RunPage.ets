import router from '@ohos.router';
import { ActivityItem, GLOBAL_ACTIVITIES } from '../../types';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

@Entry
@Component
export struct RunPage {
  private scroller: Scroller = new Scroller();
  @State scrollY: number = 0;
  @State listHeight: number = 0;

  @State activities: ActivityItem[] = GLOBAL_ACTIVITIES.map(item => item.clone());

  /**
   * 页面显示时从数据库查询各运动的真实完成状态
   * 60 分钟内完成过 → 进度 100%，否则 → 0%
   */
  async aboutToAppear() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId <= 0) return;

    for (let i = 0; i < this.activities.length; i++) {
      const done = await RdbHelper.queryActivityDoneInLastHour(userId, this.activities[i].activityType);
      const targetProgress = done ? 100 : 0;
      // 延迟一小段再启动动画，保持卡片入场的层叠效果
      const delay = i * 80;
      setTimeout(() => {
        animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
          this.activities[i].progress = targetProgress;
        });
      }, 300 + delay);
    }
  }

  /**
   * 从运动页面返回时刷新进度（onPageShow 每次显示都触发）
   */
  async onPageShow() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId <= 0) return;

    for (let i = 0; i < this.activities.length; i++) {
      const done = await RdbHelper.queryActivityDoneInLastHour(userId, this.activities[i].activityType);
      animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
        this.activities[i].progress = done ? 100 : 0;
      });
    }
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
        
        Text('运动一下')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, top: 40, bottom: 20 })
      .alignItems(VerticalAlign.Center)

      // 运动列表（双向层叠堆栈效果）
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

              // 右侧：环形进度 + 图标
              Stack() {
                Progress({ value: item.progress, total: 100, type: ProgressType.Ring })
                  .width(60)
                  .height(60)
                  .color(Color.White)
                  .style({ strokeWidth: 5 })
                
                if (item.isEmoji) {
                  Text(item.icon as string)
                    .fontSize(30)
                } else {
                  Image(item.icon)
                    .width(32)
                    .height(32)
                    .fillColor(item.noFill ? undefined : Color.White)
                    .borderRadius(item.noFill ? 16 : 0)
                }
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
              // 跳转运动打卡页，传入活动名、目标秒数和专属 activityType
              const targetUrl = item.activityPage || 'pages/run/StretchPage';
              router.pushUrl({
                url: targetUrl,
                params: {
                  activityName: item.name,
                  targetSeconds: item.targetSeconds,
                  activityType: item.activityType
                }
              });
            })
          }
          .zIndex(index)
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
      .onAreaChange((_oldValue: Area, newValue: Area) => {
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
