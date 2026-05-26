import type { UIContext } from "@ohos:arkui.UIContext";
import window from "@ohos:window";
import type { BusinessError } from "@ohos:base";
import hilog from "@ohos:hilog";
export enum ImmersiveType {
    NORMAL = 0,
    IMMERSIVE = 1
}
export class WindowUtil {
    public uiContext?: UIContext;
    public mainWindow: window.Window;
    constructor(mainWindow: window.Window) {
        this.mainWindow = mainWindow;
    }
    public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
        this.setImmersiveType(statusType === window.WindowStatusType.MAXIMIZE || window.WindowStatusType.FLOATING ?
            ImmersiveType.IMMERSIVE : ImmersiveType.NORMAL);
    };
    /**
     * 设置沉浸式类型
     * @param type 沉浸式类型
     */
    setImmersiveType(type: ImmersiveType) {
        try {
            if (type === ImmersiveType.NORMAL) {
                this.mainWindow.setWindowDecorVisible(true);
                this.release();
            }
            else if (type === ImmersiveType.IMMERSIVE) {
                // Set window decor visible
                this.mainWindow.setWindowDecorVisible(false);
                // Set window decor height
                this.mainWindow.setWindowDecorHeight(56);
                // Set window decor button style
                this.mainWindow.setDecorButtonStyle({ buttonIconSize: 24 });
            }
        }
        catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'TestLog', `Failed to set immersive type. Code: ${err.code}, message: ${err.message}`);
        }
    }
    /**
     * 设置状态栏内容颜色（深色/浅色文字）
     * @param isDarkContent 是否使用深色文字（true=深色文字，false=浅色文字）
     */
    setStatusBarContentColor(isDarkContent: boolean): void {
        try {
            // 设置状态栏、导航栏的内容颜色
            // isDarkContent: true 表示状态栏内容为深色（用于浅色背景）
            // isDarkContent: false 表示状态栏内容为浅色（用于深色背景）
            this.mainWindow.setWindowSystemBarEnable(['status', 'navigation']);
            // 设置系统栏属性
            const systemBarProperties: window.SystemBarProperties = {
                statusBarColor: '#00000000',
                statusBarContentColor: isDarkContent ? '#FF000000' : '#FFFFFFFF',
                navigationBarColor: '#00000000',
                navigationBarContentColor: isDarkContent ? '#FF000000' : '#FFFFFFFF' // 导航栏内容颜色
            };
            this.mainWindow.setWindowSystemBarProperties(systemBarProperties);
        }
        catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'WindowUtil', `Failed to set status bar color. Code: ${err.code}, message: ${err.message}`);
        }
    }
    /**
     * 根据背景色亮度自动设置状态栏内容颜色
     * @param bgColor 背景颜色（十六进制格式）
     */
    setStatusBarColorByBgColor(bgColor: string): void {
        // 解析颜色并计算亮度
        const luminance = this.calculateLuminance(bgColor);
        // 亮度 > 0.5 表示浅色背景，使用深色文字
        // 亮度 <= 0.5 表示深色背景，使用浅色文字
        this.setStatusBarContentColor(luminance > 0.5);
    }
    /**
     * 计算颜色亮度（WCAG标准）
     * @param hexColor 十六进制颜色字符串
     * @returns 亮度值 (0-1)
     */
    private calculateLuminance(hexColor: string): number {
        try {
            // 移除#号
            let hex = hexColor.replace('#', '');
            // 处理ARGB格式（8位）
            let r: number, g: number, b: number;
            if (hex.length === 8) {
                r = parseInt(hex.substring(2, 4), 16);
                g = parseInt(hex.substring(4, 6), 16);
                b = parseInt(hex.substring(6, 8), 16);
            }
            else if (hex.length === 6) {
                r = parseInt(hex.substring(0, 2), 16);
                g = parseInt(hex.substring(2, 4), 16);
                b = parseInt(hex.substring(4, 6), 16);
            }
            else {
                return 0.5; // 默认中等亮度
            }
            // 计算相对亮度
            const rsrgb = r / 255;
            const gsrgb = g / 255;
            const bsrgb = b / 255;
            const rLinear = rsrgb <= 0.03928 ? rsrgb / 12.92 : Math.pow((rsrgb + 0.055) / 1.055, 2.4);
            const gLinear = gsrgb <= 0.03928 ? gsrgb / 12.92 : Math.pow((gsrgb + 0.055) / 1.055, 2.4);
            const bLinear = bsrgb <= 0.03928 ? bsrgb / 12.92 : Math.pow((bsrgb + 0.055) / 1.055, 2.4);
            return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
        }
        catch (error) {
            return 0.5;
        }
    }
    startWindowStatusListener(): void {
        try {
            this.mainWindow.on('windowStatusChange', this.onStatusTypeChange);
        }
        catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, `TestLog`, `Failed to update window status. Code: ${err.code}, message: ${err.message}`);
        }
    }
    release(): void {
        try {
            this.mainWindow.off('windowStatusChange');
        }
        catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'TestLog', `Failed to off. Code: ${err.code}, message: ${err.message}`);
        }
    }
}
