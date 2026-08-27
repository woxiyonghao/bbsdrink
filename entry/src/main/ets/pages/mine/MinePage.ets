import { THEME_COLOR } from '../../tools/Theme';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { User } from '../../types';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
export struct MinePage {
  @State currentUser: User | null = null;
  @State scaleValue: number = 1;
  @State opacityValue: number = 1;
  
  async aboutToAppear() {
    const userId: number = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.currentUser = await RdbHelper.queryUserById(userId);
    }
  }

  // 自定义单片卡片式列表项
  @Builder MenuItem(icon: Resource, text: string, onClickAction: () => void) {
    Row() {
      Image(icon).width(24).height(24).margin({ right: 15 })
      Text(text).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333').layoutWeight(1)
      Image($r('app.media.ic_arrow_right')).width(20).height(20)
    }
    .width('90%')
    .height(70)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .shadow({ radius: 20, color: '#0D000000', offsetX: 0, offsetY: 5 })
    .margin({ bottom: 15 })
    .onClick(onClickAction)
  }

  build() {
    Column() {
      // 1. 顶部 Header 区域
      Stack({ alignContent: Alignment.TopStart }) {
        // 右上角设置图标
        Image($r('app.media.ic_settings_white')).width(26).height(26)
          .position({ x: '100%', y: 30 })
          .translate({ x: '-100%' })
          .margin({ right: 20 })
          .onClick(() => { promptAction.showToast({message: '设置待开发', bottom: 60}); })

        // 右侧大头像
        if (this.currentUser && this.currentUser.avatar) {
          Image(this.currentUser.avatar)
            .width(160).height(160)
            .borderRadius(80)
            .position({ x: '55%', y: 80 })
            .opacity(0.8)
            .objectFit(ImageFit.Cover)
        } else {
          Image($r('app.media.ic_avatar_placeholder'))
            .width(160).height(160)
            .borderRadius(80)
            .position({ x: '55%', y: 80 })
            .opacity(0.5)
        }

        // 左侧文字排版区
        Column() {
          Text('我的')
            .fontSize(36).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          
          Blank() // 撑开中间空间
          
          Divider().color('#FFFFFF').strokeWidth(3).width(20)
            .margin({ bottom: 20 })
            
          Row() {
            Text(this.currentUser?.nickname || '未登录')
              .fontSize(28).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
            Image($r('app.media.ic_edit_white')).width(20).height(20).margin({ left: 10 })
          }
          .margin({ bottom: 8 })
          
          Text(`健康达人 ${this.currentUser?.id || '--'}`)
            .fontSize(14).fontColor('#E0E0E0')
        }
        .alignItems(HorizontalAlign.Start)
        .height('100%')
        .padding({ left: 25, top: 70, bottom: 60 })
      }
      .width('100%').height(320)
      .backgroundColor(THEME_COLOR) // 微信绿主色调
      .borderRadius({ bottomLeft: 30, bottomRight: 30 })

      // 3. 菜单列表区 (向上偏移，覆盖在绿色背景上)
      Column() {
        this.MenuItem($r('app.media.ic_drink_record'), '喝水记录', () => { promptAction.showToast({message: '喝水记录待开发', bottom: 60}); })
        
        this.MenuItem($r('app.media.ic_check_record'), '打卡记录', () => { promptAction.showToast({message: '打卡记录待开发', bottom: 60}); })
        
        this.MenuItem($r('app.media.ic_sit_record'), '久坐记录', () => { promptAction.showToast({message: '久坐记录待开发', bottom: 60}); })
        
        this.MenuItem($r('app.media.ic_about'), '关于', () => { promptAction.showToast({message: '关于健康打卡 v1.0.0', bottom: 60}); })

        this.MenuItem($r('app.media.ic_logout'), '退出登录', () => {
          promptAction.showDialog({
            title: '退出登录',
            message: '确认要退出当前账号吗？',
            buttons: [
              { text: '取消', color: '#888888' },
              { text: '退出', color: '#ff4d4f' }
            ]
          }).then(async (data: promptAction.ShowDialogSuccessResponse) => {
            if (data.index === 1) { // 确认退出
              // 触发手动转场动画
              animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
                this.scaleValue = 0.8;
                this.opacityValue = 0;
              });
              
              // 动画结束后路由
              setTimeout(async () => {
                await PreferencesUtil.setCurrentUserId(-1);
                router.replaceUrl({ url: 'pages/login/LoginPage' });
              }, 400);
            }
          })
        })
      }
      .width('100%')
      .offset({ y: -40 }) // 让整个列表卡片悬浮在 Header 上
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 浅灰背景色
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .opacity(this.opacityValue)
  }
}
