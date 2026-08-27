import router from '@ohos.router';
import { User } from '../../types';
import PreferencesUtil from '../../store/PreferencesUtil';
import RdbHelper from '../../store/RdbHelper';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';

@CustomDialog
struct NicknameDialog {
  controller: CustomDialogController;
  @Link nickname: string;
  onSave: (newName: string) => void = () => {};
  
  @State tempName: string = '';

  aboutToAppear() {
    this.tempName = this.nickname;
  }

  build() {
    Column() {
      Text('修改昵称').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })
      
      TextInput({ text: this.tempName })
        .onChange((val) => { this.tempName = val })
        .maxLength(8)
        .width('90%')
        .backgroundColor('#F5F7FA')
        
      Row() {
        Button('取消').backgroundColor(Color.Transparent).fontColor('#888888').layoutWeight(1)
          .onClick(() => { this.controller.close(); })
          
        Button('保存').backgroundColor(Color.Transparent).fontColor('#07C160').layoutWeight(1)
          .onClick(() => {
            if (this.tempName.trim().length === 0) {
              promptAction.showToast({ message: '昵称不能为空' });
              return;
            }
            this.nickname = this.tempName;
            this.onSave(this.nickname);
            this.controller.close();
          })
      }.width('100%').margin({ top: 20, bottom: 10 })
    }
    .width('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
  }
}

@Entry
@Component
export struct SettingPage {
  @State currentUser: User | null = null;
  @State currentNickname: string = '';

  dialogController: CustomDialogController = new CustomDialogController({
    builder: NicknameDialog({
      nickname: $currentNickname,
      onSave: (newName) => { this.saveNickname(newName); }
    }),
    alignment: DialogAlignment.Center
  })

  async aboutToAppear() {
    const userId = await PreferencesUtil.getCurrentUserId();
    if (userId > 0) {
      this.currentUser = await RdbHelper.queryUserById(userId);
      if (this.currentUser) {
        this.currentNickname = this.currentUser.nickname;
      }
    }
  }

  // 保存昵称
  async saveNickname(newName: string) {
    if (this.currentUser) {
      this.currentUser.nickname = newName;
      await RdbHelper.updateUser(this.currentUser);
      this.currentNickname = newName;
      // 强制刷新整个对象引用 (绕过 arkts-no-spread)
      this.currentUser = {
        id: this.currentUser.id,
        nickname: this.currentUser.nickname,
        avatar: this.currentUser.avatar,
        gender: this.currentUser.gender,
        birthday: this.currentUser.birthday,
        createTime: this.currentUser.createTime
      };
      promptAction.showToast({ message: '昵称修改成功' });
    }
  }

  // 格式化时间戳为 YYYY-MM-DD
  formatDate(timestamp: number): string {
    const d = new Date(timestamp);
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 格式化性别
  formatGender(gender: number): string {
    if (gender === 1) return '男生';
    if (gender === 0) return '女生';
    return '未知';
  }

  // 处理头像点击
  handleAvatarClick() {
    promptAction.showActionMenu({
      title: '修改头像',
      buttons: [
        { text: '拍照', color: '#333333' },
        { text: '从相册选择', color: '#333333' }
      ]
    }).then(async (data: promptAction.ActionMenuSuccessResponse) => {
      if (data.index === 1) { // 从相册选择
        const photoPicker = new picker.PhotoViewPicker();
        try {
          let PhotoSelectResult = await photoPicker.select({
            MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
            maxSelectNumber: 1
          });
          if (PhotoSelectResult.photoUris.length > 0 && this.currentUser) {
            this.currentUser.avatar = PhotoSelectResult.photoUris[0];
            await RdbHelper.updateUser(this.currentUser);
            // 强制刷新整个对象引用 (绕过 arkts-no-spread)
            this.currentUser = {
              id: this.currentUser.id,
              nickname: this.currentUser.nickname,
              avatar: this.currentUser.avatar,
              gender: this.currentUser.gender,
              birthday: this.currentUser.birthday,
              createTime: this.currentUser.createTime
            };
            promptAction.showToast({ message: '头像修改成功' });
          }
        } catch (err) {
          console.error('PhotoPicker failed', err);
        }
      } else if (data.index === 0) {
        promptAction.showToast({ message: '拍照功能待开发' });
      }
    }).catch((err: Error) => {
      console.info('ActionMenu canceled', err);
    })
  }

  build() {
    Column() {
      // 自定义头部导航栏
      Row() {
        Image($r('app.media.ic_back')).width(28).height(28)
          .onClick(() => { router.back(); })
        Text('个人信息').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .margin({ left: 15 })
        Blank()
      }
      .width('100%').height(56).padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')

      // 内容列表区
      if (this.currentUser) {
        Column() {
          // 1. 头像行
          Row() {
            Text('头像').fontSize(16).fontColor('#333333').layoutWeight(1)
            if (this.currentUser.avatar) {
              Image(this.currentUser.avatar).width(48).height(48).borderRadius(24).objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.ic_avatar_placeholder')).width(48).height(48).borderRadius(24)
            }
          }
          .width('100%').height(80)
          .onClick(() => { this.handleAvatarClick(); })
          
          Divider().color('#F5F5F5')
          
          // 2. 昵称行
          Row() {
            Text('昵称').fontSize(16).fontColor('#333333').layoutWeight(1)
            Text(this.currentNickname).fontSize(16).fontColor('#888888')
          }
          .width('100%').height(60)
          .onClick(() => { this.dialogController.open(); })
          
          Divider().color('#F5F5F5')
          
          // 3. 健康 ID
          Row() {
            Text('健康 ID').fontSize(16).fontColor('#333333').layoutWeight(1)
            Text(this.currentUser.id?.toString() || '--').fontSize(16).fontColor('#888888')
          }
          .width('100%').height(60)
          
          Divider().color('#F5F5F5')
          
          // 4. 性别
          Row() {
            Text('性别').fontSize(16).fontColor('#333333').layoutWeight(1)
            Text(this.formatGender(this.currentUser.gender)).fontSize(16).fontColor('#888888')
          }
          .width('100%').height(60)
          
          Divider().color('#F5F5F5')
          
          // 5. 生日
          Row() {
            Text('生日').fontSize(16).fontColor('#333333').layoutWeight(1)
            Text(this.formatDate(this.currentUser.birthday)).fontSize(16).fontColor('#888888')
          }
          .width('100%').height(60)
        }
        .width('100%').padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')
        .margin({ top: 15 })
      } else {
        Text('正在加载用户信息...').margin({ top: 50 }).fontColor('#888888')
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 浅灰背景色
  }
}
