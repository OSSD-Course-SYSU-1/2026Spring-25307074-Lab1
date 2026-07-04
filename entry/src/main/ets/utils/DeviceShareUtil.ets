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
 * DeviceShareUtil - 隔空投送工具类
 * 
 * 功能说明：
 * 1. 支持隔空传送（GesturesShare）- 手势感应分享
 * 2. 支持碰一碰分享（KnockShare）- NFC接触分享
 * 3. 支持系统分享面板作为降级方案（模拟器环境）
 * 4. 多端兼容性处理（Phone/Tablet/TV/Wearable）
 * 5. 设备能力检测和降级处理
 * 
 * 使用说明：
 * 1. 在页面进入时调用 registerGestureShareListener() 注册监听
 * 2. 在页面离开时调用 unregisterGestureShareListener() 注销监听
 * 3. 在回调中构造分享数据并发起分享
 * 4. 如果不支持harmonyShare，使用 showSystemSharePanel() 显示系统分享面板
 */

import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG: string = '[DeviceShareUtil]';

/** 分享类型枚举 */
export enum ShareType {
  GESTURE_SHARE = 'gesturesShare',  // 隔空传送
  KNOCK_SHARE = 'knockShare'        // 碰一碰分享
}

/** 分享状态枚举 */
export enum ShareState {
  IDLE = 'idle',           // 空闲
  LISTENING = 'listening', // 监听中
  DETECTED = 'detected',   // 检测到分享意图
  SHARING = 'sharing',     // 分享中
  SUCCESS = 'success',     // 分享成功
  FAILED = 'failed'        // 分享失败
}

/** 分享数据配置 */
export interface ShareDataConfig {
  content: string;           // 分享内容（文本/链接/文件URI）
  utdType: utd.UniformDataType;  // 统一数据类型
  title?: string;            // 标题
  description?: string;      // 描述
  thumbnailUri?: string;     // 缩略图URI
}

/** 设备能力检测结果 */
export interface DeviceCapability {
  isSupported: boolean;      // 是否支持隔空投送
  deviceType: string;        // 设备类型
  canSend: boolean;          // 是否支持发送
  canReceive: boolean;       // 是否支持接收
  canUseSystemShare: boolean; // 是否支持系统分享面板（降级方案）
  reason?: string;           // 不支持的原因
}

/**
 * 隔空投送工具类
 */
export class DeviceShareUtil {
  private static instance: DeviceShareUtil;
  private context: common.UIAbilityContext | null = null;
  private isListening: boolean = false;
  private currentShareType: ShareType = ShareType.GESTURE_SHARE;
  
  // 回调函数引用（必须保持同一引用才能正确注销）
  private gestureShareCallback = (sharableTarget: harmonyShare.SharableTarget): void => {
    this.handleShareCallback(sharableTarget);
  };
  
  private knockShareCallback = (sharableTarget: harmonyShare.SharableTarget): void => {
    this.handleShareCallback(sharableTarget);
  };
  
  // 分享数据配置回调
  private shareDataCallback: (() => ShareDataConfig) | null = null;
  
