import router from '@ohos.router';
import { 隐私政策 } from './PrivacyPolicy';
import { 用户政策 } from './UserPolicy';

@Entry
@Component
export struct PrivacyPage {
  @State title: string = '';
  @State content: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.type === 'user') {
      this.title = '用户政策';
      this.content = 用户政策;
    } else {
      this.title = '隐私政策';
      this.content = 隐私政策;
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24)
          .onClick(() => router.back())
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      Scroll() {
        Text(this.content)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(24)
          .padding(20)
          .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
