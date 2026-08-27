# Drink App 开发规范 (AI Coding Rules)

在为本 ArkTS 项目编写代码时，请始终遵循以下规则：

1. **及时分割文件，防止代码冗余**：
   - 保持单个文件简短精炼。如果一个 UI 组件变得过大，请将其拆分为更小的子组件。
   - 避免将所有逻辑塞进同一个页面，合理抽取业务逻辑。

2. **主动新建文件和目录**：
   - 根据业务需求，需要新建目录就果断新建，需要新建文件就果断新建，不要将新功能强行凑在已有的文件中。

3. **严格遵守模块化的目录规范**：
   项目采用模块化划分，请将代码放置在对应的目录下（如不存在请先创建）：
   - `pages/home/`: 首页专属的页面和局部组件
   - `pages/ding/`: 打卡页专属的页面和局部组件
   - `pages/mine/`: 我的专属页面和局部组件
   - `components/`: 跨页面复用的公共组件
   - `tools/`: 通用工具类 (如时间处理、字符串处理等)
   - `store/`: 状态管理、本地存储 (Preferences)、数据库 (SQLite/RelationalStore) 操作
   - `types/`: 全局的 TypeScript 接口声明和类型定义 (Interfaces, Types)

4. **规范的中文注释**：
   - 必须为所有公共方法、核心业务逻辑、共享属性添加**简体中文注释**，说明其作用和参数意义，增强代码可读性。

5. **代码整洁与控制流规范 (Clean Code)**：
   - **避免深度嵌套的 if-else**：遇到多重条件判断时，尽量将其封装为 `enum` 枚举，并使用 `switch-case` 结构。
   - **使用尽早返回 (Early Return) 模式**：避免冗长的 `else` 块。
     - ❌ **Bad (避免使用)**:
       ```typescript
       const process = (isValid: boolean) => {
         if (isValid) {
           // do long things...
         } else {
           // do another thing...
         }
       }
       ```
     - ✅ **Good (推荐使用)**:
       ```typescript
       const process = (isValid: boolean) => {
         if (!isValid) {
           return; // 或抛出异常、处理另一分支
         }
         // do long things...
       }
       ```

6. **UI 与设计规范**：
   - **主色调**：项目属于“工具 + 健康”类，主色调必须统一使用 **绿色 (Green)**。在使用高亮、强调色、选中状态时，请使用优雅健康的绿色（如 `#34C759`）。
