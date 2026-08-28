import promptAction from '@ohos.promptAction';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';

class DrinkOption {
  type: number;
  name: string;
  icon: Resource;
  
  constructor(type: number, name: string, icon: Resource) {
    this.type = type;
    this.name = name;
    this.icon = icon;
  }
}

@CustomDialog
export struct DrinkDialog {
  controller: CustomDialogController;
  @State selectedDrink: number = 0; // 0水, 1咖啡, 2茶, 3牛奶, 5果汁
  @State selectedAmount: number = 250;
  private onConfirm?: () => void;

  readonly DRINKS: DrinkOption[] = [
    new DrinkOption(0, '白开水', $r('app.media.ic_drink_water')),
    new DrinkOption(1, '咖啡', $r('app.media.ic_drink_coffee')),
    new DrinkOption(2, '茶', $r('app.media.ic_drink_tea')),
    new DrinkOption(3, '牛奶', $r('app.media.ic_drink_milk')),
    new DrinkOption(5, '果汁', $r('app.media.ic_drink_juice'))
  ];

  readonly AMOUNTS: number[] = [150, 250, 350, 500, 750];

  async saveRecord() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      await RdbHelper.insertRecord({
        userId: userId,
        type: 0, // 对于水进度条统计，这里统一存为 0 (代表补水)，实际业务中可以用扩展字段存具体类型，为了不改动老代码，先用 0
        value: this.selectedAmount,
        timestamp: new Date().getTime()
      });
      promptAction.showToast({ message: `成功记录 ${this.selectedAmount}ml ${this.DRINKS.find(d => d.type === this.selectedDrink)?.name}！` });
      if (this.onConfirm) {
        this.onConfirm();
      }
      this.controller.close();
    } else {
      promptAction.showToast({ message: '请先登录' });
    }
  }

  build() {
    Column() {
      Text('记录水分补充')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ bottom: 24, top: 10 })

      // 饮品类型选择
      Text('选择饮品').fontSize(14).fontColor('#666').width('100%').margin({ bottom: 12 })
      Row({ space: 12 }) {
        ForEach(this.DRINKS, (item: DrinkOption) => {
          Column() {
            Row() {
              Image(item.icon)
                .width(28).height(28)
                .fillColor(this.selectedDrink === item.type ? '#FFFFFF' : '#666666')
            }
            .width(50).height(50)
            .backgroundColor(this.selectedDrink === item.type ? '#07C160' : '#F5F7FA')
            .borderRadius(25)
            .justifyContent(FlexAlign.Center)
            
            Text(item.name)
              .fontSize(12)
              .fontColor(this.selectedDrink === item.type ? '#07C160' : '#999')
              .margin({ top: 8 })
          }
          .onClick(() => {
            this.selectedDrink = item.type;
          })
        })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 32 })

      // 容量选择
      Text('选择容量 (ml)').fontSize(14).fontColor('#666').width('100%').margin({ bottom: 12 })
      Row({ space: 10 }) {
        ForEach(this.AMOUNTS, (amt: number) => {
          Text(`${amt}`)
            .fontSize(14)
            .fontWeight(this.selectedAmount === amt ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedAmount === amt ? '#07C160' : '#666')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.selectedAmount === amt ? 'rgba(7, 193, 96, 0.1)' : '#F5F7FA')
            .border({ width: 1, color: this.selectedAmount === amt ? '#07C160' : 'transparent', radius: 16 })
            .onClick(() => {
              this.selectedAmount = amt;
            })
        })
      }.width('100%').margin({ bottom: 40 })

      // 提交按钮
      Button('咕噜咕噜 吨吨吨！')
        .width('100%')
        .height(48)
        .backgroundColor('#07C160')
        .fontColor('#FFF')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.saveRecord();
        })
    }
    .width('90%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
  }
}
