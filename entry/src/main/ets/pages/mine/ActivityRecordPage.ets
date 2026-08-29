import router from '@ohos.router';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';
import { CheckInRecord, GLOBAL_ACTIVITIES } from '../../types';

@Entry
@Component
export struct ActivityRecordPage {
  @State records: CheckInRecord[] = [];
  @State isLoading: boolean = true;

  @State currentIndex: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;

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
    if (relIndex === 1) return 15 - 15 * progress;
    if (relIndex === 2) return 30 - 15 * progress;
    if (relIndex === 3) return 45 - 15 * progress;
    return 0;
  }

  getCardRotation(index: number): number {
    let relIndex = index - this.currentIndex;
    // 顶层卡片随手指滑动旋转
    if (relIndex <= 0) return this.offsetX / 20;
    
    let progress = Math.min(Math.abs(this.offsetX) / 150, 1);
    
    // 第2张：初始向左倾斜 -4 度，滑动时逐渐回正到 0 度
    if (relIndex === 1) return -4 * (1 - progress);
    
    // 第3张：初始向右倾斜 +4 度，滑动时逐渐转到 -4 度（成为新的第2张）
    if (relIndex === 2) return 4 - 8 * progress;
    
    // 第4张：初始向左倾斜 -4 度，滑动时逐渐转到 +4 度（成为新的第3张）
    if (relIndex === 3) return -4 + 8 * progress;
    
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
      .zIndex(200) // Ensure nav is above cards

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.records.length === 0 || this.currentIndex >= this.records.length) {
        Column() {
          Text('暂无更多记录').fontSize(16).fontColor('#999999').margin({ top: 16 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Stack({ alignContent: Alignment.Center }) {
          ForEach(this.records, (record: CheckInRecord, index: number) => {
            this.CardItem(record, index)
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ bottom: 40 }) // Give some space at the bottom for the stack translation
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
