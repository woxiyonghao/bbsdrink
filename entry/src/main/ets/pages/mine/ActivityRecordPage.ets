import router from '@ohos.router';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';
import { CheckInRecord, GLOBAL_ACTIVITIES } from '../../types';

class DailyRecordGroup {
  date: string;
  records: CheckInRecord[];
  
  constructor(date: string, records: CheckInRecord[]) {
    this.date = date;
    this.records = records;
  }
}

@Component
struct DailyCardStack {
  @State records: CheckInRecord[] = [];
  
  @State currentIndex: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;

  getStaticIconForType(type: number): Resource {
    switch (type) {
      case 201: return $r('app.media.stretch_static');
      case 202: return $r('app.media.neck_static');
      case 203: return $r('app.media.eye_static');
      case 204: return $r('app.media.fruit_static');
      case 205: return $r('app.media.window_static');
      case 206: return $r('app.media.rest_static');
      case 207: return $r('app.media.stand_static');
      case 208: return $r('app.media.squat_static');
      case 209: return $r('app.media.walk_static');
      case 210: return $r('app.media.run_static');
      default: return $r('app.media.stretch_static');
    }
  }

  getActivityName(type: number): string {
    const activity = GLOBAL_ACTIVITIES.find(a => a.activityType === type);
    return activity ? activity.name : '未知运动';
  }

  formatTime(value: number): string {
    const min = Math.floor(value / 60);
    const sec = value % 60;
    if (min > 0) {
      return `${min}分${sec > 0 ? sec + '秒' : ''}`;
    }
    return `${sec}秒`;
  }

  formatDate(timestamp: number): string {
    const d = new Date(timestamp);
    const HH = String(d.getHours()).padStart(2, '0');
    const MM = String(d.getMinutes()).padStart(2, '0');
    const SS = String(d.getSeconds()).padStart(2, '0');
    return `${HH}:${MM}:${SS}`; // 日期已经在外面了，这里可以只显示时间，也可以显示全，按需求这里显示全
  }

  getActivityColors(type: number): [string, string] {
    const activity = GLOBAL_ACTIVITIES.find(a => a.activityType === type);
    return activity ? [activity.color1, activity.color2] : ['#A8E063', '#56AB2F'];
  }

  getCardScale(index: number): number {
    let relIndex = index - this.currentIndex;
    if (relIndex <= 0) return 1;
    let progress = Math.min(Math.abs(this.offsetX) / 150, 1);
    if (relIndex === 1) return 0.95 + 0.05 * progress;
    if (relIndex === 2) return 0.90 + 0.05 * progress;
    if (relIndex === 3) return 0.85 + 0.05 * progress;
    return 0;
  }

  getCardTranslateY(index: number): number {
    let relIndex = index - this.currentIndex;
    if (relIndex <= 0) return this.offsetY;
    let progress = Math.min(Math.abs(this.offsetX) / 150, 1);
    if (relIndex === 1) return 20 - 20 * progress;
    if (relIndex === 2) return 40 - 20 * progress;
    if (relIndex === 3) return 60 - 20 * progress;
    return 0;
  }

  getCardRotation(index: number): number {
    let relIndex = index - this.currentIndex;
    if (relIndex <= 0) return this.offsetX / 20;
    let progress = Math.min(Math.abs(this.offsetX) / 150, 1);
    if (relIndex === 1) return -8 * (1 - progress);
    if (relIndex === 2) return 8 - 16 * progress;
    if (relIndex === 3) return -8 + 16 * progress;
    return 0;
  }

  @Builder CardItem(record: CheckInRecord, index: number) {
    if (index - this.currentIndex >= 0 && index - this.currentIndex < 4) {
      Column() {
        // 顶部图片（第一帧）带有对应渐变背景
        Stack() {
          Image(this.getStaticIconForType(record.type))
            .width('80%')
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .aspectRatio(1)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [this.getActivityColors(record.type)[0], 0.0],
            [this.getActivityColors(record.type)[1], 1.0]
          ]
        })
        .borderRadius({ topLeft: 24, topRight: 24 })
        
        // 下方信息
        Column() {
          Text(this.getActivityName(record.type))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 20 })

          Text(`运动时长: ${this.formatTime(record.value)}`)
            .fontSize(15)
            .fontColor('#666666')
            .margin({ top: 10 })

          Text(`完成时间: ${this.formatDate(record.timestamp)}`)
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 6, bottom: 25 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 25, right: 25 })
      }
      .width('85%')
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.1)', offsetY: 8 })
      .zIndex(100 - (index - this.currentIndex))
      .scale({ x: this.getCardScale(index), y: this.getCardScale(index) })
      .translate({ 
        x: (index - this.currentIndex) === 0 ? this.offsetX : 0, 
        y: this.getCardTranslateY(index)
      })
      .rotate({ z: 1, angle: this.getCardRotation(index) })
      .gesture(
        PanGesture()
          .onActionUpdate((event: GestureEvent) => {
            if (index === this.currentIndex) {
              this.offsetX = event.offsetX;
              this.offsetY = event.offsetY;
            }
          })
          .onActionEnd((event: GestureEvent) => {
            if (index === this.currentIndex) {
              if (Math.abs(this.offsetX) > 120) {
                // 飞出屏幕并切换下一张
                let sign = this.offsetX > 0 ? 1 : -1;
                animateTo({ duration: 300, curve: Curve.EaseOut, onFinish: () => {
                  this.currentIndex++;
                  this.offsetX = 0;
                  this.offsetY = 0;
                }}, () => {
                  this.offsetX = sign * 600;
                  this.offsetY = this.offsetY + (event.offsetY > 0 ? 100 : -100);
                });
              } else {
                // 弹回原位
                animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
                  this.offsetX = 0;
                  this.offsetY = 0;
                });
              }
            }
          })
      )
    }
  }

  build() {
    if (this.currentIndex >= this.records.length) {
      Column() {
        Text('当天记录已全部看完').fontSize(14).fontColor('#999999')
      }.width('100%').height(300).justifyContent(FlexAlign.Center)
    } else {
      Stack({ alignContent: Alignment.Top }) {
        ForEach(this.records, (record: CheckInRecord, index: number) => {
          this.CardItem(record, index)
        })
      }
      .width('100%')
      .height(480) // 给予固定高度，防止被列表截断
      .padding({ top: 10, bottom: 40 })
    }
  }
}

