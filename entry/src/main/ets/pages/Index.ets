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
 * Index - 优化后的自适应背景色主页
 * 
 * 优化内容：
 * 1. 使用智能取色策略，避免平均色偏灰问题
 * 2. 背景色平滑渐变过渡动画
 * 3. 图片手动切换功能
 * 4. 图片加载状态处理
 * 5. 沉浸式状态栏动态适配
 * 6. 深色模式适配
 */

import { window } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { effectKit } from '@kit.ArkGraphics2D';
import CommonConstants from '../constants/CommonContants';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import Logger from '../utils/Logger';
import { ImmersiveType, WindowUtil } from '../utils/WindowUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import {
  ColorPickerUtil,
  ColorExtractStrategy,
  ColorInfo,
  ColorExtractResult
} from '../utils/ColorPickerUtil';

const TAG: string = '[Index]';

/** 图片加载状态枚举 */
enum ImageLoadState {
  LOADING,
  SUCCESS,
  ERROR
}

/** 图片项接口 */
interface ImageItem {
  resource: Resource;
  loadState: ImageLoadState;
}

@Entry
@Component
struct Index {
  // 图片数据 - 初始状态为SUCCESS，图片会直接显示
  @State imgData: ImageItem[] = [
    { resource: $r('app.media.image1'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image2'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image3'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image4'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image5'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image6'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image7'), loadState: ImageLoadState.SUCCESS },
    { resource: $r('app.media.image8'), loadState: ImageLoadState.SUCCESS },
  ];
  
  // 当前背景色（用于渐变）
  @State currentBgColor: string = CommonConstants.START_WINDOW_BACKGROUND;
  // 目标背景色（用于渐变动画）
  @State targetBgColor: string = CommonConstants.START_WINDOW_BACKGROUND;
  // 当前Swiper索引
  @State currentIndex: number = 0;
  // 安全区域高度
  @State topSafeHeight: number = 0;
  @State bottomSafeHeight: number = 0;
  // 设备类型
  @State is2in1Device: boolean = false;
  // 是否为深色模式
  @State isDarkMode: boolean = false;
  // 状态栏文字颜色（根据背景色动态调整）
  @State statusBarTextColor: string = '#FF000000';
  // 是否正在处理颜色提取
  private isProcessingColor: boolean = false;
  
  // Swiper控制器
  private swiperController: SwiperController = new SwiperController();
  // 配置参数
  private swiperInterval: number = CommonConstants.SWIPER_INTERVAL;
  private swiperDuration: number = CommonConstants.SWIPER_DURATION;
  private swiperItemSpace: number = CommonConstants.SWIPER_ITEM_SPACE;
  // 上下文
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // 响应式断点
  @StorageLink(CommonConstants.KEY_PREFIX + 'currentWidthBreakpoint') currentWidthBreakpoint: string = 'md';
  @StorageLink(CommonConstants.KEY_PREFIX + 'windowUtil') windowUtil: WindowUtil | undefined = undefined;
  
  // 取色策略（可通过UI切换）
  @State colorStrategy: ColorExtractStrategy = ColorExtractStrategy.SMART;

