import { HomePage } from '../home/HomePage';
import { DingPage } from '../ding/DingPage';
import { MinePage } from '../mine/MinePage';
import { THEME_COLOR } from '../../tools/Theme';

@Entry
@Component
export struct TabsPage {
  @Provide('isTabBarShow') isTabBarShow: boolean = true;
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  private primaryColor: string = THEME_COLOR;
  private unselectedColor: string = '#999999';

  @Builder
  TabBarBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .width(22)
        .height(22)
        .margin({ bottom: 4 })
        .fillColor(this.currentIndex === targetIndex ? this.primaryColor : this.unselectedColor)
        .scale({ x: this.currentIndex === targetIndex ? 1.35 : 1, y: this.currentIndex === targetIndex ? 1.35 : 1 })
        .animation({ duration: 300, curve: Curve.Friction })
      
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? this.primaryColor : this.unselectedColor)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
    .layoutWeight(1) // 均分宽度
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 1. 内容区域
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          HomePage({ currentTabIndex: this.currentIndex })
        }
        TabContent() {
          DingPage({ currentTabIndex: this.currentIndex })
        }
        TabContent() {
          MinePage({ currentTabIndex: this.currentIndex })
        }
      }
      .scrollable(false)
      .barHeight(0) // 隐藏默认 TabBar
      .animationDuration(0) // 禁用滑动动画，响应更干脆
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .height('100%')

      // 2. iOS 胶囊形毛玻璃自定义 TabBar
      if (this.isTabBarShow) {
        Stack({ alignContent: Alignment.Center }) {
          Stack({ alignContent: Alignment.Start }) {
            // 液态滑动玻璃指示器 (修复位置与透明度)
            Row()
              .width('33.333%')
              .height('100%')
              .borderRadius(28)
              .backgroundColor('rgba(255, 255, 255, 0.35)') // 增加透明度，呈现更真实的毛玻璃反光
              .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.04)', offsetY: 2 })
              .position({ x: `${this.currentIndex * 33.333}%`, y: 0 }) // 使用精确的父组件绝对定位
              .animation({ duration: 350, curve: Curve.Friction })

            Row() {
              this.TabBarBuilder('首页', 0, $r('app.media.ic_home_anim'), $r('app.media.ic_home_anim_static'))
              this.TabBarBuilder('打卡', 1, $r('app.media.ic_ding_phone_anim'), $r('app.media.ic_ding_phone_static'))
              this.TabBarBuilder('我的', 2, $r('app.media.ic_mine_tie_anim'), $r('app.media.ic_mine_tie_static'))
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height('100%')
          .padding(4)
        }
        .width('80%') // 胶囊宽度，两边留白
        .height(64) // 胶囊高度
        .margin({ bottom: 24 }) // 悬浮于底部
        .borderRadius(32) // 完全圆角，形成胶囊形状
        .backgroundColor('rgba(7, 193, 96, 0.15)') // 淡淡的主题绿色，增加毛玻璃的通透感
        .backdropBlur(30) // 原生的强背景模糊（毛玻璃核心）
        .shadow({ radius: 15, color: 'rgba(0, 0, 0, 0.08)', offsetY: 5 }) // 悬浮阴影
        .border({ width: 0.5, color: 'rgba(255, 255, 255, 0.6)' }) // 边缘高光边框
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5') // 页面底层给点底色，毛玻璃效果更明显
  }

  // 页面转场动画定义
  pageTransition() {
    // 退场动画 (当push新页面时，当前页退场)
    // ding -> 变大，透明度渐渐变透明，1.0->1.4
    PageTransitionExit({ type: RouteType.Push, duration: 400, curve: Curve.Linear })
      .opacity(0)
      .scale({ x: 1.4, y: 1.4 })

    // 进场动画 (当从新页面pop回来时，当前页进场)
    // ding从原本消失时变大的1.4倍变回1.0，透明渐渐不透明
    PageTransitionEnter({ type: RouteType.Pop, duration: 400, curve: Curve.Linear })
      .opacity(0)
      .scale({ x: 1.4, y: 1.4 })
  }
}
