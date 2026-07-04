/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * MigrationStateManager - 跨端迁移状态管理器
 * 
 * 功能说明：
 * 1. 管理应用迁移时的状态保存和恢复
 * 2. 支持图片浏览状态、播放状态、背景色等状态的迁移
 * 3. 提供状态序列化和反序列化能力
 * 
 * 使用说明：
 * 1. 在onContinue中调用saveMigrationState()保存状态
 * 2. 在onCreate/onNewWant中调用restoreMigrationState()恢复状态
 * 3. 通过AppStorage在页面间共享状态
 */

import Logger from './Logger';

const TAG: string = '[MigrationStateManager]';

/** 迁移状态接口 */
export interface MigrationState {
  // 当前图片索引
  currentIndex: number;
  // 图片数量
  imageCount: number;
  // 当前背景色
  currentBgColor: string;
  // 目标背景色
  targetBgColor: string;
  // 取色策略
  colorStrategy: string;
  // 图片缩放比例
  imageScale: number;
  // 是否自动播放
  isAutoPlay: boolean;
  // Swiper间隔时间
  swiperInterval: number;
  // 时间戳
  timestamp: number;
  // 迁移源设备
  sourceDevice?: string;
}

/** 迁移结果 */
export interface MigrationResult {
  success: boolean;
  message?: string;
  state?: MigrationState;
}

/**
 * 跨端迁移状态管理器（单例）
 */
export class MigrationStateManager {
  private static instance: MigrationStateManager;
  private currentMigrationState: MigrationState | null = null;
  
  // AppStorage键名
  public static readonly KEY_MIGRATION_STATE: string = 'migration_state';
  public static readonly KEY_IS_MIGRATION_RESTORE: string = 'is_migration_restore';
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): MigrationStateManager {
    if (!MigrationStateManager.instance) {
      MigrationStateManager.instance = new MigrationStateManager();
    }
    return MigrationStateManager.instance;
  }
  
  /**
   * 保存迁移状态
   * @param state 迁移状态
   * @returns 序列化后的状态字符串
   */
  public saveMigrationState(state: MigrationState): string {
    try {
      // 添加时间戳
      state.timestamp = Date.now();
      
      // 保存到内存
      this.currentMigrationState = state;
      
      // 序列化为JSON字符串
      const stateString = JSON.stringify(state);
      
      Logger.info(TAG, `Migration state saved: ${stateString}`);
      return stateString;
    } catch (error) {
      Logger.error(TAG, `Failed to save migration state: ${JSON.stringify(error)}`);
      return '';
    }
  }
  
  /**
   * 恢复迁移状态
   * @param stateString 序列化的状态字符串
   * @returns 迁移结果
   */
  public restoreMigrationState(stateString: string): MigrationResult {
    try {
      if (!stateString || stateString.length === 0) {
        Logger.warn(TAG, 'Empty migration state string');
        return { success: false, message: '状态数据为空' };
      }
      
      // 反序列化
      const state: MigrationState = JSON.parse(stateString) as MigrationState;
      
      // 验证时间戳（防止过期状态）
      const currentTime = Date.now();
      const timeDiff = currentTime - state.timestamp;
      if (timeDiff > 300000) { // 5分钟过期
        Logger.warn(TAG, `Migration state expired: ${timeDiff}ms`);
        return { success: false, message: '状态数据已过期' };
      }
      
      // 保存到内存
      this.currentMigrationState = state;
      
      // 同步到AppStorage，供页面使用
      AppStorage.setOrCreate(MigrationStateManager.KEY_MIGRATION_STATE, state);
      AppStorage.setOrCreate(MigrationStateManager.KEY_IS_MIGRATION_RESTORE, true);
      
      Logger.info(TAG, `Migration state restored: currentIndex=${state.currentIndex}, bgColor=${state.currentBgColor}`);
      return { success: true, state: state };
    } catch (error) {
      Logger.error(TAG, `Failed to restore migration state: ${JSON.stringify(error)}`);
      return { success: false, message: `状态恢复失败: ${error}` };
    }
  }
  
  /**
   * 获取当前迁移状态
   */
  public getCurrentMigrationState(): MigrationState | null {
    return this.currentMigrationState;
  }
  
  /**
   * 清除迁移状态
   */
  public clearMigrationState(): void {
    this.currentMigrationState = null;
    AppStorage.delete(MigrationStateManager.KEY_MIGRATION_STATE);
    AppStorage.setOrCreate(MigrationStateManager.KEY_IS_MIGRATION_RESTORE, false);
    Logger.info(TAG, 'Migration state cleared');
  }
  
  /**
   * 检查是否为迁移恢复启动
   */
  public isMigrationRestore(): boolean {
    const isRestore = AppStorage.get<boolean>(MigrationStateManager.KEY_IS_MIGRATION_RESTORE) || false;
    return isRestore;
  }
  
  /**
   * 创建默认迁移状态
   */
  public static createDefaultState(): MigrationState {
    return {
      currentIndex: 0,
      imageCount: 8,
      currentBgColor: '#FFD4D4D4',
      targetBgColor: '#FFD4D4D4',
      colorStrategy: 'SMART',
      imageScale: 1.0,
      isAutoPlay: true,
      swiperInterval: 3500,
      timestamp: Date.now()
    };
  }
  
  /**
   * 验证迁移状态有效性
   */
  public validateMigrationState(state: MigrationState): boolean {
    if (!state) {
      return false;
    }
    
    // 验证索引范围
    if (state.currentIndex < 0 || state.currentIndex >= state.imageCount) {
      Logger.warn(TAG, `Invalid currentIndex: ${state.currentIndex}`);
      return false;
    }
    
    // 验证缩放比例
    if (state.imageScale < 0.3 || state.imageScale > 1.5) {
      Logger.warn(TAG, `Invalid imageScale: ${state.imageScale}`);
      return false;
    }
    
    // 验证颜色格式
    if (!state.currentBgColor || !state.currentBgColor.startsWith('#')) {
      Logger.warn(TAG, `Invalid currentBgColor: ${state.currentBgColor}`);
      return false;
    }
    
    return true;
  }
}

export default MigrationStateManager;
