import picker from '@ohos.file.picker';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { User } from '../../types';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';
import { THEME_COLOR } from '../../tools/Theme';

@Entry
@Component
export struct LoginPage {
  @State nickname: string = '';
  @State avatarUri: string = '';
  @State gender: number = 2; // 0: 女, 1: 男, 2: 未知
  @State birthday: number = new Date().getTime(); // 默认今天

  @State scaleValue: number = 1;
  @State opacityValue: number = 1;

  private primaryColor: string = THEME_COLOR; // 微信绿

  /**
   * 调起系统相册选择头像
   */
  private async selectAvatar() {
    try {
      let photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new picker.PhotoViewPicker();
      let photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        this.avatarUri = photoSelectResult.photoUris[0];
      }
    } catch (err) {
      console.error('PhotoViewPicker failed', err);
    }
  }

  /**
   * 显示日期选择器，供用户选择生日
   */
  private showDatePicker() {
    DatePickerDialog.show({
      start: new Date("1900-1-1"),
      end: new Date(),
      selected: new Date(this.birthday),
      onAccept: (value: DatePickerResult) => {
        // value 包含 year, month, day
        const date = new Date();
        date.setFullYear(value.year, value.month, value.day);
        this.birthday = date.getTime();
      }
    });
  }

  /**
   * 提交表单并创建用户
   */
  private async onSubmit() {
    if (this.nickname.trim() === '') {
      promptAction.showToast({ message: '请输入专属昵称', bottom: 60 });
      return;
    }
    if (this.gender === 2) {
      promptAction.showToast({ message: '请选择性别', bottom: 60 });
      return;
    }

    // 触发手动转场动画
    animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
      this.scaleValue = 1.2;
      this.opacityValue = 0;
    });

    // 等待动画结束后处理数据并跳转
    setTimeout(async () => {
      const newUser: User = {
        nickname: this.nickname,
        avatar: this.avatarUri,
        gender: this.gender,
        birthday: this.birthday,
        createTime: new Date().getTime()
      };

      // 1. 保存到 SQLite，并获取自增的 ID (起步为 10000)
      const newUserId = await RdbHelper.insertUser(newUser);
      
      if (newUserId > 0) {
        // 2. 将此 ID 存为当前首选项 (记录已登录状态)
        await PreferencesUtil.setCurrentUserId(newUserId);
      }

      // 3. 路由到主应用 Tabs 骨架
      router.replaceUrl({ url: 'pages/tabs/TabsPage' });
    }, 500);
  }

  build() {
    Column() {
      // 顶部留白
      Blank().height(80)

      Text('欢迎来到健康助手')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ bottom: 40 })

      // 头像选择区域
      Column() {
        Image(this.avatarUri ? this.avatarUri : $r('app.media.ic_avatar_placeholder'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#F0F0F0')
          .onClick(() => this.selectAvatar())
        
        Text('点击设置头像')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 12 })
      }.margin({ bottom: 40 })

      // 核心表单区域
      Column({ space: 24 }) {
        // 昵称输入
        Row() {
          Text('* ').fontColor(Color.Red).fontSize(16)
          Text('昵称').width(50).fontSize(16).fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '请输入昵称(最多8字符)', text: this.nickname })
            .maxLength(8)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((val) => this.nickname = val)
        }
        .padding({ bottom: 8 })
        .border({ width: { bottom: 1 }, color: '#EEE' })

        // 性别选择
        Row() {
          Text('* ').fontColor(Color.Red).fontSize(16)
          Text('性别').width(50).fontSize(16).fontWeight(FontWeight.Medium)
          Row({ space: 20 }) {
            // 男生选项
            Row() {
              Image($r('app.media.ic_male'))
                .width(32).height(32)
                .opacity(this.gender === 1 ? 1 : 0.3) // 彩色 Emoji，通过透明度表示选中
                .scale({ x: this.gender === 1 ? 1.1 : 1, y: this.gender === 1 ? 1.1 : 1 })
                .animation({ duration: 200 })
              Text('男生').fontSize(16).margin({ left: 8 })
                .fontColor(this.gender === 1 ? this.primaryColor : '#888888')
            }
            .onClick(() => this.gender = 1)
            
            // 女生选项
            Row() {
              Image($r('app.media.ic_female'))
                .width(32).height(32)
                .opacity(this.gender === 0 ? 1 : 0.3)
                .scale({ x: this.gender === 0 ? 1.1 : 1, y: this.gender === 0 ? 1.1 : 1 })
                .animation({ duration: 200 })
              Text('女生').fontSize(16).margin({ left: 8 })
                .fontColor(this.gender === 0 ? this.primaryColor : '#888888')
            }
            .onClick(() => this.gender = 0)
          }.layoutWeight(1)
        }
        .padding({ bottom: 8 })
        .border({ width: { bottom: 1 }, color: '#EEE' })

        // 生日选择
        Row() {
          Text('* ').fontColor(Color.Red).fontSize(16)
          Text('生日').width(50).fontSize(16).fontWeight(FontWeight.Medium)
          Text(`${new Date(this.birthday).getFullYear()}-${(new Date(this.birthday).getMonth() + 1).toString().padStart(2, '0')}-${new Date(this.birthday).getDate().toString().padStart(2, '0')}`)
            .layoutWeight(1)
            .fontSize(16)
            .fontColor(this.primaryColor)
            .onClick(() => this.showDatePicker())
        }
        .padding({ bottom: 8 })
        .border({ width: { bottom: 1 }, color: '#EEE' })
      }
      .width('85%')

      Blank()

      // 提交按钮
      Button('开启健康生活')
        .width('85%')
        .height(50)
        .backgroundColor(this.primaryColor)
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .borderRadius(25)
        .margin({ bottom: 50 })
        .onClick(() => this.onSubmit())

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .opacity(this.opacityValue)
  }
}
