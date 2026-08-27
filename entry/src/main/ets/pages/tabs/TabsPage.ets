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
  private unselectedColor: string = '#8A8A8A';

  @Builder
  TabBarBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .width(22)
        .height(22)
        .margin({ bottom: 4 })
        .fillColor(this.currentIndex === targetIndex ? this.primaryColor : this.unselectedColor)
      
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
          HomePage()
        }
        TabContent() {
          DingPage()
        }
        TabContent() {
          MinePage()
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
        Row() {
          this.TabBarBuilder('首页', 0, $r('app.media.ic_home_filled'), $r('app.media.ic_home'))
          this.TabBarBuilder('打卡', 1, $r('app.media.ic_ding_filled'), $r('app.media.ic_ding'))
          this.TabBarBuilder('我的', 2, $r('app.media.ic_mine_filled'), $r('app.media.ic_mine'))
        }
        .width('80%') // 胶囊宽度，两边留白
        .height(64) // 胶囊高度
        .margin({ bottom: 24 }) // 悬浮于底部
        .borderRadius(32) // 完全圆角，形成胶囊形状
        .backgroundColor('rgba(255, 255, 255, 0.4)') // 增加透明度以增强毛玻璃质感
        .backdropBlur(30) // 原生的强背景模糊（毛玻璃核心）
        .shadow({ radius: 15, color: 'rgba(0, 0, 0, 0.08)', offsetY: 5 }) // 悬浮阴影
        .border({ width: 0.5, color: 'rgba(255, 255, 255, 0.6)' }) // 边缘高光边框
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5') // 页面底层给点底色，毛玻璃效果更明显
  }
}
