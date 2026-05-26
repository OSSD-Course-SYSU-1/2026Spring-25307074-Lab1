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

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  private windowUtil?: WindowUtil;
  private windowObj?: window.Window;
  private uiContext?: UIContext;
  public static readonly KEY_CURRENT_WIDTH_BREAKPOINT: string = CommonConstants.KEY_PREFIX + 'currentWidthBreakpoint';
  public static readonly KEY_WINDOW_UTIL: string = CommonConstants.KEY_PREFIX + 'windowUtil';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
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
}
