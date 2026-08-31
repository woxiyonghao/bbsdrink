import picker from '@ohos.file.picker';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';

export class ImageSaveUtil {
  public static async savePixelMapToGallery(pixelMap: image.PixelMap): Promise<void> {
    try {
      let photoSaveOptions: picker.PhotoSaveOptions = new picker.PhotoSaveOptions();
      photoSaveOptions.newFileNames = [`Poster_${new Date().getTime()}.png`];
      
      let photoPicker: picker.PhotoViewPicker = new picker.PhotoViewPicker();
      let uris: Array<string> = await photoPicker.save(photoSaveOptions);
      
      if (uris && uris.length > 0) {
        let uri: string = uris[0];
        let file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
        
        let imagePacker: image.ImagePacker = image.createImagePacker();
        let packOpts: image.PackingOption = { format: "image/png", quality: 100 };
        
        let arrayBuffer: ArrayBuffer = await imagePacker.packing(pixelMap, packOpts);
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
