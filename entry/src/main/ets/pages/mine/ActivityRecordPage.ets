import router from '@ohos.router';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';
import { CheckInRecord, GLOBAL_ACTIVITIES } from '../../types';

@Entry
@Component
export struct ActivityRecordPage {
  @State records: CheckInRecord[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.records = await RdbHelper.queryActivityRecords(userId);
    }
    this.isLoading = false;
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
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    const HH = String(d.getHours()).padStart(2, '0');
    const MM = String(d.getMinutes()).padStart(2, '0');
    const SS = String(d.getSeconds()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd} ${HH}:${MM}:${SS}`;
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

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.records.length === 0) {
        Column() {
          Text('暂无运动记录').fontSize(16).fontColor('#999999').margin({ top: 16 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Grid() {
          ForEach(this.records, (record: CheckInRecord) => {
            GridItem() {
              Column() {
                // 顶部图片（第一帧）
                Image(this.getStaticIconForType(record.type))
                  .width('100%')
                  .aspectRatio(1)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('rgba(7, 193, 96, 0.05)')
                  .borderRadius({ topLeft: 12, topRight: 12 })
                  .padding(10)
                
                // 下方信息
                Column() {
                  Text(this.getActivityName(record.type))
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ top: 8 })

                  Text(`时长: ${this.formatTime(record.value)}`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ top: 6 })

                  Text(this.formatDate(record.timestamp))
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ top: 4, bottom: 12 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 12, right: 12 })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(15)
        .rowsGap(15)
        .padding({ left: 15, right: 15, top: 15, bottom: 20 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