  // 状态变化回调
  private onStateChange: ((state: ShareState, message?: string) => void) | null = null;
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): DeviceShareUtil {
    if (!DeviceShareUtil.instance) {
      DeviceShareUtil.instance = new DeviceShareUtil();
    }
    return DeviceShareUtil.instance;
  }
  
  /**
   * 初始化上下文
   */
  public init(context: common.UIAbilityContext): void {
    this.context = context;
    Logger.info(TAG, 'DeviceShareUtil initialized');
  }
  
  /**
   * 检测设备能力
   */
  public checkDeviceCapability(): DeviceCapability {
    const deviceType = deviceInfo.deviceType;
    const capability: DeviceCapability = {
      isSupported: false,
      deviceType: deviceType,
      canSend: false,
      canReceive: false,
      canUseSystemShare: false
    };
    
    // 检测系统分享面板能力（降级方案，所有设备都支持）
    const systemShareCapability = 'SystemCapability.BundleManager.BundleFramework';
    capability.canUseSystemShare = canIUse(systemShareCapability);
    
    // 检测系统版本和系统能力
    const capabilityFlag = 'SystemCapability.Collaboration.HarmonyShare';
    const isSystemSupported = canIUse(capabilityFlag);
    
    if (!isSystemSupported) {
      capability.reason = '当前系统版本不支持隔空投送功能（需要HarmonyOS 5.0及以上），将使用系统分享面板';
      Logger.warn(TAG, capability.reason);
      
      // 虽然不支持harmonyShare，但可以使用系统分享面板
      if (capability.canUseSystemShare) {
        capability.isSupported = true;
        capability.canSend = true;
        capability.canReceive = true;
        Logger.info(TAG, '将使用系统分享面板作为降级方案');
      }
      return capability;
    }
    
    // 根据设备类型判断能力
    switch (deviceType) {
      case 'phone':
      case 'tablet':
      case '2in1':
        capability.isSupported = true;
        capability.canSend = true;
        capability.canReceive = true;
        Logger.info(TAG, `${deviceType}设备完全支持隔空投送`);
        break;
        
      case 'tv':
        capability.isSupported = true;
        capability.canSend = false;  // TV通常不支持发送
        capability.canReceive = true;
        capability.reason = '电视设备支持接收，但不支持发送';
        Logger.info(TAG, capability.reason);
        break;
        
      case 'wearable':
        capability.isSupported = false;
        capability.canSend = false;
        capability.canReceive = false;
        capability.reason = '手表设备不支持隔空投送功能';
        Logger.warn(TAG, capability.reason);
        break;
        
      default:
        capability.reason = `未知设备类型: ${deviceType}`;
        Logger.warn(TAG, capability.reason);
    }
    
    return capability;
  }
  
  /**
   * 设置分享数据回调
   */
  public setShareDataCallback(callback: () => ShareDataConfig): void {
    this.shareDataCallback = callback;
  }
  
  /**
   * 设置状态变化回调
   */
  public setOnStateChange(callback: (state: ShareState, message?: string) => void): void {
    this.onStateChange = callback;
  }
  
  /**
   * 注册隔空传送监听
   */
  public registerGestureShareListener(): boolean {
    if (this.isListening) {
      Logger.warn(TAG, 'Already listening to gesture share');
      return true;
    }
    
    const capability = this.checkDeviceCapability();
    if (!capability.isSupported || !capability.canSend) {
      const message = capability.reason || '当前设备不支持隔空投送';
      Logger.error(TAG, message);
      this.notifyStateChange(ShareState.FAILED, message);
      return false;
    }
    
    try {
      harmonyShare.on(ShareType.GESTURE_SHARE, this.gestureShareCallback);
      this.isListening = true;
      this.currentShareType = ShareType.GESTURE_SHARE;
      this.notifyStateChange(ShareState.LISTENING, '隔空传送监听已开启');
      Logger.info(TAG, 'Gesture share listener registered');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to register gesture share listener. Code: ${err.code}, message: ${err.message}`);
      this.notifyStateChange(ShareState.FAILED, `注册监听失败: ${err.message}`);
      return false;
    }
  }
  
  /**
   * 注册碰一碰分享监听
   */
  public registerKnockShareListener(): boolean {
    if (this.isListening) {
      Logger.warn(TAG, 'Already listening to knock share');
      return true;
    }
    
    const capability = this.checkDeviceCapability();
    if (!capability.isSupported || !capability.canSend) {
      const message = capability.reason || '当前设备不支持碰一碰分享';
      Logger.error(TAG, message);
      this.notifyStateChange(ShareState.FAILED, message);
      return false;
    }
    
    try {
      harmonyShare.on(ShareType.KNOCK_SHARE, this.knockShareCallback);
      this.isListening = true;
      this.currentShareType = ShareType.KNOCK_SHARE;
      this.notifyStateChange(ShareState.LISTENING, '碰一碰分享监听已开启');
      Logger.info(TAG, 'Knock share listener registered');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to register knock share listener. Code: ${err.code}, message: ${err.message}`);
      this.notifyStateChange(ShareState.FAILED, `注册监听失败: ${err.message}`);
      return false;
    }
  }
  
  /**
   * 注销隔空传送监听
   */
  public unregisterGestureShareListener(): void {
    if (!this.isListening || this.currentShareType !== ShareType.GESTURE_SHARE) {
      return;
    }
    
    try {
      harmonyShare.off(ShareType.GESTURE_SHARE, this.gestureShareCallback);
      this.isListening = false;
      this.notifyStateChange(ShareState.IDLE, '隔空传送监听已关闭');
      Logger.info(TAG, 'Gesture share listener unregistered');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to unregister gesture share listener. Code: ${err.code}, message: ${err.message}`);
    }
  }
  
  /**
   * 注销碰一碰分享监听
   */
  public unregisterKnockShareListener(): void {
    if (!this.isListening || this.currentShareType !== ShareType.KNOCK_SHARE) {
      return;
    }
    
    try {
      harmonyShare.off(ShareType.KNOCK_SHARE, this.knockShareCallback);
      this.isListening = false;
      this.notifyStateChange(ShareState.IDLE, '碰一碰分享监听已关闭');
      Logger.info(TAG, 'Knock share listener unregistered');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to unregister knock share listener. Code: ${err.code}, message: ${err.message}`);
    }
  }
  
  /**
   * 注销所有监听
   */
  public unregisterAllListeners(): void {
    this.unregisterGestureShareListener();
    this.unregisterKnockShareListener();
  }
  
  /**
   * 处理分享回调
   * 注意：必须在3秒内调用share/clarifyNonShare/reject方法
   */
  private handleShareCallback(sharableTarget: harmonyShare.SharableTarget): void {
    Logger.info(TAG, 'Share callback triggered');
    this.notifyStateChange(ShareState.DETECTED, '检测到分享意图');
    
    try {
      // 获取分享数据配置
      if (!this.shareDataCallback) {
        Logger.error(TAG, 'Share data callback not set');
        sharableTarget.clarifyNonShare({ message: '未设置分享数据' });
        this.notifyStateChange(ShareState.FAILED, '未设置分享数据');
        return;
      }
      
      const shareConfig = this.shareDataCallback();
      
      // 构造分享数据
      const shareData = new systemShare.SharedData({
        utd: shareConfig.utdType,
        content: shareConfig.content,
        title: shareConfig.title,
        description: shareConfig.description,
        thumbnailUri: shareConfig.thumbnailUri
      });
      
      // 发起分享
      this.notifyStateChange(ShareState.SHARING, '正在分享...');
      
      sharableTarget.share(shareData).then(() => {
        Logger.info(TAG, 'Share succeeded');
        this.notifyStateChange(ShareState.SUCCESS, '分享成功');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Share failed. Code: ${err.code}, message: ${err.message}`);
        this.notifyStateChange(ShareState.FAILED, `分享失败: ${err.message}`);
      });
      
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Handle share callback failed. Code: ${err.code}, message: ${err.message}`);
      
      // 发生异常时主动拒绝
      sharableTarget.reject(harmonyShare.SharableErrorCode.NO_CONTENT_ERROR);
      this.notifyStateChange(ShareState.FAILED, `处理失败: ${err.message}`);
    }
  }
  
  /**
   * 构造图片分享数据
   */
  public static createImageShareConfig(
    imageUri: string,
    title: string = '图片分享',
    description: string = '通过隔空投送分享图片'
  ): ShareDataConfig {
    return {
      content: imageUri,
      utdType: utd.UniformDataType.IMAGE,
      title: title,
      description: description,
      thumbnailUri: imageUri
    };
  }
  
  /**
   * 构造文本分享数据
   */
  public static createTextShareConfig(
    text: string,
    title: string = '文本分享',
    description: string = '通过隔空投送分享文本'
  ): ShareDataConfig {
    return {
      content: text,
      utdType: utd.UniformDataType.PLAIN_TEXT,
      title: title,
      description: description
    };
  }
  
  /**
   * 构造链接分享数据
   */
  public static createLinkShareConfig(
    url: string,
    title: string = '链接分享',
    description: string = '通过隔空投送分享链接',
    thumbnailUri?: string
  ): ShareDataConfig {
    return {
      content: url,
      utdType: utd.UniformDataType.HYPERLINK,
      title: title,
      description: description,
      thumbnailUri: thumbnailUri
    };
  }
  
  /**
   * 构造视频分享数据
   */
  public static createVideoShareConfig(
    videoUri: string,
    title: string = '视频分享',
    description: string = '通过隔空投送分享视频'
  ): ShareDataConfig {
    return {
      content: videoUri,
      utdType: utd.UniformDataType.VIDEO,
      title: title,
      description: description
    };
  }
  
  /**
   * 将文件路径转换为URI
   */
  public static convertPathToUri(filePath: string): string {
    return fileUri.getUriFromPath(filePath);
  }
  
  /**
   * 通知状态变化
   */
  private notifyStateChange(state: ShareState, message?: string): void {
    if (this.onStateChange) {
      this.onStateChange(state, message);
    }
  }
  
  /**
   * 获取当前监听状态
   */
  public isCurrentlyListening(): boolean {
    return this.isListening;
  }
  
  /**
   * 获取当前分享类型
   */
  public getCurrentShareType(): ShareType {
    return this.currentShareType;
  }
  
  /**
   * 使用系统分享面板分享内容（降级方案）
   * 适用于模拟器环境或不支持harmonyShare的设备
   */
  public async showSystemSharePanel(shareConfig: ShareDataConfig): Promise<boolean> {
    if (!this.context) {
      Logger.error(TAG, 'Context not initialized');
      return false;
    }
    
    try {
      Logger.info(TAG, 'Showing system share panel');
      this.notifyStateChange(ShareState.SHARING, '正在打开分享面板...');
      
      // 构造分享数据
      const sharedData = new systemShare.SharedData({
        utd: shareConfig.utdType,
        content: shareConfig.content,
        title: shareConfig.title,
        description: shareConfig.description,
        thumbnailUri: shareConfig.thumbnailUri
      });
      
      // 创建分享控制器
      const shareController = new systemShare.ShareController(sharedData);
      
      // 显示分享面板
      await shareController.show(this.context, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      Logger.info(TAG, 'System share panel shown successfully');
      this.notifyStateChange(ShareState.SUCCESS, '分享面板已打开');
      return true;
      
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Failed to show system share panel. Code: ${err.code}, message: ${err.message}`);
      this.notifyStateChange(ShareState.FAILED, `打开分享面板失败: ${err.message}`);
      return false;
    }
  }
  
  /**
   * 智能分享（自动选择harmonyShare或系统分享面板）
   * 优先使用harmonyShare，如果不可用则降级到系统分享面板
   */
  public async smartShare(shareConfig: ShareDataConfig): Promise<boolean> {
    const capability = this.checkDeviceCapability();
    
    // 如果支持harmonyShare且已监听，则使用harmonyShare
    if (capability.isSupported && this.isListening) {
      Logger.info(TAG, 'Using harmonyShare for sharing');
      // harmonyShare会在回调中自动处理，这里返回true
      return true;
    }
    
    // 否则使用系统分享面板
    if (capability.canUseSystemShare) {
      Logger.info(TAG, 'Falling back to system share panel');
      return await this.showSystemSharePanel(shareConfig);
    }
    
    Logger.error(TAG, 'No available share method');
    return false;
  }
  
  /**
   * 检查是否可以使用系统分享面板
   */
  public canUseSystemShare(): boolean {
    const capability = this.checkDeviceCapability();
    return capability.canUseSystemShare;
  }
}

export default DeviceShareUtil;
