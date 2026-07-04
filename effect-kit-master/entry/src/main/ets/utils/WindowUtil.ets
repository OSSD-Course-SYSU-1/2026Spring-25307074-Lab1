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

import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export enum ImmersiveType {
  NORMAL,
  IMMERSIVE
}

export class WindowUtil {
  public uiContext?: UIContext;
  public mainWindow: window.Window;

  constructor(mainWindow: window.Window) {
    this.mainWindow = mainWindow;
  }

  public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
    this.setImmersiveType(statusType === window.WindowStatusType.MAXIMIZE || statusType === window.WindowStatusType.FLOATING ?
      ImmersiveType.IMMERSIVE : ImmersiveType.NORMAL)
  }

  setImmersiveType(type: ImmersiveType) {
    try {
      if (type === ImmersiveType.NORMAL) {
        this.mainWindow.setWindowDecorVisible(true);
        this.release();
      } else if (type === ImmersiveType.IMMERSIVE) {
        // Set window decor visible
        this.mainWindow.setWindowDecorVisible(false);
        // Set window decor height
        this.mainWindow.setWindowDecorHeight(56);
        // Set window decor button style
        this.mainWindow.setDecorButtonStyle({ buttonIconSize: 24 });
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to set immersive type. Code: ${err.code}, message: ${err.message}`);
    }
  }

  startWindowStatusListener(): void {
    try {
      this.mainWindow.on('windowStatusChange', this.onStatusTypeChange);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, `TestLog`, `Failed to update window status. Code: ${err.code}, message: ${err.message}`);
    }
  }

  release(): void {
    try {
      this.mainWindow.off('windowStatusChange');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to off. Code: ${err.code}, message: ${err.message}`);
    }
  }
}
