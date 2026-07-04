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
 * DistributedDataManager - 分布式数据管理器（简化版）
 * 当前SDK版本不支持分布式数据API，提供空实现
 */

import { common } from '@kit.AbilityKit';
import Logger from './Logger';

const TAG: string = '[DistributedDataManager]';

/** 分布式数据配置 */
export interface DistributedDataConfig {
  storeId: string;
  bundleName: string;
}

/** 数据变化回调 */
export type DataChangeCallback = (key: string, value: string | number | boolean | object) => void;

/**
 * 分布式数据管理器（简化实现）
 */
export default class DistributedDataManager {
  private static instance: DistributedDataManager | null = null;
  private isInitialized: boolean = false;
  private dataMap: Map<string, string | number | boolean | object> = new Map();
  private callbacks: DataChangeCallback[] = [];

  private constructor() {}

  public static getInstance(): DistributedDataManager {
    if (!DistributedDataManager.instance) {
      DistributedDataManager.instance = new DistributedDataManager();
    }
    return DistributedDataManager.instance;
  }

  public async init(context: common.UIAbilityContext): Promise<boolean> {
    Logger.info(TAG, 'DistributedDataManager init (simplified mode)');
    this.isInitialized = true;
    return true;
  }

  public async put(key: string, value: string | number | boolean | object): Promise<boolean> {
    this.dataMap.set(key, value);
    return true;
  }

  public async get(key: string): Promise<string | number | boolean | object | undefined> {
    return this.dataMap.get(key);
  }

  public subscribe(key: string, callback: DataChangeCallback): void {
    this.callbacks.push(callback);
  }

  public unsubscribe(key: string): void {
    // 简化实现
  }

  public isReady(): boolean {
    return this.isInitialized;
  }

  public async sync(): Promise<boolean> {
    Logger.info(TAG, 'sync (simplified mode)');
    return true;
  }

  public async release(): Promise<void> {
    this.isInitialized = false;
    this.dataMap.clear();
    this.callbacks = [];
  }
}