@Entry
@Component
export struct ActivityRecordPage {
  @State groups: DailyRecordGroup[] = [];
  @State isLoading: boolean = true;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = true;
  @State currentEndTime: number = 0;
  @State isTodayOnly: boolean = false;
  private userId: number = -1;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['isTodayOnly']) {
      this.isTodayOnly = params['isTodayOnly'] as boolean;
    }
    
    this.userId = await PreferencesUtil.getCurrentUserId();
    if (this.userId > 0) {
      const now = new Date();
      now.setHours(23, 59, 59, 999);
      this.currentEndTime = now.getTime();
      await this.loadMoreRecords(true);
    }
    this.isLoading = false;
  }

  async loadMoreRecords(isRefresh: boolean = false) {
    if (this.userId <= 0) return;
    if (!this.hasMore && !isRefresh) return;
    if (this.isLoadingMore && !isRefresh) return;

    if (isRefresh) {
      const now = new Date();
      now.setHours(23, 59, 59, 999);
      this.currentEndTime = now.getTime();
      this.groups = [];
      this.hasMore = true;
    } else {
      this.isLoadingMore = true;
    }

    // 每次查询 7 天的数据，如果是“今日运动”则只查询当天
    let start = this.currentEndTime - 7 * 24 * 60 * 60 * 1000 + 1;
    if (this.isTodayOnly) {
      const d = new Date(this.currentEndTime);
      d.setHours(0, 0, 0, 0);
      start = d.getTime();
      this.hasMore = false; // 今日只查一次
    }
    
    const records = await RdbHelper.queryActivityRecordsByRange(this.userId, start, this.currentEndTime);

    if (records.length > 0) {
      let tempGroups = new Map<string, CheckInRecord[]>();
      for (let r of records) {
        const dateStr = this.formatDateOnly(r.timestamp);
        if (!tempGroups.has(dateStr)) {
          tempGroups.set(dateStr, []);
        }
        tempGroups.get(dateStr)!.push(r);
      }

      let newGroups: DailyRecordGroup[] = [];
      tempGroups.forEach((recs, dateStr) => {
        newGroups.push(new DailyRecordGroup(dateStr, recs));
      });

      // 合并到已有的分组
      if (!isRefresh && this.groups.length > 0 && newGroups.length > 0) {
        const lastGroup = this.groups[this.groups.length - 1];
        if (lastGroup.date === newGroups[0].date) {
          lastGroup.records.push(...newGroups[0].records);
          newGroups.shift();
        }
      }
      this.groups.push(...newGroups);
    }

    this.currentEndTime = start - 1;
    const oldestTime = await RdbHelper.queryOldestActivityRecordTime(this.userId);
    if (oldestTime === 0 || this.currentEndTime < oldestTime) {
      this.hasMore = false;
    }

    this.isLoadingMore = false;
  }

  formatDateOnly(timestamp: number): string {
    const d = new Date(timestamp);
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
  }

  @Builder itemHead(dateStr: string) {
    Row() {
      Text(dateStr)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .backgroundColor('#F5F7FA')
        .width('100%')
        .padding({ left: 24, top: 16, bottom: 16 })
    }
    .width('100%')
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
        
        Text(this.isTodayOnly ? '今日运动' : '运动记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, top: 40, bottom: 20 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .zIndex(200)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.groups.length === 0) {
        Column() {
          Image($r('app.media.run_empty'))
            .width('60%')
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
            .borderRadius(1000)
            .clip(true)
            
          Text(this.isTodayOnly ? '今天还没有开始运动喔。' : '暂无运动记录喔。')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 30, bottom: 50 })

          Button('去运动')
            .width(200)
            .height(50)
            .backgroundColor('#07C160') // 微信淡绿色
            .fontColor(Color.White)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .type(ButtonType.Capsule)
            .onClick(() => {
              router.pushUrl({ url: 'pages/run/RunPage' });
            })
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 40 })
      } else {
        List() {
          ForEach(this.groups, (group: DailyRecordGroup) => {
            ListItemGroup({ header: this.itemHead(group.date) }) {
              ListItem() {
                DailyCardStack({ records: group.records })
              }
            }
          })

          if (!this.isTodayOnly) {
            ListItem() {
              Row() {
                if (this.isLoadingMore) {
                  LoadingProgress().width(24).height(24).margin({ right: 8 })
                  Text('正在加载前一周数据...').fontSize(14).fontColor('#999999')
                } else if (!this.hasMore) {
                  Text('没有更多数据了~').fontSize(14).fontColor('#999999')
                } else {
                  Text('上拉或点击加载前一周记录').fontSize(14).fontColor('#999999')
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ top: 20, bottom: 40 })
              .onClick(() => {
                if (!this.isLoadingMore && this.hasMore) {
                  this.loadMoreRecords();
                }
              })
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .onReachEnd(() => {
          if (!this.isLoadingMore && this.hasMore) {
            this.loadMoreRecords();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
