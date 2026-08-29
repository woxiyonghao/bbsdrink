export interface User {
  id?: number;
  nickname: string;
  avatar?: string;
  gender: number; // 0: 女, 1: 男, 2: 未知
  birthday: number; // 出生年月日的时间戳
  createTime: number;
}

export interface Task {
  id?: number;
  userId: number;
  title: string;
  targetCount: number; // 例如 30 (分钟)， 1000 (次)
  unit: string;
  createTime: number;
}

export interface CheckInRecord {
  id?: number;
  userId: number;
  type: number; // 0: 喝水, 1: 久坐, 2: 步数, 3: 自定义任务, 4: 每日签到
  taskId?: number; // 如果是自定义任务(type=3)，关联 task 表的 id
  value: number; // 例如 喝水量，步数
  timestamp: number;
}

export class DrinkOption {
  type: number;
  name: string;
  icon: Resource;
  
  constructor(type: number, name: string, icon: Resource) {
    this.type = type;
    this.name = name;
    this.icon = icon;
  }
}

export const GLOBAL_DRINKS: DrinkOption[] = [
  new DrinkOption(0, '水', $r('app.media.ic_drink_water')),
  new DrinkOption(1, '咖啡', $r('app.media.ic_drink_coffee')),
  new DrinkOption(2, '绿茶', $r('app.media.ic_drink_tea')),
  new DrinkOption(3, '牛奶', $r('app.media.ic_drink_milk')),
  new DrinkOption(4, '果汁', $r('app.media.ic_drink_juice')),
  new DrinkOption(5, '柠檬茶', $r('app.media.ic_drink_lemon')),
  new DrinkOption(6, '运动饮料', $r('app.media.ic_drink_sports')),
  new DrinkOption(7, '气泡水', $r('app.media.ic_drink_sparkling')),
  new DrinkOption(8, '椰子水', $r('app.media.ic_drink_coconut')),
  new DrinkOption(9, '花茶', $r('app.media.ic_drink_herbal')),
  new DrinkOption(10, '热可可', $r('app.media.ic_drink_cocoa')),
  new DrinkOption(11, '补剂', $r('app.media.ic_drink_bottle'))
];

/**
 * 运动活动类
 * activityType: 数据库存储类型，200+ 专属运动类，避免与喝水类(0~11)、签到(4)冲突
 *   201: 伸懒腰  202: 颈椎操  203: 眼保健操  204: 吃点水果
 *   205: 眺望窗外 206: 闭目养神 207: 站起来动动 208: 深蹲一下
 *   209: 楼下走走 210: 跑一下
 */
export class ActivityItem {
  name: string;
  duration: string;
  color1: string;
  color2: string;
  /** 当前进度（0~100），由数据库查询结果驱动，完成=100，未完成=0 */
  progress: number;
  icon: ResourceStr;
  isEmoji?: boolean;
  noFill?: boolean;
  /** 目标秒数，完成打卡所需时长 */
  targetSeconds: number;
  /** 数据库记录类型值，每个运动唯一，范围 201~299 */
  activityType: number;
  /** 跳转的运动页面路由，不填默认使用 StretchPage */
  activityPage?: string;

  constructor(
    name: string,
    duration: string,
    color1: string,
    color2: string,
    progress: number,
    icon: ResourceStr,
    activityType: number,
    targetSeconds: number,
    isEmoji?: boolean,
    noFill?: boolean,
    activityPage?: string
  ) {
    this.name = name;
    this.duration = duration;
    this.color1 = color1;
    this.color2 = color2;
    this.progress = progress;
    this.icon = icon;
    this.activityType = activityType;
    this.targetSeconds = targetSeconds;
    this.isEmoji = isEmoji;
    this.noFill = noFill;
    this.activityPage = activityPage;
  }

  clone(): ActivityItem {
    return new ActivityItem(
      this.name,
      this.duration,
      this.color1,
      this.color2,
      this.progress,
      this.icon,
      this.activityType,
      this.targetSeconds,
      this.isEmoji,
      this.noFill,
      this.activityPage
    );
  }
}

/**
 * 全局运动活动列表
 * 已移除喝水类（接杯水/喝杯咖啡/喝杯牛奶/喝杯果汁/喝杯茶），这些属于喝水模块
 * activityType 从 201 起步，每项唯一，确保数据库记录互不干扰
 */
export const GLOBAL_ACTIVITIES: ActivityItem[] = [
  new ActivityItem('伸懒腰',     '1分钟',  '#FFB75E', '#ED8F03', 0, $r('app.media.stretch'),        201, 60),
  new ActivityItem('颈椎操',     '5分钟',  '#A8E063', '#56AB2F', 0, $r('app.media.neck'),           202, 300, undefined, true, 'pages/run/NeckPage'),
  new ActivityItem('眼保健操',   '5分钟',  '#FFD166', '#F4A261', 0, '💆',                            203, 300, true),
  new ActivityItem('吃点水果',   '5分钟',  '#EF476F', '#D90429', 0, '🍎',                            204, 300, true),
  new ActivityItem('眺望窗外',   '2分钟',  '#06D6A0', '#00A896', 0, '🏞️',                           205, 120, true),
  new ActivityItem('闭目养神',   '3分钟',  '#FF758C', '#FF7EB3', 0, '🧘',                            206, 180, true),
  new ActivityItem('站起来动动', '3分钟',  '#A8E063', '#56AB2F', 0, '🤸',                            207, 180, true),
  new ActivityItem('深蹲一下',   '3分钟',  '#FFB75E', '#ED8F03', 0, $r('app.media.squat'),           208, 180, undefined, true, 'pages/run/SquatPage'),
  new ActivityItem('楼下走走',   '10分钟', '#06D6A0', '#00A896', 0, $r('app.media.ic_sport_white'), 209, 600),
  new ActivityItem('跑一下',     '15分钟', '#118AB2', '#073B4C', 0, $r('app.media.ic_sport_white'), 210, 900),
];

