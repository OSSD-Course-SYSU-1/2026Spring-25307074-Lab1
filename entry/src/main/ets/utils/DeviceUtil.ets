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

import { deviceInfo } from '@kit.BasicServicesKit';

/**
 * 设备类型枚举
 */
export enum DeviceType {
  PHONE = 'phone',
  TABLET = 'tablet',
  TWO_IN_ONE = '2in1',
  TV = 'tv',
  WEARABLE = 'wearable',
  DEFAULT = 'default'
}

/**
 * 尺寸配置接口
 */
export class SizeConfig {
  fontSize: number = 12;          // 字体大小
  buttonHeight: number = 32;      // 按钮高度
  buttonWidth: number = 40;       // 按钮宽度（圆形按钮）
  iconSize: number = 24;          // 图标大小
  padding: number = 20;           // 内边距
  margin: number = 8;             // 外边距
  sliderWidth: string = '40%';    // 滑块宽度
  controlRowHeight: number = 36;  // 控制行高度

  constructor(
    fontSize: number,
    buttonHeight: number,
    buttonWidth: number,
    iconSize: number,
    padding: number,
    margin: number,
    sliderWidth: string,
    controlRowHeight: number
  ) {
    this.fontSize = fontSize;
    this.buttonHeight = buttonHeight;
    this.buttonWidth = buttonWidth;
    this.iconSize = iconSize;
    this.padding = padding;
    this.margin = margin;
    this.sliderWidth = sliderWidth;
    this.controlRowHeight = controlRowHeight;
  }
}

/**
 * 设备适配工具类
 * 提供多端尺寸适配能力，特别优化手表等小屏设备
 * 支持模拟器环境下的设备类型切换测试
 */
export class DeviceUtil {
  private static instance: DeviceUtil;
  private currentDeviceType: DeviceType;
  private sizeConfig: SizeConfig;
  private isSimulatedDevice: boolean = false; // 是否使用模拟设备类型
  private simulatedDeviceType: DeviceType | null = null; // 模拟的设备类型

  private constructor() {
    this.currentDeviceType = this.detectDeviceType();
    this.sizeConfig = this.initSizeConfig();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): DeviceUtil {
    if (!DeviceUtil.instance) {
      DeviceUtil.instance = new DeviceUtil();
    }
    return DeviceUtil.instance;
  }

  /**
   * 检测当前设备类型
   */
  private detectDeviceType(): DeviceType {
    const deviceType = deviceInfo.deviceType;
    if (deviceType === 'phone') {
      return DeviceType.PHONE;
    } else if (deviceType === 'tablet') {
      return DeviceType.TABLET;
    } else if (deviceType === '2in1') {
      return DeviceType.TWO_IN_ONE;
    } else if (deviceType === 'tv') {
      return DeviceType.TV;
    } else if (deviceType === 'wearable') {
      return DeviceType.WEARABLE;
    } else {
      return DeviceType.DEFAULT;
    }
  }

  /**
   * 初始化尺寸配置
   */
  private initSizeConfig(): SizeConfig {
    // 获取有效的设备类型（可能是模拟的）
    const effectiveDeviceType = this.getEffectiveDeviceType();
    
    // 根据设备类型返回对应的尺寸配置
    if (effectiveDeviceType === DeviceType.WEARABLE) {
      // 手表设备 - 极简尺寸，适配圆形小屏
      return new SizeConfig(8, 20, 24, 12, 4, 2, '25%', 20);
    } else if (effectiveDeviceType === DeviceType.PHONE) {
      // 手机设备 - 标准尺寸
      return new SizeConfig(12, 32, 40, 24, 20, 8, '40%', 36);
    } else if (effectiveDeviceType === DeviceType.TABLET) {
      // 平板设备 - 稍大尺寸
      return new SizeConfig(14, 36, 44, 26, 24, 10, '45%', 40);
    } else if (effectiveDeviceType === DeviceType.TWO_IN_ONE) {
      // 2合1设备 - 大尺寸
      return new SizeConfig(14, 36, 44, 26, 24, 10, '45%', 40);
    } else if (effectiveDeviceType === DeviceType.TV) {
      // TV设备 - 大尺寸
      return new SizeConfig(16, 40, 48, 28, 28, 12, '50%', 44);
    } else {
      // 默认配置
      return new SizeConfig(12, 32, 40, 24, 20, 8, '40%', 36);
    }
  }

  /**
   * 获取当前设备类型
   */
  public getDeviceType(): DeviceType {
    return this.getEffectiveDeviceType();
  }

  /**
   * 判断是否为手表设备
   */
  public isWearable(): boolean {
    return this.getEffectiveDeviceType() === DeviceType.WEARABLE;
  }

  /**
   * 判断是否为TV设备
   */
  public isTV(): boolean {
    return this.getEffectiveDeviceType() === DeviceType.TV;
  }

  /**
   * 判断是否为2in1设备
   */
  public is2in1(): boolean {
    return this.getEffectiveDeviceType() === DeviceType.TWO_IN_ONE;
  }

