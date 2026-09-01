import picker from '@ohos.file.picker';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { User } from '../../types';
import RdbHelper from '../../store/RdbHelper';
import PreferencesUtil from '../../store/PreferencesUtil';
import { THEME_COLOR } from '../../tools/Theme';

import common from '@ohos.app.ability.common';

@CustomDialog
export struct PrivacyDialog {
  controller: CustomDialogController
  cancel: () => void = () => {}
  confirm: () => void = () => {}

  build() {
    Column() {
      Text('服务协议和隐私政策')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 24, bottom: 12 })
      
      Scroll() {
        Text() {
          Span('欢迎使用“该喝水啦亲”！\n\n')
          Span('我们非常重视您的隐私保护和个人信息安全。在您使用本应用前，请认真阅读')
          Span('《用户协议》')
            .fontColor(THEME_COLOR)
            .onClick(() => {
              router.pushUrl({ url: 'pages/login/PrivacyPage', params: { type: 'user' } })
            })
          Span('和')
          Span('《隐私政策》')
            .fontColor(THEME_COLOR)
            .onClick(() => {
              router.pushUrl({ url: 'pages/login/PrivacyPage', params: { type: 'privacy' } })
            })
          Span('。\n\n')
          Span('本应用为纯本地应用，您的所有健康数据（包含头像、昵称、打卡记录等）均加密存储在您的本地设备上。我们不会将您的个人数据上传至任何云端服务器，也不会与任何第三方共享。\n\n')
          Span('如果您同意上述协议内容，请点击“同意”开始使用。')
        }
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(24)
      }
      .height(180)
      .margin({ left: 24, right: 24, bottom: 20 })

      Divider().color('rgba(0, 0, 0, 0.05)')

