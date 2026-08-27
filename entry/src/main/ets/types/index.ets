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
