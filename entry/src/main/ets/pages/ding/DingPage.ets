import router from '@ohos.router';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import { CheckInRecord } from '../../types';
import promptAction from '@ohos.promptAction';

interface DrinkType {
  id: number;
  name: string;
  icon: Resource;
}

@Entry
@Component
export struct DingPage {
  @State selectedDrink: number = 0; // 默认白开水
  @State selectedVolume: number = 200; // 默认 200ml
  @State customVolumeStr: string = '';

  private drinkTypes: DrinkType[] = [
    { id: 0, name: '白开水', icon: $r('app.media.ic_drink_water') },
    { id: 1, name: '茶', icon: $r('app.media.ic_drink_tea') },
    { id: 2, name: '咖啡', icon: $r('app.media.ic_drink_coffee') },
    { id: 3, name: '牛奶', icon: $r('app.media.ic_drink_milk') },
    { id: 4, name: '果汁', icon: $r('app.media.ic_drink_juice') }
  ];

  private volumeOptions: number[] = [100, 150, 200, 300, 500];

  // 打卡操作
  async punchIn() {
    let finalVolume = this.selectedVolume;
    if (this.selectedVolume === -1) {
      const parsed = parseInt(this.customVolumeStr);
      if (isNaN(parsed) || parsed <= 0) {
        promptAction.showToast({ message: '请输入正确的饮水量' });
        return;
      }
      finalVolume = parsed;
    }

    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId <= 0) {
      promptAction.showToast({ message: '用户未登录' });
      return;
    }

    const record: CheckInRecord = {
      userId: userId,
      type: this.selectedDrink,
      taskId: -1, // 暂不绑定具体任务
      value: finalVolume,
      timestamp: Date.now()
    };

    const res = await RdbHelper.insertRecord(record);
    if (res > 0) {
      promptAction.showToast({ message: `成功打卡 ${finalVolume}ml 💧` });
      router.back(); // 返回首页
    } else {
      promptAction.showToast({ message: '打卡失败' });
    }
  }

  build() {
    Column() {
      // 头部导航栏
      Row() {
        Image($r('app.media.ic_back')).width(28).height(28)
          .onClick(() => { router.back(); })
        Text('喝水打卡').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .margin({ left: 15 })
        Blank()
      }
      .width('100%').height(56).padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')

      // 饮品类型选择区 (横向滑动)
      Text('选择饮品').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        .width('100%').padding({ left: 20, top: 20, bottom: 10 })
      
      Scroll() {
        Row({ space: 15 }) {
          ForEach(this.drinkTypes, (item: DrinkType) => {
            Column() {
              Image(item.icon)
                .width(40).height(40)
                .margin({ bottom: 8 })
                .opacity(this.selectedDrink === item.id ? 1 : 0.4)
              Text(item.name)
                .fontSize(14)
                .fontColor(this.selectedDrink === item.id ? '#07C160' : '#888888')
                .fontWeight(this.selectedDrink === item.id ? FontWeight.Bold : FontWeight.Normal)
            }
            .width(80)
            .height(90)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedDrink === item.id ? '#E6F8EE' : '#F5F7FA') // 选中时背景浅绿
            .borderRadius(15)
            .onClick(() => {
              this.selectedDrink = item.id;
            })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // 饮水量选择区 (网格)
      Text('选择容量 (ml)').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        .width('100%').padding({ left: 20, top: 30, bottom: 10 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.volumeOptions, (vol: number) => {
          Text(vol.toString() + ' ml')
            .width('30%')
            .height(50)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.selectedVolume === vol ? '#07C160' : '#F5F7FA')
            .fontColor(this.selectedVolume === vol ? '#FFFFFF' : '#333333')
            .fontWeight(this.selectedVolume === vol ? FontWeight.Bold : FontWeight.Normal)
            .borderRadius(25)
            .margin({ bottom: 15 })
            .onClick(() => {
              this.selectedVolume = vol;
            })
        })
        
        // 自定义输入框
        TextInput({ placeholder: '自定义', text: this.customVolumeStr })
          .type(InputType.Number)
          .width('30%')
          .height(50)
          .backgroundColor(this.selectedVolume === -1 ? '#07C160' : '#F5F7FA')
          .fontColor(this.selectedVolume === -1 ? '#FFFFFF' : '#333333')
          .borderRadius(25)
          .margin({ bottom: 15 })
          .textAlign(TextAlign.Center)
          .onChange((val) => {
            this.selectedVolume = -1;
            this.customVolumeStr = val;
          })
          .onClick(() => {
            this.selectedVolume = -1;
          })
      }
      .padding({ left: 20, right: 20 })

      Blank()

      // 确认打卡按钮
      Button('滴，打卡')
        .width('85%')
        .height(50)
        .backgroundColor('#07C160')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .borderRadius(25)
        .shadow({ radius: 10, color: '#4D07C160', offsetY: 5 })
        .margin({ bottom: 40 })
        .onClick(() => {
          this.punchIn();
        })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
