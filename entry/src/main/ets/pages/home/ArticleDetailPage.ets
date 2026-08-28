import router from '@ohos.router';
import { HealthArticle } from '../../store/MockArticles';

@Entry
@Component
export struct ArticleDetailPage {
  @State article: HealthArticle | null = null;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['article']) {
      this.article = params['article'] as HealthArticle;
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24)
          .onClick(() => router.back())
        Text('知识详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('rgba(255, 255, 255, 0.95)')
      .zIndex(10)

      if (this.article) {
        Scroll() {
          Column() {
            // 头图
            Image(this.article.imageUrl)
              .width('100%')
              .height(240)
              .objectFit(ImageFit.Cover)
            
            Column() {
              // 标题
              Text(this.article.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222222')
                .lineHeight(32)
                .margin({ top: 24, bottom: 16 })
              
              // 正文内容
              Text(this.article.content)
                .fontSize(16)
                .fontColor('#444444')
                .lineHeight(28) // 舒适的行距
                .letterSpacing(0.5)
            }
            .width('100%')
            .padding({ left: 24, right: 24, bottom: 60 })
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: 24, topRight: 24 })
            .margin({ top: -20 }) // 让白色内容区遮挡一点头图，形成层次感
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      } else {
        Column() {
          Text('文章加载失败')
            .fontColor('#999')
            .margin({ top: 100 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
