import router from '@ohos.router';

@Entry
@Component
export struct PrivacyPage {
  @State title: string = '';
  @State content: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.type === 'user') {
      this.title = '用户协议';
      this.content = `欢迎您使用“该喝水啦亲”健康打卡应用（以下简称“本应用”）。\n\n1. 协议的接受与修改\n您在登录或使用本应用时，即视为您完全同意并接受本协议的全部条款。本应用保留随时修改本协议的权利，修改后的内容将在应用内公布。\n\n2. 服务说明\n本应用为您提供本地化的喝水、运动打卡记录服务。所有数据默认保存在您的本地设备上。\n\n3. 用户的行为规范\n您在使用本应用时，必须遵守国家法律法规，不得利用本应用从事任何违法违规或侵害他人合法权益的活动。\n\n4. 免责声明\n本应用提供的健康建议及数据记录仅供参考，不能替代专业的医疗建议。因使用本应用产生的一切后果由您自行承担。`;
    } else {
      this.title = '隐私政策';
      this.content = `“该喝水啦亲”健康打卡应用（以下简称“本应用”）非常重视您的隐私。本隐私政策旨在向您说明我们会如何收集、使用、存储和保护您的个人信息。\n\n1. 信息的收集\n在您使用本应用时，为了提供个性化的健康记录服务，我们会收集您主动填写的昵称、性别、生日以及设置的头像信息。这些数据将仅用于在应用内为您展示及生成对应的健康报告。\n\n2. 信息的存储与保护\n本应用是一款纯本地应用，您的所有个人数据（包含健康记录）均加密存储在您的本地设备上。我们不会将您的个人数据上传至任何云端服务器，也不会与任何第三方共享。\n\n3. 网络权限说明\n本应用不主动发起任何收集用户数据的网络请求。应用内预置的文章模块中的配图使用了本地资源，确保您的使用轨迹不会被追踪。\n\n4. 账号注销与数据删除\n您可以通过应用内“个人信息”页面提供的“注销账号”功能，随时清除您在本应用内的所有本地数据。数据一旦清除，将无法恢复，请谨慎操作。\n\n5. 联系我们\n如果您对本隐私政策有任何疑问，请通过应用内的“关于我们”页面联系开发者。`;
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24).height(24)
          .onClick(() => router.back())
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      Scroll() {
        Text(this.content)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(24)
          .padding(20)
          .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
