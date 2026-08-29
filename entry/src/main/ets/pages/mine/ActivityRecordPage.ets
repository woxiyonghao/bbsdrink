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

@Entry
@Component
export struct ActivityRecordPage {
  @State groups: DailyRecordGroup[] = [];
  @State isLoading: boolean = true;
  @State isLoadingMore: boolean = false;
  @State hasMore: boolean = true;
  @State currentEndTime: number = 0;
  private userId: number = -1;

  async aboutToAppear() {
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

    if (isRefresh) {
      const now = new Date();
      now.setHours(23, 59, 59, 999);
      this.currentEndTime = now.getTime();
      this.groups = [];
      this.hasMore = true;
    } else {
      this.isLoadingMore = true;
    }

    // 每次查询 7 天的数据
    const start = this.currentEndTime - 7 * 24 * 60 * 60 * 1000 + 1;
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

    // 更新查询结束时间
    this.currentEndTime = start - 1;
    
    // 如果查询到了早于 2024 年，则认为没有更多数据了
    if (this.currentEndTime < new Date('2024-01-01').getTime()) {
      this.hasMore = false;
    }

    this.isLoadingMore = false;
  }

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

  getActivityColors(type: number): [string, string] {
    const activity = GLOBAL_ACTIVITIES.find(a => a.activityType === type);
    return activity ? [activity.color1, activity.color2] : ['#A8E063', '#56AB2F'];
  }

  formatTime(value: number): string {
    const min = Math.floor(value / 60);
    const sec = value % 60;
    if (min > 0) {
      return `${min}分${sec > 0 ? sec + '秒' : ''}`;
    }
    return `${sec}秒`;
  }

  formatDateOnly(timestamp: number): string {
    const d = new Date(timestamp);
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
  }

  formatDateTime(timestamp: number): string {
    const d = new Date(timestamp);
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    const HH = String(d.getHours()).padStart(2, '0');
    const MM = String(d.getMinutes()).padStart(2, '0');
    const SS = String(d.getSeconds()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd} ${HH}:${MM}:${SS}`;
  }

  @Builder itemHead(dateStr: string) {
    Row() {
      Text(dateStr)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .backgroundColor('#F5F7FA')
        .width('100%')
        .padding({ left: 24, top: 16, bottom: 8 })
    }
    .width('100%')
  }

  @Builder CardItem(record: CheckInRecord) {
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

        Text(`完成时间: ${this.formatDateTime(record.timestamp)}`)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ top: 6, bottom: 25 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 25, right: 25 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 15, color: 'rgba(0,0,0,0.05)', offsetY: 6 })
    .margin({ top: 8, bottom: 16 })
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
        
        Text('运动记录')
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
      } else {
        List() {
          ForEach(this.groups, (group: DailyRecordGroup) => {
            ListItemGroup({ header: this.itemHead(group.date) }) {
              ForEach(group.records, (record: CheckInRecord) => {
                ListItem() {
                  this.CardItem(record)
                }
                .padding({ left: 20, right: 20 })
              })
            }
          })

          ListItem() {
            Row() {
              if (this.isLoadingMore) {
                LoadingProgress().width(24).height(24).margin({ right: 8 })
                Text('正在加载前一周数据...').fontSize(14).fontColor('#999999')
              } else if (!this.hasMore) {
                Text('没有更多记录了').fontSize(14).fontColor('#999999')
              } else {
                Text('上拉加载前一周记录').fontSize(14).fontColor('#999999')
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 20, bottom: 40 })
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
