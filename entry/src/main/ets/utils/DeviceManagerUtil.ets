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
 * DeviceManagerUtil - 设备管理工具（简化版）
 * 当前SDK版本不支持分布式设备管理API，提供空实现
 */

import { common } from '@kit.AbilityKit';
import Logger from './Logger';

const TAG: string = '[DeviceManagerUtil]';

/** 设备信息接口 */
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId: string;
  isOnline: boolean;
  isLocal: boolean;
}

/** 设备状态变化回调 */
export type DeviceStateCallback = (device: DeviceInfo, state: 'online' | 'offline' | 'changed') => void;

/** 设备发现回调 */
export type DeviceDiscoveryCallback = (devices: DeviceInfo[]) => void;

/**
 * 设备管理工具（简化实现）
 */
export default class DeviceManagerUtil {
  private static instance: DeviceManagerUtil | null = null;
  private isInitialized: boolean = false;
  private context: common.UIAbilityContext | null = null;
  private deviceList: DeviceInfo[] = [];
  private deviceStateCallbacks: DeviceStateCallback[] = [];
  private deviceDiscoveryCallbacks: DeviceDiscoveryCallback[] = [];

  private constructor() {}

  public static getInstance(): DeviceManagerUtil {
    if (!DeviceManagerUtil.instance) {
      DeviceManagerUtil.instance = new DeviceManagerUtil();
    }
    return DeviceManagerUtil.instance;
  }

  public async init(context: common.UIAbilityContext): Promise<boolean> {
    Logger.info(TAG, 'DeviceManagerUtil init (simplified mode)');
    this.context = context;
    this.isInitialized = true;
    return true;
  }

  public startDeviceDiscovery(): boolean {
    Logger.info(TAG, 'startDeviceDiscovery (simplified mode)');
    return true;
  }

  public stopDeviceDiscovery(): void {
    Logger.info(TAG, 'stopDeviceDiscovery (simplified mode)');
  }

  public getOnlineDevices(): DeviceInfo[] {
    return [...this.deviceList];
  }

  public getLocalDeviceInfo(): DeviceInfo | null {
    return {
      deviceId: 'local',
      deviceName: 'Local Device',
      deviceType: 'phone',
      networkId: '',
      isOnline: true,
      isLocal: true
    };
  }

  public isReady(): boolean {
    return this.isInitialized;
  }

  public async migrateTo(deviceId: string): Promise<boolean> {
    Logger.info(TAG, `migrateTo ${deviceId} (simplified mode - not supported)`);
    return false;
  }

  public onDeviceStateChange(callback: DeviceStateCallback): void {
    this.deviceStateCallbacks.push(callback);
  }

  public onDeviceDiscovery(callback: DeviceDiscoveryCallback): void {
    this.deviceDiscoveryCallbacks.push(callback);
  }

  public offDeviceStateChange(callback: DeviceStateCallback): void {
    const index = this.deviceStateCallbacks.indexOf(callback);
    if (index > -1) {
      this.deviceStateCallbacks.splice(index, 1);
    }
  }

  public offDeviceDiscovery(callback: DeviceDiscoveryCallback): void {
    const index = this.deviceDiscoveryCallbacks.indexOf(callback);
    if (index > -1) {
      this.deviceDiscoveryCallbacks.splice(index, 1);
    }
  }

  public release(): void {
    this.isInitialized = false;
    this.deviceList = [];
    this.deviceStateCallbacks = [];
    this.deviceDiscoveryCallbacks = [];
  }
}
