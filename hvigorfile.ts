import { appTasks } from '@ohos/hvigor-ohos-plugin';
import * as fs from 'fs';
import * as path from 'path';

try {
  const targetPath = path.join(__dirname, 'oh_modules/.ohpm');
  // 查找所有 ibest-ui 的 oh-package.json5 并将 compatibleSdkVersion:21 改为 12
  const fixSDK = (dir) => {
    if (!fs.existsSync(dir)) return;
    const files = fs.readdirSync(dir);
    for (const file of files) {
      const fullPath = path.join(dir, file);
      if (fs.statSync(fullPath).isDirectory()) {
        fixSDK(fullPath);
      } else if (file === 'oh-package.json5') {
        let content = fs.readFileSync(fullPath, 'utf-8');
        if (content.includes('"compatibleSdkVersion":21')) {
          content = content.replace(/"compatibleSdkVersion":21/g, '"compatibleSdkVersion":12');
          fs.writeFileSync(fullPath, content, 'utf-8');
        }
      }
    }
  };
  fixSDK(targetPath);
} catch (e) {
  console.log('Failed to fix ibest sdk version', e);
}

export default {
  system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []        /* Custom plugin to extend the functionality of Hvigor. */
}
