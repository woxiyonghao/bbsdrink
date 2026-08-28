import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { User } from '../../types';

import { HealthArticle, HEALTH_ARTICLES } from '../../store/MockArticles';

const DAILY_QUOTES = [
  "今天也要好好照顾自己哦 ✨",
  "流水不腐，多喝水能保持年轻 💧",
  "每一次起身，都是对身体的温柔 🚶",
  "健康是一场马拉松，享受当下的每一步 🏃",
  "好身体是最高级的奢侈品 🌿"
];

@Entry
@Component
export struct HomePage {
  @State userId: number = -1;
  @State nickname: string = '朋友';
  @State todayDrank: number = 0;
  @State dailyGoal: number = 2000; // 默认2000ml
  @State hasCheckedIn: boolean = false;
  @State currentArticlePage: number = 0;
  @State dailyQuote: string = '';
  @State lastWaterTime: number = 0;
  @State waterReminderMsg: string = '正在加载水分数据...';
  @State waterReminderColor: string = '#07C160';
  @State waterReminderBg: string = 'rgba(7, 193, 96, 0.1)';
  @State weekCheckInStatus: boolean[] = [false, false, false, false, false, false, false];
  @State weekCheckInCount: number = 0;
  
  private currentDate: string = '';

  aboutToAppear() {
    const date = new Date();
    this.currentDate = `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
    this.dailyQuote = DAILY_QUOTES[Math.floor(Math.random() * DAILY_QUOTES.length)];
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
      this.hasCheckedIn = await RdbHelper.hasCheckedInToday(this.userId);
      this.lastWaterTime = await RdbHelper.queryLatestWaterRecordTime(this.userId);
      this.updateWaterReminder();
      await this.loadWeeklyTrend();
    }
  }

  updateWaterReminder() {
    if (this.lastWaterTime === 0) {
      this.waterReminderMsg = '新的一天，快喝下第一杯水吧！';
      this.waterReminderColor = '#FF5C5C'; // 红色
      this.waterReminderBg = 'rgba(255, 92, 92, 0.1)';
      return;
    }
    const now = new Date().getTime();
    const diffMins = Math.floor((now - this.lastWaterTime) / 1000 / 60);
    const interval = 60; // 建议 60 分钟喝一次
    if (diffMins >= interval) {
      this.waterReminderMsg = `已经 ${diffMins} 分钟没喝水了，快补充水分！`;
      this.waterReminderColor = '#FF5C5C'; // 淡红系
      this.waterReminderBg = 'rgba(255, 92, 92, 0.1)';
    } else {
      const wait = interval - diffMins;
      this.waterReminderMsg = `已喝水，建议 ${wait} 分钟后再次补水`;
      this.waterReminderColor = '#07C160'; // 绿色
      this.waterReminderBg = 'rgba(7, 193, 96, 0.1)';
    }
  }

  async loadWeeklyTrend() {
    const timestamps = await RdbHelper.queryAllCheckInTimestamps(this.userId);
    const now = new Date();
    const currentDayOfWeek = now.getDay() === 0 ? 7 : now.getDay();
    now.setHours(0,0,0,0);
    const mondayTime = now.getTime() - (currentDayOfWeek - 1) * 24 * 60 * 60 * 1000;
    
    let status = [false, false, false, false, false, false, false];
    let count = 0;
    for (const ts of timestamps) {
      if (ts >= mondayTime) {
        const d = new Date(ts);
        const dayIdx = d.getDay() === 0 ? 6 : d.getDay() - 1;
        if (dayIdx >= 0 && dayIdx < 7 && !status[dayIdx]) {
          status[dayIdx] = true;
          count++;
        }
      }
    }
    if (this.hasCheckedIn && !status[currentDayOfWeek - 1]) {
      status[currentDayOfWeek - 1] = true;
      count++;
    }
    this.weekCheckInStatus = status;
    this.weekCheckInCount = count;
  }

  async addWater(amount: number) {
    if (this.userId <= 0) return;
    // UI 动画
    animateTo({ duration: 500, curve: Curve.Friction }, () => {
      this.todayDrank += amount;
    });
    // 入库
    const now = new Date().getTime();
    await RdbHelper.insertRecord({
      userId: this.userId,
      type: 0, // 0 表示喝水
      value: amount,
      timestamp: now
    });
    this.lastWaterTime = now;
    this.updateWaterReminder();
  }

  @Builder QuickAddWaterBtn(label: string, amount: number) {
    Button(label)
      .width(86)
      .height(36)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor('#07C160')
      .backgroundColor('rgba(7, 193, 96, 0.1)')
      .borderRadius(18)
      .padding(0) // 移除内边距防止文字被截断
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
            Text(`您好，${this.nickname}`)
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
          
          // 海报分享 & 成就墙 按钮
          Row({ space: 14 }) {
            // 成就墙按钮
            Row() {
              Image($r('app.media.ic_trophy'))
                .width(24).height(24)
                .fillColor('#333333')
            }
            .width(42).height(42)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#F5F7FA')
            .borderRadius(21)
            .onClick(() => {
              promptAction.showToast({ message: '健康成就墙功能即将开放！' });
            })

            // 分享海报按钮
            Row() {
              Image($r('app.media.ic_camera'))
                .width(24).height(24)
                .fillColor('#333333')
            }
            .width(42).height(42)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#F5F7FA')
            .borderRadius(21)
            .onClick(() => {
              promptAction.showToast({ message: '每日健康海报功能即将开放！' });
            })
          }
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 10 })

        // 每日健康金句
        Row() {
          Text(this.dailyQuote)
            .fontSize(14)
            .fontColor('#999999')
            .fontStyle(FontStyle.Italic)
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 20 })
        .justifyContent(FlexAlign.Start)

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
          .margin({ bottom: 24 })

          Divider().color('#F5F5F5').width('80%').margin({ bottom: 16 })

          // 智能提醒状态
          Row() {
            Image($r('app.media.ic_ding_filled')).width(14).height(14).fillColor(this.waterReminderColor).margin({ right: 6 })
            Text(this.waterReminderMsg)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.waterReminderColor)
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.waterReminderBg)
          .borderRadius(12)
        }
        .width('90%')
        .padding({ top: 32, bottom: 24 })
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
        .margin({ bottom: 20 })

        // 3.1 微型周报趋势图 (Weekly Trend)
        Column() {
          Row() {
            Text('本周签到情况').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333')
            Blank()
            Text(`${this.weekCheckInCount}/7 天`).fontSize(12).fontColor('#07C160')
          }.width('100%').margin({ bottom: 16 })
          
          Row() {
            ForEach(['一', '二', '三', '四', '五', '六', '日'], (day: string, index: number) => {
              Column() {
                Circle()
                  .width(14)
                  .height(14)
                  .fill(this.weekCheckInStatus[index] ? '#07C160' : '#F0F0F0')
                  .margin({ bottom: 8 })
                Text(day).fontSize(12).fontColor(this.weekCheckInStatus[index] ? '#333' : '#999')
              }.layoutWeight(1)
            })
          }.width('100%')
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .margin({ bottom: 32 })
        .shadow({ radius: 15, color: 'rgba(0, 0, 0, 0.03)', offsetY: 6 })

        // 4. 图文并茂的健康知识栏目
        Column() {
          Row() {
            Text('健康小贴士')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Blank()
            Row() {
              Image($r('app.media.ic_refresh')).width(14).height(14).fillColor('#999999').margin({ right: 4 })
              Text('换一批')
                .fontSize(13)
                .fontColor('#999999')
            }
            .onClick(() => {
              if ((this.currentArticlePage + 1) * 10 >= HEALTH_ARTICLES.length) {
                this.currentArticlePage = 0;
              } else {
                this.currentArticlePage++;
              }
            })
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 16, top: 20 })
          
          ForEach(HEALTH_ARTICLES.slice(this.currentArticlePage * 10, (this.currentArticlePage + 1) * 10), (article: HealthArticle) => {
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
