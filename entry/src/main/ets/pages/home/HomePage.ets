import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { User } from '../../types';

import { HealthArticle, HEALTH_ARTICLES } from '../../store/MockArticles';

@Entry
@Component
export struct HomePage {
  @State userId: number = -1;
  @State nickname: string = '朋友';
  @State todayDrank: number = 0;
  @State dailyGoal: number = 2000; // 默认2000ml
  @State hasCheckedIn: boolean = false;
  
  private currentDate: string = '';

  aboutToAppear() {
    const date = new Date();
    this.currentDate = `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
    this.initData();
  }

  async initData() {
    this.userId = await PreferencesUtil.getCurrentUserId();
    if (this.userId > 0) {
      const user = await RdbHelper.queryUserById(this.userId);
      if (user) {
        this.nickname = user.nickname;
      }
      this.todayDrank = await RdbHelper.queryTodayWaterTotal(this.userId);
      // 检查今日是否已签到等逻辑后续可补充
    }
  }

  async addWater(amount: number) {
    if (this.userId <= 0) return;
    // UI 动画
    animateTo({ duration: 500, curve: Curve.Friction }, () => {
      this.todayDrank += amount;
    });
    // 入库
    await RdbHelper.insertRecord({
      userId: this.userId,
      type: 0, // 0 表示喝水
      value: amount,
      timestamp: new Date().getTime()
    });
  }

  @Builder QuickAddWaterBtn(label: string, amount: number) {
    Button(label)
      .width(80)
      .height(36)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor('#07C160')
      .backgroundColor('rgba(7, 193, 96, 0.1)')
      .borderRadius(18)
      .onClick(() => this.addWater(amount))
  }

  @Builder HealthCard(title: string, value: string, unit: string, icon: Resource, bgColor: string = '#FFF') {
    Column() {
      Row() {
        Image(icon).width(20).height(20).fillColor('#07C160')
        Text(title).fontSize(14).fontColor('#666').margin({ left: 6 })
        Blank()
      }.width('100%')
      
      Row() {
        Text(value).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#333')
        Text(unit).fontSize(12).fontColor('#999').margin({ left: 4, bottom: 4 })
      }.width('100%').margin({ top: 16 }).alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .height(100)
    .padding(16)
    .backgroundColor(bgColor)
    .borderRadius(20)
    .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.03)', offsetY: 4 })
    .onClick(() => { promptAction.showToast({ message: `${title}功能开发中` }) })
  }

  build() {
    Scroll() {
      Column() {
        // 1. 顶部 Header (问候与签到)
        Row() {
          Column() {
            Text(`早上好，${this.nickname}`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text(this.currentDate)
              .fontSize(13)
              .fontColor('#888888')
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          
          // 签到按钮
          Row() {
            Image($r('app.media.ic_check_record')).width(16).height(16).fillColor(this.hasCheckedIn ? '#FFFFFF' : '#07C160')
            Text(this.hasCheckedIn ? '已签到' : '签到')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.hasCheckedIn ? '#FFFFFF' : '#07C160')
              .margin({ left: 4 })
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.hasCheckedIn ? '#07C160' : 'rgba(7, 193, 96, 0.15)')
          .borderRadius(16)
          .onClick(() => {
            if (!this.hasCheckedIn) {
              this.hasCheckedIn = true;
              promptAction.showToast({ message: '签到成功！' });
            }
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 20 })

        // 2. 核心大盘：喝水进度环
        Column() {
          Stack() {
            Progress({ value: this.todayDrank, total: this.dailyGoal, type: ProgressType.Ring })
              .width(180)
              .height(180)
              .color('#07C160')
              .backgroundColor('#F5F7FA')
              .style({ strokeWidth: 16 })
              .animation({ duration: 800, curve: Curve.FastOutSlowIn }) // 喝水时的圆环动画
            
            Column() {
              Image($r('app.media.ic_drink_water')).width(28).height(28).fillColor('#07C160').margin({ bottom: 4 })
              Text(`${this.todayDrank}`)
                .fontSize(36)
                .fontWeight(FontWeight.Bolder)
                .fontColor('#333333')
              Text(`/ ${this.dailyGoal} ml`)
                .fontSize(14)
                .fontColor('#999999')
            }
          }.margin({ bottom: 30, top: 10 })

          // 快捷加水按钮
          Row({ space: 12 }) {
            this.QuickAddWaterBtn('+150ml', 150)
            this.QuickAddWaterBtn('+250ml', 250)
            this.QuickAddWaterBtn('+500ml', 500)
          }
        }
        .width('90%')
        .padding({ top: 24, bottom: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.04)', offsetY: 8 })
        .margin({ bottom: 20 })

        // 3. 健康双卡片 (防久坐 & 步数)
        Row({ space: 16 }) {
          this.HealthCard('今日活动', '0', '次', $r('app.media.ic_sit_record'))
          this.HealthCard('今日步数', '0', '步', $r('app.media.ic_check_record')) // 暂用 check 图标
        }
        .width('90%')
        .margin({ bottom: 32 })

        // 4. 图文并茂的健康知识栏目
        Column() {
          Row() {
            Text('健康小贴士')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Blank()
            Text('查看更多')
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 16, top: 20 })
          
          ForEach(HEALTH_ARTICLES, (article: HealthArticle) => {
            Row() {
              Column() {
                Text(article.title)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.White)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .lineHeight(22)
                
                Blank()
                
                Text(article.summary)
                  .fontSize(12)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .lineHeight(18)
              }
              .layoutWeight(1)
              .height(76)
              .alignItems(HorizontalAlign.Start)
              
              Image(article.imageUrl)
                .width(100)
                .height(76)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .margin({ left: 16 })
            }
            .width('90%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .margin({ top: 8, bottom: 8 }) // 恢复垂直间距，靠 Column 默认居中配合 90% 宽度实现左右留白
            .borderRadius(16) // 添加圆角
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]] // 和 Ding 中的 Drink 卡片保持一致的浅蓝色渐变
            })
            .shadow({ radius: 8, color: '#4D219EBC', offsetY: 4 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/home/ArticleDetailPage',
                params: {
                  article: article
                }
              })
            })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 24, topRight: 24 })
        .padding({ bottom: 120 }) // 给底部 TabBar 留出足够的空间
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 整个 Scroll 的底色
    .scrollBar(BarState.Off)
  }
}
