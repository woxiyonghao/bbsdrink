import photoAccessHelper from '@ohos.file.photoAccessHelper';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';

export class ImageSaveUtil {
  public static async savePixelMapToGallery(pixelMap: image.PixelMap): Promise<void> {
    try {
      let PhotoSaveOptions = new photoAccessHelper.PhotoSaveOptions();
      PhotoSaveOptions.newFileNames = [`Poster_${new Date().getTime()}.png`];
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      
      let uris = await photoPicker.save(PhotoSaveOptions);
      if (uris && uris.length > 0) {
        let uri = uris[0];
        let file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
        
        let imagePacker = image.createImagePacker();
        let packOpts: image.PackingOption = { format: "image/png", quality: 100 };
        
        let arrayBuffer = await imagePacker.packing(pixelMap, packOpts);
        fs.writeSync(file.fd, arrayBuffer);
        fs.closeSync(file);
        
        promptAction.showToast({ message: '保存相册成功！' });
      }
    } catch (err) {
      console.error('SaveImage Error:', JSON.stringify(err));
      promptAction.showToast({ message: '保存相册失败' });
    }
  }
}
