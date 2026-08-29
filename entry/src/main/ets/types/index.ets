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

export class ActivityItem {
  name: string;
  duration: string;
  color1: string;
  color2: string;
  progress: number;
  icon: ResourceStr;
  isEmoji?: boolean;
  drinkType?: number;
  noFill?: boolean;
  targetSeconds?: number;
  /** 指定跳转的运动页面路由，不填默认使用 StretchPage */
  activityPage?: string;

  constructor(
    name: string,
    duration: string,
    color1: string,
    color2: string,
    progress: number,
    icon: ResourceStr,
    isEmoji?: boolean,
    drinkType?: number,
    noFill?: boolean,
    targetSeconds?: number,
    activityPage?: string
  ) {
    this.name = name;
    this.duration = duration;
    this.color1 = color1;
    this.color2 = color2;
    this.progress = progress;
    this.icon = icon;
    this.isEmoji = isEmoji;
    this.drinkType = drinkType;
    this.noFill = noFill;
    this.targetSeconds = targetSeconds;
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
      this.isEmoji,
      this.drinkType,
      this.noFill,
      this.targetSeconds,
      this.activityPage
    );
  }
}

export const GLOBAL_ACTIVITIES: ActivityItem[] = [
  new ActivityItem('伸懒腰', '1分钟', '#FFB75E', '#ED8F03', 0, $r('app.media.stretch'), undefined, undefined, true, 60),
  new ActivityItem('接杯水', '3分钟', '#8ECAE6', '#219EBC', 0, $r('app.media.ic_cup_water'), undefined, 0),
  new ActivityItem('颈椎操', '5分钟', '#A8E063', '#56AB2F', 0, $r('app.media.ic_sit_record'), undefined, undefined, undefined, 300),
  new ActivityItem('喝杯咖啡', '5分钟', '#D4A373', '#A98467', 0, $r('app.media.ic_drink_coffee'), undefined, 1),
  new ActivityItem('眼保健操', '5分钟', '#FFD166', '#F4A261', 0, '💆', true, undefined, undefined, 300),
  new ActivityItem('吃点水果', '5分钟', '#EF476F', '#D90429', 0, '🍎', true, undefined, undefined, 300),
  new ActivityItem('喝杯牛奶', '3分钟', '#8ECAE6', '#0077B6', 0, $r('app.media.ic_drink_milk'), undefined, 3),
  new ActivityItem('眺望窗外', '2分钟', '#06D6A0', '#00A896', 0, '🏞️', true, undefined, undefined, 120),
  new ActivityItem('闭目养神', '3分钟', '#FF758C', '#FF7EB3', 0, '🧘', true, undefined, undefined, 180),
  new ActivityItem('喝杯果汁', '3分钟', '#FF9A9E', '#FECFEF', 0, $r('app.media.ic_drink_juice'), undefined, 4),
  new ActivityItem('站起来动动', '3分钟', '#A8E063', '#56AB2F', 0, '🤸', true, undefined, undefined, 180),
  new ActivityItem('深蹲一下', '3分钟', '#FFB75E', '#ED8F03', 0, $r('app.media.squat'), undefined, undefined, true, 180, 'pages/run/SquatPage'),
  new ActivityItem('楼下走走', '10分钟', '#06D6A0', '#00A896', 0, $r('app.media.ic_sport_white'), undefined, undefined, undefined, 600),
  new ActivityItem('喝杯茶', '10分钟', '#90E0EF', '#0077B6', 0, $r('app.media.ic_drink_tea'), undefined, 2),
  new ActivityItem('跑一下', '15分钟', '#118AB2', '#073B4C', 0, $r('app.media.ic_sport_white'), undefined, undefined, undefined, 900)
];