  async aboutToAppear() {
    Logger.info(TAG, 'aboutToAppear start');
    
    // 初始化设备信息
    this.is2in1Device = deviceInfo.deviceType === '2in1';
    
    // 初始化深色模式状态
    this.initDarkMode();
    
    // 设置沉浸式状态栏
    this.windowUtil?.setImmersiveType(ImmersiveType.IMMERSIVE);
    this.windowUtil?.startWindowStatusListener();
    
    // 初始化窗口信息
    await this.initWindowInfo();
    
    // 加载第一张图片的颜色
    await this.loadImageColor(0);
  }

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear');
    this.windowUtil?.setImmersiveType(ImmersiveType.NORMAL);
    this.windowUtil?.release();
    AppStorage.delete(CommonConstants.KEY_PREFIX + 'currentWidthBreakpoint');
    AppStorage.delete(CommonConstants.KEY_PREFIX + 'windowUtil');
  }

  /**
   * 初始化深色模式状态
   */
  private initDarkMode(): void {
    try {
      const config = this.context.resourceManager.getConfigurationSync();
      // 使用数值比较判断深色模式
      this.isDarkMode = config.colorMode === 1; // 1: COLOR_MODE_DARK, 0: COLOR_MODE_LIGHT
      Logger.info(TAG, `isDarkMode: ${this.isDarkMode}`);
    } catch (error) {
      Logger.error(TAG, `initDarkMode failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 初始化窗口信息
   */
  private async initWindowInfo(): Promise<void> {
    try {
      let windowHeight: window.Window = await window.getLastWindow(this.context);
      await windowHeight.setWindowLayoutFullScreen(true);
      this.topSafeHeight = this.getUIContext().px2vp(
        windowHeight.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
      );
      this.bottomSafeHeight = this.getUIContext().px2vp(
        windowHeight.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
      );
    } catch (error) {
      Logger.error(TAG, `initWindowInfo failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 加载指定索引图片的颜色
   * @param index 图片索引
   */
  private async loadImageColor(index: number): Promise<void> {
    if (this.isProcessingColor || index < 0 || index >= this.imgData.length) {
      return;
    }
    
    this.isProcessingColor = true;
    
    try {
      // 获取图片PixelMap
      const pixelMap = await this.getPixelMapFromResource(this.imgData[index].resource);
      if (!pixelMap) {
        Logger.error(TAG, 'Failed to get pixelMap');
        this.isProcessingColor = false;
        return;
      }

      // 使用ColorPickerUtil提取颜色
      const result: ColorExtractResult = await ColorPickerUtil.extractColorFromPixelMap(
        pixelMap,
        this.colorStrategy
      );

      // 根据深色模式调整颜色
      let finalColor = ColorPickerUtil.adjustColorForTheme(result.color, this.isDarkMode);
      let finalHex = ColorPickerUtil.colorToHex(finalColor);

      // 更新状态栏文字颜色
      this.statusBarTextColor = ColorPickerUtil.getContrastColor(finalColor);

      // 使用动画过渡到新颜色
      this.transitionToNewColor(finalHex);

      // 释放资源
      pixelMap.release();
      
      // 更新图片加载状态
      this.imgData[index].loadState = ImageLoadState.SUCCESS;

      Logger.info(TAG, `Color extracted: ${finalHex}, confidence: ${result.confidence}`);

    } catch (error) {
      Logger.error(TAG, `loadImageColor failed: ${JSON.stringify(error)}`);
      this.imgData[index].loadState = ImageLoadState.ERROR;
    } finally {
      this.isProcessingColor = false;
    }
  }

  /**
   * 从Resource获取PixelMap
   */
  private async getPixelMapFromResource(resource: Resource): Promise<image.PixelMap | null> {
    try {
      const resourceMgr: resourceManager.ResourceManager = this.context.resourceManager;
      const fileData: Uint8Array = await resourceMgr.getMediaContent(resource.id);
      const buffer = fileData.buffer as ArrayBuffer;
      const imageSource: image.ImageSource = image.createImageSource(buffer);
      const pixelMap: image.PixelMap = await imageSource.createPixelMap();
      imageSource.release();
      return pixelMap;
    } catch (error) {
      Logger.error(TAG, `getPixelMapFromResource failed: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 使用动画过渡到新颜色
   */
  private transitionToNewColor(newColor: string): void {
    this.targetBgColor = newColor;
    
    this.getUIContext().animateTo({
      duration: CommonConstants.COLOR_TRANSITION_DURATION,
      curve: CommonConstants.COLOR_TRANSITION_CURVE,
      onFinish: () => {
        this.currentBgColor = this.targetBgColor;
      }
    }, () => {
      this.currentBgColor = newColor;
    });
  }

  /**
   * 手动切换到上一张图片
   */
  private showPreviousImage(): void {
    this.swiperController.showPrevious();
  }

  /**
   * 手动切换到下一张图片
   */
  private showNextImage(): void {
    this.swiperController.showNext();
  }

  /**
   * 切换取色策略
   */
  private cycleColorStrategy(): void {
    const strategies = [
      ColorExtractStrategy.SMART,
      ColorExtractStrategy.MAIN_COLOR,
      ColorExtractStrategy.LARGEST_PROPORTION,
      ColorExtractStrategy.HIGHEST_SATURATION,
      ColorExtractStrategy.TOP_PROPORTION
    ];
    const currentIndex = strategies.indexOf(this.colorStrategy);
    this.colorStrategy = strategies[(currentIndex + 1) % strategies.length];
    
    // 重新提取当前图片颜色
    this.loadImageColor(this.currentIndex);
  }

  build() {
    Column() {
      // 顶部状态栏占位
      Row()
        .width('100%')
        .height(this.topSafeHeight)
        .backgroundColor(this.currentBgColor)

      // Swiper图片轮播
      Stack({ alignContent: Alignment.Center }) {
        Swiper(this.swiperController) {
          ForEach(this.imgData, (item: ImageItem, index: number) => {
            this.ImageItemBuilder(item, index);
          }, (item: ImageItem, index: number) => index.toString())
        }
        .width(CommonConstants.FULL_PARENT)
        .height(this.currentWidthBreakpoint === 'lg' || this.currentWidthBreakpoint === 'xl' 
          ? 'calc(100% - 16vp)' : 'auto')
        .padding({ left: $r('app.integer.swiper_padding_left'), right: $r('app.integer.swiper_padding_right') })
        .autoPlay(true)
        .interval(this.swiperInterval)
        .duration(this.swiperDuration)
        .loop(true)
        .itemSpace(this.swiperItemSpace)
        .indicator(false)
        .onChange((index: number) => {
          this.currentIndex = index;
          this.loadImageColor(index);
        })

        // 左右切换按钮
        Row() {
          // 左箭头
          Button({ type: ButtonType.Circle }) {
            Text('<')
              .fontColor(Color.White)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
          }
          .width(40)
          .height(40)
          .backgroundColor('#66000000')
          .onClick(() => this.showPreviousImage())

          Blank().layoutWeight(1)

          // 右箭头
          Button({ type: ButtonType.Circle }) {
            Text('>')
              .fontColor(Color.White)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
          }
          .width(40)
          .height(40)
          .backgroundColor('#66000000')
          .onClick(() => this.showNextImage())
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)

      // 底部指示器和控制区
      Row() {
        // 页码指示
        Text(`${this.currentIndex + 1} / ${this.imgData.length}`)
          .fontColor(Color.White)
          .fontSize(14)

        Blank().layoutWeight(1)

        // 取色策略切换按钮
        Button(this.getStrategyName())
          .fontSize(12)
          .height(32)
          .backgroundColor('#66000000')
          .onClick(() => this.cycleColorStrategy())
      }
      .width('100%')
      .height(50)
      .padding({ left: 20, right: 20 })
      .backgroundColor(this.currentBgColor)

      // 底部安全区域
      Row()
        .width('100%')
        .height(this.bottomSafeHeight)
        .backgroundColor(this.currentBgColor)
    }
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        [this.currentBgColor, CommonConstants.START_GRADIENT_RANGE],
        [this.isDarkMode ? '#FF1A1A1A' : Color.White, CommonConstants.END_GRADIENT_RANGE]
      ]
    })
  }

  /**
   * 图片项构建器
   */
  @Builder
  ImageItemBuilder(item: ImageItem, index: number) {
    Stack() {
      if (item.loadState === ImageLoadState.LOADING) {
        // 加载中状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(Color.White)
          Text('加载中...')
            .fontColor(Color.White)
            .fontSize(14)
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(CommonConstants.LOADING_BG_COLOR)
        .borderRadius($r('app.integer.image_borderRadius'))
      } else if (item.loadState === ImageLoadState.ERROR) {
        // 加载失败状态
        Column() {
          Text('加载失败')
            .fontColor(Color.Red)
            .fontSize(16)
          Button('重试')
            .margin({ top: 10 })
            .onClick(() => {
              item.loadState = ImageLoadState.LOADING;
              this.loadImageColor(index);
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(CommonConstants.ERROR_BG_COLOR)
        .borderRadius($r('app.integer.image_borderRadius'))
      } else {
        // 加载成功
        Image(item.resource)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius($r('app.integer.image_borderRadius'))
          .onComplete(() => {
            if (item.loadState === ImageLoadState.LOADING) {
              item.loadState = ImageLoadState.SUCCESS;
            }
          })
          .onError(() => {
            item.loadState = ImageLoadState.ERROR;
          })
      }
    }
    .width('100%')
    .height('100%')
    .margin({
      top: this.is2in1Device ? $r('app.integer.image_margin_big_top') : $r('app.integer.image_margin_top')
    })
  }

  /**
   * 获取当前取色策略名称
   */
  private getStrategyName(): string {
    switch (this.colorStrategy) {
      case ColorExtractStrategy.SMART:
        return '智能取色';
      case ColorExtractStrategy.MAIN_COLOR:
        return '主色调';
      case ColorExtractStrategy.LARGEST_PROPORTION:
        return '占比最多';
      case ColorExtractStrategy.HIGHEST_SATURATION:
        return '饱和度最高';
      case ColorExtractStrategy.TOP_PROPORTION:
        return '前N颜色';
      default:
        return '智能取色';
    }
  }
}
