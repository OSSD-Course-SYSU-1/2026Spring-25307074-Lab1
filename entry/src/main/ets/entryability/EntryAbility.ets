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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import Logger from '../utils/Logger';
import { WindowUtil } from '../utils/WindowUtil';
import CommonConstants from '../constants/CommonContants';
import MigrationStateManager, { MigrationState } from '../utils/MigrationStateManager';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  private windowUtil?: WindowUtil;
  private windowObj?: window.Window;
  private uiContext?: UIContext;
  public static readonly KEY_CURRENT_WIDTH_BREAKPOINT: string = CommonConstants.KEY_PREFIX + 'currentWidthBreakpoint';
  public static readonly KEY_WINDOW_UTIL: string = CommonConstants.KEY_PREFIX + 'windowUtil';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    
    // 检查是否为迁移启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      Logger.info(TAG, 'Launched by migration in onCreate');
      this.handleMigrationRestore(want);
    }
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();

    Logger.info(TAG, 'widthBp & heightBp:' + widthBp + ',' + heightBp);

    AppStorage.setOrCreate(EntryAbility.KEY_CURRENT_WIDTH_BREAKPOINT,
      widthBp === 0 ? 'xs' : widthBp === 1 ? 'sm' : widthBp === 2 ? 'md' : widthBp === 3 ? 'lg' : 'xl');

    // Application adaptation for horizontal and vertical screen switching.
    this.windowObj?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to setPreferredOrientation. code = ${err.code}, message = ${err.message}`);
    });
  };

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      this.windowUtil = new WindowUtil(windowStage.getMainWindowSync());
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to get main window. code = ${err.code}, message = ${err.message}`);
    }
    AppStorage.setOrCreate(EntryAbility.KEY_WINDOW_UTIL, this.windowUtil);
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    windowStage.getMainWindow().then((windowObj) => {
      this.windowObj = windowObj;
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to obtain the main window. code = ${err.code}, message = ${err.message}`);
    });
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. code = ${err.code}, message = ${err.message}`);
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      try {
        this.uiContext = this.windowObj!.getUIContext();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to getUIContext. code = ${err.code}, message = ${err.message}`);
      }
      windowStage.getMainWindow().then((data: window.Window) => {
        let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
        let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
        Logger.info(TAG, 'widthBp & heightBp:' + widthBp + ',' + heightBp);
        AppStorage.setOrCreate(EntryAbility.KEY_CURRENT_WIDTH_BREAKPOINT,
          widthBp === 0 ? 'xs' : widthBp === 1 ? 'sm' : widthBp === 2 ? 'md' : widthBp === 3 ? 'lg' : 'xl');
        data.on('windowSizeChange', this.onWindowSizeChange);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to obtain the main window. code = ${err.code}, message = ${err.message}`);
      });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  /**
   * 跨端迁移回调 - 保存状态
   * 当应用迁移到其他设备时触发，需要保存当前业务状态
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    Logger.info(TAG, 'onContinue triggered for migration');
    
    try {
      // 获取迁移状态管理器
      const migrationManager = MigrationStateManager.getInstance();
      
      // 从AppStorage获取当前状态
      const currentIndex = AppStorage.get<number>('current_image_index') || 0;
      const imageCount = AppStorage.get<number>('image_count') || 8;
      const currentBgColor = AppStorage.get<string>('current_bg_color') || '#FFD4D4D4';
      const targetBgColor = AppStorage.get<string>('target_bg_color') || '#FFD4D4D4';
      const colorStrategy = AppStorage.get<string>('color_strategy') || 'SMART';
      const imageScale = AppStorage.get<number>('image_scale') || 1.0;
      const isAutoPlay = AppStorage.get<boolean>('is_auto_play') || true;
      const swiperInterval = AppStorage.get<number>('swiper_interval') || 3500;
      
      // 构造迁移状态
      const migrationState: MigrationState = {
        currentIndex: currentIndex,
        imageCount: imageCount,
        currentBgColor: currentBgColor,
        targetBgColor: targetBgColor,
        colorStrategy: colorStrategy,
        imageScale: imageScale,
        isAutoPlay: isAutoPlay,
        swiperInterval: swiperInterval,
        timestamp: Date.now()
      };
      
      // 保存状态并序列化
      const stateString = migrationManager.saveMigrationState(migrationState);
      
      if (stateString && stateString.length > 0) {
        // 将状态数据存入wantParam，传递给目标设备
        wantParam['migration_data'] = stateString;
        Logger.info(TAG, `Migration state saved successfully, size: ${stateString.length}`);
        return AbilityConstant.OnContinueResult.AGREE;
      } else {
        Logger.error(TAG, 'Failed to save migration state');
        return AbilityConstant.OnContinueResult.REJECT;
      }
    } catch (error) {
      Logger.error(TAG, `onContinue failed: ${JSON.stringify(error)}`);
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }

  /**
   * 新Want启动回调
   * 当通过迁移启动或其他方式启动时触发
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'onNewWant triggered');
    
    // 检查是否为迁移启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      Logger.info(TAG, 'Launched by migration');
      this.handleMigrationRestore(want);
    }
  }

  /**
   * 处理迁移恢复
   */
  private handleMigrationRestore(want: Want): void {
    try {
      const migrationManager = MigrationStateManager.getInstance();
      
      // 从want参数中获取迁移数据
      const migrationData = want.parameters?.['migration_data'] as string;
      
      if (migrationData && migrationData.length > 0) {
        // 恢复迁移状态
        const result = migrationManager.restoreMigrationState(migrationData);
        
        if (result.success) {
          Logger.info(TAG, 'Migration restore successful');
        } else {
          Logger.error(TAG, `Migration restore failed: ${result.message}`);
        }
      } else {
        Logger.warn(TAG, 'No migration data found in want');
      }
    } catch (error) {
      Logger.error(TAG, `handleMigrationRestore failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 保存状态回调（用于分布式数据同步）
   */
  onSaveState(reason: AbilityConstant.StateType, wantParam: Record<string, Object>): AbilityConstant.OnSaveResult {
    Logger.info(TAG, `onSaveState triggered, reason: ${reason}`);
    
    try {
      const migrationManager = MigrationStateManager.getInstance();
      
      // 获取当前状态
      const currentIndex = AppStorage.get<number>('current_image_index') || 0;
      const imageCount = AppStorage.get<number>('image_count') || 8;
      const currentBgColor = AppStorage.get<string>('current_bg_color') || '#FFD4D4D4';
      const targetBgColor = AppStorage.get<string>('target_bg_color') || '#FFD4D4D4';
      const colorStrategy = AppStorage.get<string>('color_strategy') || 'SMART';
      const imageScale = AppStorage.get<number>('image_scale') || 1.0;
      const isAutoPlay = AppStorage.get<boolean>('is_auto_play') || true;
      const swiperInterval = AppStorage.get<number>('swiper_interval') || 3500;
      
      const migrationState: MigrationState = {
        currentIndex: currentIndex,
        imageCount: imageCount,
        currentBgColor: currentBgColor,
        targetBgColor: targetBgColor,
        colorStrategy: colorStrategy,
        imageScale: imageScale,
        isAutoPlay: isAutoPlay,
        swiperInterval: swiperInterval,
        timestamp: Date.now()
      };
      
      const stateString = migrationManager.saveMigrationState(migrationState);
      
      if (stateString && stateString.length > 0) {
        wantParam['saved_state'] = stateString;
        Logger.info(TAG, 'State saved successfully');
        return 0; // AbilityConstant.OnSaveResult.ALL_SAVED
      } else {
        Logger.error(TAG, 'Failed to save state');
        return 2; // AbilityConstant.OnSaveResult.NOT_SAVED
      }
    } catch (error) {
      Logger.error(TAG, `onSaveState failed: ${JSON.stringify(error)}`);
      return 2; // AbilityConstant.OnSaveResult.NOT_SAVED
    }
  }
}
