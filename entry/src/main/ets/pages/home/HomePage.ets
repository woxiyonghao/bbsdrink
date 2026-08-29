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
  
  @State todayActivityCount: number = 0;
  @State todayActivityDuration: number = 0;

  private currentDate: string = '';

  @Prop @Watch('onTabChange') currentTabIndex: number = 0;

  onTabChange() {
    if (this.currentTabIndex === 0) {
      this.initData();
    }
  }

  onPageShow() {
    if (this.userId > 0) {
      RdbHelper.queryTodayWaterTotal(this.userId).then(total => {
        this.todayDrank = total;
      });
      RdbHelper.queryTodayActivityCount(this.userId).then(count => {
        this.todayActivityCount = count;
      });
      RdbHelper.queryTodayActivityDuration(this.userId).then(duration => {
        this.todayActivityDuration = duration;
      });
    }
  }

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
      this.todayActivityCount = await RdbHelper.queryTodayActivityCount(this.userId);
      this.todayActivityDuration = await RdbHelper.queryTodayActivityDuration(this.userId);
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

  @Builder ExerciseRingsCard() {
    Row() {
      // 3 rings stack
      Stack() {
        // Outer (Move / Calories)
        Progress({ value: this.todayActivityDuration * 5, total: 200, type: ProgressType.Ring })
          .width(140).height(140)
          .color('#07C160').backgroundColor('rgba(7, 193, 96, 0.15)')
          .style({ strokeWidth: 14 })
          .animation({ duration: 800, curve: Curve.FastOutSlowIn })
        
        // Middle (Exercise / Duration)
        Progress({ value: this.todayActivityDuration, total: 30, type: ProgressType.Ring })
          .width(110).height(110)
          .color('#34C759').backgroundColor('rgba(52, 199, 89, 0.15)')
          .style({ strokeWidth: 14 })
          .animation({ duration: 800, curve: Curve.FastOutSlowIn })

        // Inner (Stand / Count)
        Progress({ value: this.todayActivityCount, total: 5, type: ProgressType.Ring })
          .width(80).height(80)
          .color('#30D158').backgroundColor('rgba(48, 209, 88, 0.15)')
          .style({ strokeWidth: 14 })
          .animation({ duration: 800, curve: Curve.FastOutSlowIn })
      }
      .width(140)
      
      // Stats on the right
      Column({ space: 14 }) {
        // Calories
        Column() {
          Text('活动').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
          Row() {
            Text(`${this.todayActivityDuration * 5}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#07C160')
            Text(`/200千卡`).fontSize(12).fontColor('#07C160').margin({ left: 2, bottom: 3 })
          }.alignItems(VerticalAlign.Bottom).margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)

        // Duration
        Column() {
          Text('锻炼').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
          Row() {
            Text(`${this.todayActivityDuration}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#34C759')
            Text(`/30分钟`).fontSize(12).fontColor('#34C759').margin({ left: 2, bottom: 3 })
          }.alignItems(VerticalAlign.Bottom).margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)

        // Count
        Column() {
          Text('运动次数').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
          Row() {
            Text(`${this.todayActivityCount}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#30D158')
            Text(`/5次`).fontSize(12).fontColor('#30D158').margin({ left: 2, bottom: 3 })
          }.alignItems(VerticalAlign.Bottom).margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)
      }
      .margin({ left: 28 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('90%')
    .padding({ left: 20, right: 20, top: 24, bottom: 24 })
    .backgroundColor('#1C1C1E') // Apple Fitness 黑底
    .borderRadius(24)
    .shadow({ radius: 15, color: 'rgba(0, 0, 0, 0.15)', offsetY: 8 })
    .margin({ bottom: 20 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/mine/ActivityRecordPage', params: { isTodayOnly: true } })
    })
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

  @Builder HealthCard(title: string, value: string, unit: string, icon: Resource, bgColor: string = '#FFF', onClickAction?: () => void) {
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
    .onClick(() => { 
      if (onClickAction) {
        onClickAction();
      } else {
        promptAction.showToast({ message: `${title}功能开发中` });
      }
    })
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
            // 内部水位线（根据进度上升）
            Stack({ alignContent: Alignment.Bottom }) {
              Column()
                .width('100%')
                .height(`${Math.min(this.todayDrank / this.dailyGoal, 1) * 100}%`)
                .linearGradient({
                  direction: GradientDirection.Top,
                  colors: [['#8ECAE6', 0.0], ['#219EBC', 1.0]] // 参照 drink 模块渐变色
                })
                .opacity(0.35) // 增加透明度确保上方文字依然清晰可读
                .animation({ duration: 800, curve: Curve.FastOutSlowIn })
            }
            .width(148) // 180 (总宽) - 16*2 (环粗) = 148
            .height(148)
            .borderRadius(74)
            .clip(true)

            Progress({ value: this.todayDrank, total: this.dailyGoal, type: ProgressType.Ring })
              .width(180)
              .height(180)
              .color('#07C160')
              .backgroundColor('#F5F7FA')
              .style({ strokeWidth: 16 })
              .animation({ duration: 800, curve: Curve.FastOutSlowIn })
            
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

        // 3. 运动数据大盘 (Apple Fitness 风格)
        this.ExerciseRingsCard()

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
                // 如果是今天，在外面加一个小圈
                Stack() {
                  if (new Date().getDay() === (index === 6 ? 0 : index + 1)) {
                    Circle()
                      .width(20)
                      .height(20)
                      .fill('transparent')
                      .stroke('#07C160')
                      .strokeWidth(1)
                  }
                  Circle()
                    .width(14)
                    .height(14)
                    .fill(this.weekCheckInStatus[index] ? '#07C160' : '#F0F0F0')
                }.width(20).height(20).margin({ bottom: 8 })

                Text(day)
                  .fontSize(12)
                  .fontWeight(new Date().getDay() === (index === 6 ? 0 : index + 1) ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(new Date().getDay() === (index === 6 ? 0 : index + 1) ? '#07C160' : (this.weekCheckInStatus[index] ? '#333' : '#999'))
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