      Row() {
        Text('不同意')
          .fontSize(16)
          .fontColor('#888888')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller.close()
            this.cancel()
          })
        
        Divider().vertical(true).height('100%').color('rgba(0, 0, 0, 0.05)')
        
        Text('同意')
          .fontSize(16)
          .fontColor(THEME_COLOR)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller.close()
            this.confirm()
          })
      }
      .width('100%')
      .height(50)
    }
    .width('85%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}

@Entry
@Component
export struct LoginPage {
  @State nickname: string = '';
  @State avatarUri: string = '';
  @State gender: number = 2; // 0: 女, 1: 男, 2: 未知
  @State birthday: number = new Date(new Date().setFullYear(new Date().getFullYear() - 14)).getTime(); // 默认14年前，限制未成年人
  @State isAgreePrivacy: boolean = false; // 是否同意隐私协议

  @State scaleValue: number = 1;
  @State opacityValue: number = 1;

  @State isLoginMode: boolean = true; // 默认登录模式
  @State existingUsers: User[] = [];

  private primaryColor: string = THEME_COLOR; // 微信绿

  privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      cancel: () => {
        const context = getContext(this) as common.UIAbilityContext;
        context.terminateSelf();
      },
      confirm: async () => {
        await PreferencesUtil.setPrivacyAgreed(true);
        this.isAgreePrivacy = true;
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  })

  async aboutToAppear() {
    const isAgreed = await PreferencesUtil.getPrivacyAgreed();
    if (!isAgreed) {
      this.privacyDialogController.open();
    } else {
      this.isAgreePrivacy = true;
    }

    this.existingUsers = await RdbHelper.queryAllUsers();
    if (this.existingUsers.length === 0) {
      this.isLoginMode = false;
    }
  }

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
    const maxDate = new Date();
    maxDate.setFullYear(maxDate.getFullYear() - 14);

    DatePickerDialog.show({
      start: new Date("1900-1-1"),
      end: maxDate,
      selected: new Date(this.birthday),
      onAccept: (value: DatePickerResult) => {
        const date = new Date();
        date.setFullYear(value.year, value.month, value.day);
        this.birthday = date.getTime();
      }
    });
  }

  /**
   * 登录现有用户
   */
  private async loginExistingUser(user: User) {
    if (!this.isAgreePrivacy) {
      promptAction.showToast({ message: '请先阅读并同意隐私政策和用户协议', bottom: 60 });
      return;
    }

    animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
      this.scaleValue = 1.2;
      this.opacityValue = 0;
    });

    setTimeout(async () => {
      if (user.id) {
        await PreferencesUtil.setCurrentUserId(user.id);
        router.replaceUrl({ url: 'pages/tabs/TabsPage' });
      }
    }, 500);
  }

  /**
   * 提交表单并创建用户
   */
  private async onSubmit() {
    if (!this.isAgreePrivacy) {
      promptAction.showToast({ message: '请先阅读并同意隐私政策和用户协议', bottom: 60 });
      return;
    }

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

      // 1. 保存到 SQLite，并获取自增的 ID
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

      Text(this.isLoginMode ? '欢迎回来，健康助手' : '欢迎来到健康助手')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ bottom: 40 })

      if (this.isLoginMode) {
        // 登录模式：选择现有账号
        Text('请选择账号登录')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })

        List({ space: 15 }) {
          ForEach(this.existingUsers, (user: User) => {
            ListItem() {
              Row() {
                Image(user.avatar ? user.avatar : $r('app.media.ic_avatar_placeholder'))
                  .width(50).height(50).borderRadius(25).objectFit(ImageFit.Cover)
                  .backgroundColor('#F0F0F0')
                Text(user.nickname).fontSize(18).margin({ left: 15 }).layoutWeight(1)
                Button('登录').backgroundColor(this.primaryColor).fontColor(Color.White)
                  .onClick(() => this.loginExistingUser(user))
              }
              .width('85%')
              .padding(15)
              .backgroundColor('#F5F7FA')
              .borderRadius(12)
            }
          }, (user: User) => user.id!.toString())
        }
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .layoutWeight(1)

        Button('创建新账号')
          .width('85%')
          .height(50)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .fontSize(18)
          .borderRadius(25)
          .margin({ top: 20, bottom: 20 })
          .onClick(() => {
            this.isLoginMode = false;
          })

      } else {
        // 注册模式：填写表单
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
                  .opacity(this.gender === 1 ? 1 : 0.3)
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

        if (this.existingUsers.length > 0) {
          Text('返回已有账号登录')
            .fontSize(14)
            .fontColor(this.primaryColor)
            .margin({ bottom: 20 })
            .onClick(() => {
              this.isLoginMode = true;
            })
        }

        // 提交按钮
        Button('开启健康生活')
          .width('85%')
          .height(50)
          .backgroundColor(this.primaryColor)
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .borderRadius(25)
          .margin({ bottom: 10 })
          .onClick(() => this.onSubmit())
      }

      // 隐私政策勾选 (全局，无论是登录还是注册都必须勾选)
      Row() {
        Checkbox({ name: 'privacy', group: 'privacyGroup' })
          .select(this.isAgreePrivacy)
          .onChange((value: boolean) => {
            this.isAgreePrivacy = value
          })
          .selectedColor(this.primaryColor)
          .width(14).height(14)
          .margin({ right: 6 })
        Text() {
          Span('我已阅读并同意')
            .fontColor('#999')
            .fontSize(12)
          Span('《用户协议》')
            .fontColor(this.primaryColor)
            .fontSize(12)
            .onClick(() => {
              router.pushUrl({ url: 'pages/login/PrivacyPage', params: { type: 'user' } })
            })
          Span('与')
            .fontColor('#999')
            .fontSize(12)
          Span('《隐私政策》')
            .fontColor(this.primaryColor)
            .fontSize(12)
            .onClick(() => {
              router.pushUrl({ url: 'pages/login/PrivacyPage', params: { type: 'privacy' } })
            })
        }
      }
      .width('85%')
      .margin({ bottom: 40 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .opacity(this.opacityValue)
  }
}