  /**
   * 获取字体大小
   * @param level 字体大小级别 (1: 小, 2: 中, 3: 大)
   */
  public getFontSize(level: number = 2): number {
    const baseSize = this.sizeConfig.fontSize;
    
    // 根据级别调整大小
    if (level === 1) {
      // 小号字体
      return Math.max(baseSize - 2, 8);
    } else if (level === 3) {
      // 大号字体
      return baseSize + 2;
    } else {
      // 标准字体
      return baseSize;
    }
  }

  /**
   * 获取按钮高度
   */
  public getButtonHeight(): number {
    return this.sizeConfig.buttonHeight;
  }

  /**
   * 获取按钮宽度（圆形按钮）
   */
  public getButtonWidth(): number {
    return this.sizeConfig.buttonWidth;
  }

  /**
   * 获取图标大小
   */
  public getIconSize(): number {
    return this.sizeConfig.iconSize;
  }

  /**
   * 获取内边距
   */
  public getPadding(): number {
    return this.sizeConfig.padding;
  }

  /**
   * 获取外边距
   */
  public getMargin(): number {
    return this.sizeConfig.margin;
  }

  /**
   * 获取滑块宽度
   */
  public getSliderWidth(): string {
    return this.sizeConfig.sliderWidth;
  }

  /**
   * 获取控制行高度
   */
  public getControlRowHeight(): number {
    return this.sizeConfig.controlRowHeight;
  }

  /**
   * 获取页码字体大小
   */
  public getPageIndicatorFontSize(): number {
    // 手表设备使用更小的字体
    if (this.isWearable()) {
      return 8;
    }
    return 14;
  }

  /**
   * 获取左右切换按钮尺寸
   */
  public getNavigationButtonSize(): number {
    // 手表设备使用更小的按钮
    if (this.isWearable()) {
      return 24;
    }
    return 40;
  }

  /**
   * 获取导航按钮图标字体大小
   */
  public getNavigationIconFontSize(): number {
    // 手表设备使用更小的图标
    if (this.isWearable()) {
      return 12;
    }
    return 24;
  }

  /**
   * 判断是否显示完整控制面板
   * 手表设备简化UI，隐藏部分控制项
   */
  public shouldShowFullControls(): boolean {
    return !this.isWearable();
  }

  /**
   * 判断是否显示图片大小调节滑块
   * 手表设备隐藏此功能
   */
  public shouldShowImageSizeSlider(): boolean {
    return !this.isWearable();
  }

  /**
   * 判断是否显示取色策略切换按钮
   * 手表设备隐藏此功能
   */
  public shouldShowColorStrategyButton(): boolean {
    return !this.isWearable();
  }

  /**
   * 获取Swiper间距
   */
  public getSwiperItemSpace(): number {
    if (this.isWearable()) {
      return 5;
    }
    return 10;
  }

  /**
   * 获取Swiper自动播放间隔
   */
  public getSwiperInterval(): number {
    // 手表设备延长间隔，避免操作过快
    if (this.isWearable()) {
      return 4000;
    }
    return 3500;
  }
  
  /**
   * 设置模拟设备类型（用于测试）
   * @param deviceType 要模拟的设备类型
   */
  public setSimulatedDeviceType(deviceType: DeviceType): void {
    this.isSimulatedDevice = true;
    this.simulatedDeviceType = deviceType;
    this.sizeConfig = this.initSizeConfig();
  }
  
  /**
   * 清除模拟设备类型，恢复真实设备类型
   */
  public clearSimulatedDeviceType(): void {
    this.isSimulatedDevice = false;
    this.simulatedDeviceType = null;
    this.sizeConfig = this.initSizeConfig();
  }
  
  /**
   * 获取当前使用的设备类型（可能是模拟的）
   */
  public getEffectiveDeviceType(): DeviceType {
    if (this.isSimulatedDevice && this.simulatedDeviceType) {
      return this.simulatedDeviceType;
    }
    return this.currentDeviceType;
  }
  
  /**
   * 是否正在使用模拟设备类型
   */
  public isUsingSimulatedDevice(): boolean {
    return this.isSimulatedDevice;
  }
  
  /**
   * 获取所有可用的设备类型列表（用于测试）
   */
  public static getAvailableDeviceTypes(): DeviceType[] {
    return [
      DeviceType.PHONE,
      DeviceType.TABLET,
      DeviceType.TWO_IN_ONE,
      DeviceType.TV,
      DeviceType.WEARABLE
    ];
  }
  
  /**
   * 获取设备类型的显示名称
   */
  public static getDeviceTypeDisplayName(deviceType: DeviceType): string {
    const displayNameMap: Record<DeviceType, string> = {
      [DeviceType.PHONE]: '手机',
      [DeviceType.TABLET]: '平板',
      [DeviceType.TWO_IN_ONE]: '2合1设备',
      [DeviceType.TV]: '电视',
      [DeviceType.WEARABLE]: '手表',
      [DeviceType.DEFAULT]: '默认'
    };
    return displayNameMap[deviceType] || '未知';
  }
}
