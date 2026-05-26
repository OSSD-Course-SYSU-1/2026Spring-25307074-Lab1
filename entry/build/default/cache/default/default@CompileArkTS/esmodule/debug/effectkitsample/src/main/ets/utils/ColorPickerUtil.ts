import effectKit from "@ohos:effectKit";
import type image from "@ohos:multimedia.image";
import type { BusinessError } from "@ohos:base";
import Logger from "@bundle:com.example.effectkit/effectkitsample/ets/utils/Logger";
const TAG: string = '[ColorPickerUtil]';
/** 颜色对象接口 */
export interface ColorInfo {
    red: number;
    green: number;
    blue: number;
    alpha: number;
}
/** HSL颜色接口 */
interface HslColor {
    h: number;
    s: number;
    l: number;
}
/** RGB颜色接口 */
interface RgbColor {
    r: number;
    g: number;
    b: number;
}
/** 取色策略枚举 */
export enum ColorExtractStrategy {
    MAIN_COLOR = 0,
    LARGEST_PROPORTION = 1,
    TOP_PROPORTION = 2,
    AVERAGE_COLOR = 3,
    HIGHEST_SATURATION = 4,
    SMART = 5
}
/** 取色结果接口 */
export interface ColorExtractResult {
    color: ColorInfo;
    hex: string;
    strategy: ColorExtractStrategy;
    confidence: number;
}
/** 智能取色结果接口 */
interface SmartExtractResult {
    color: effectKit.Color;
    confidence: number;
}
/**
 * 颜色工具类
 * 提供多种图片取色策略和颜色处理功能
 */
export class ColorPickerUtil {
    /**
     * 从PixelMap中提取颜色（核心方法）
     * @param pixelMap 图片像素数据
     * @param strategy 取色策略，默认使用智能策略
     * @returns 取色结果Promise
     */
    static async extractColorFromPixelMap(pixelMap: image.PixelMap, strategy: ColorExtractStrategy = ColorExtractStrategy.SMART): Promise<ColorExtractResult> {
        try {
            const colorPicker = await ColorPickerUtil.createColorPicker(pixelMap);
            let color: effectKit.Color;
            let confidence = 1.0;
            switch (strategy) {
                case ColorExtractStrategy.MAIN_COLOR:
                    color = colorPicker.getMainColorSync();
                    confidence = 0.9;
                    break;
                case ColorExtractStrategy.LARGEST_PROPORTION:
                    color = colorPicker.getLargestProportionColor();
                    confidence = 0.85;
                    break;
                case ColorExtractStrategy.TOP_PROPORTION:
                    color = ColorPickerUtil.extractTopColorsWeighted(colorPicker);
                    confidence = 0.8;
                    break;
                case ColorExtractStrategy.AVERAGE_COLOR:
                    color = colorPicker.getAverageColor();
                    confidence = 0.6;
                    break;
                case ColorExtractStrategy.HIGHEST_SATURATION:
                    color = colorPicker.getHighestSaturationColor();
                    confidence = 0.75;
                    break;
                case ColorExtractStrategy.SMART:
                    const smartResult = ColorPickerUtil.extractSmartColor(colorPicker);
                    color = smartResult.color;
                    confidence = smartResult.confidence;
                    break;
                default:
                    color = colorPicker.getMainColorSync();
                    confidence = 0.9;
            }
            const colorInfo: ColorInfo = {
                red: color.red,
                green: color.green,
                blue: color.blue,
                alpha: color.alpha
            };
            return {
                color: colorInfo,
                hex: ColorPickerUtil.colorToHex(colorInfo),
                strategy: strategy,
                confidence: confidence
            };
        }
        catch (error) {
            const err = error as BusinessError;
            Logger.error(TAG, `Failed to extract color. code = ${err.code}, message = ${err.message}`);
            return ColorPickerUtil.getDefaultResult(strategy);
        }
    }
    /**
     * 创建ColorPicker实例（Promise封装）
     */
    private static createColorPicker(pixelMap: image.PixelMap): Promise<effectKit.ColorPicker> {
        return new Promise((resolve, reject) => {
            effectKit.createColorPicker(pixelMap, (err: BusinessError, colorPicker: effectKit.ColorPicker) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(colorPicker);
                }
            });
        });
    }
    /**
     * 智能取色策略
     */
    private static extractSmartColor(colorPicker: effectKit.ColorPicker): SmartExtractResult {
        const mainColor = colorPicker.getMainColorSync();
        const largestColor = colorPicker.getLargestProportionColor();
        const saturationColor = colorPicker.getHighestSaturationColor();
        const mainScore = ColorPickerUtil.scoreColor(mainColor);
        const largestScore = ColorPickerUtil.scoreColor(largestColor);
        const saturationScore = ColorPickerUtil.scoreColor(saturationColor);
        let bestColor: effectKit.Color;
        let confidence: number;
        if (mainScore >= largestScore && mainScore >= saturationScore) {
            bestColor = mainColor;
            confidence = 0.9;
        }
        else if (largestScore >= saturationScore) {
            bestColor = largestColor;
            confidence = 0.85;
        }
        else {
            bestColor = saturationColor;
            confidence = 0.8;
        }
        bestColor = ColorPickerUtil.optimizeColor(bestColor);
        const result: SmartExtractResult = {
            color: bestColor,
            confidence: confidence
        };
        return result;
    }
    /**
     * 前N颜色加权平均
     */
    private static extractTopColorsWeighted(colorPicker: effectKit.ColorPicker): effectKit.Color {
        const topColors = colorPicker.getTopProportionColors(3);
        if (topColors.length === 0 || !topColors[0]) {
            return colorPicker.getMainColorSync();
        }
        return topColors[0]!;
    }
    /**
     * 颜色评分函数
     */
    private static scoreColor(color: effectKit.Color): number {
        const hsl = ColorPickerUtil.rgbToHsl(color.red, color.green, color.blue);
        const saturationScore = Math.min(1, hsl.s * 1.5);
        let brightnessScore: number;
        if (hsl.l < 0.3) {
            brightnessScore = hsl.l / 0.3 * 0.7;
        }
        else if (hsl.l > 0.7) {
            brightnessScore = (1 - hsl.l) / 0.3 * 0.7;
        }
        else {
            brightnessScore = 1.0;
        }
        return saturationScore * 0.6 + brightnessScore * 0.4;
    }
    /**
     * 优化颜色
     */
    private static optimizeColor(color: effectKit.Color): effectKit.Color {
        const hsl = ColorPickerUtil.rgbToHsl(color.red, color.green, color.blue);
        hsl.s = Math.min(1, hsl.s * 1.2 + 0.1);
        if (hsl.l < 0.3) {
            hsl.l = 0.3 + hsl.l * 0.3;
        }
        else if (hsl.l > 0.8) {
            hsl.l = 0.8 - (1 - hsl.l) * 0.3;
        }
        const rgb = ColorPickerUtil.hslToRgb(hsl.h, hsl.s, hsl.l);
        const result: effectKit.Color = {
            red: rgb.r,
            green: rgb.g,
            blue: rgb.b,
            alpha: color.alpha
        };
        return result;
    }
    /**
     * RGB转HSL
     */
    private static rgbToHsl(r: number, g: number, b: number): HslColor {
        r /= 255;
        g /= 255;
        b /= 255;
        const max = Math.max(r, g, b);
        const min = Math.min(r, g, b);
        let h = 0;
        let s = 0;
        let l = (max + min) / 2;
        if (max !== min) {
            const d = max - min;
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            switch (max) {
                case r:
                    h = (g - b) / d + (g < b ? 6 : 0);
                    break;
                case g:
                    h = (b - r) / d + 2;
                    break;
                case b:
                    h = (r - g) / d + 4;
                    break;
            }
            h /= 6;
        }
        const result: HslColor = { h: h, s: s, l: l };
        return result;
    }
    /**
     * HSL转RGB
     */
    private static hslToRgb(h: number, s: number, l: number): RgbColor {
        let r: number;
        let g: number;
        let b: number;
        if (s === 0) {
            r = l;
            g = l;
            b = l;
        }
        else {
            const hue2rgb = (p: number, q: number, t: number): number => {
                let newT = t;
                if (newT < 0) {
                    newT += 1;
                }
                if (newT > 1) {
                    newT -= 1;
                }
                if (newT < 1 / 6) {
                    return p + (q - p) * 6 * newT;
                }
                if (newT < 1 / 2) {
                    return q;
                }
                if (newT < 2 / 3) {
                    return p + (q - p) * (2 / 3 - newT) * 6;
                }
                return p;
            };
            const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
            const p = 2 * l - q;
            r = hue2rgb(p, q, h + 1 / 3);
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - 1 / 3);
        }
        const result: RgbColor = {
            r: Math.round(r * 255),
            g: Math.round(g * 255),
            b: Math.round(b * 255)
        };
        return result;
    }
    /**
     * 颜色对象转十六进制字符串
     */
    static colorToHex(color: ColorInfo): string {
        const alpha = color.alpha.toString(16).padStart(2, '0');
        const red = color.red.toString(16).padStart(2, '0');
        const green = color.green.toString(16).padStart(2, '0');
        const blue = color.blue.toString(16).padStart(2, '0');
        return `#${alpha}${red}${green}${blue}`.toUpperCase();
    }
    /**
     * 十六进制字符串转颜色对象
     */
    static hexToColor(hex: string): ColorInfo {
        let hexValue = hex.replace('#', '');
        if (hexValue.length === 3) {
            hexValue = hexValue.split('').map((c: string) => c + c).join('');
        }
        else if (hexValue.length === 4) {
            hexValue = hexValue.split('').map((c: string) => c + c).join('');
        }
        if (hexValue.length === 6) {
            hexValue = 'FF' + hexValue;
        }
        const result: ColorInfo = {
            alpha: parseInt(hexValue.substring(0, 2), 16),
            red: parseInt(hexValue.substring(2, 4), 16),
            green: parseInt(hexValue.substring(4, 6), 16),
            blue: parseInt(hexValue.substring(6, 8), 16)
        };
        return result;
    }
    /**
     * 计算颜色相对亮度 (WCAG标准)
     */
    static calculateLuminance(color: ColorInfo): number {
        const r = color.red / 255;
        const g = color.green / 255;
        const b = color.blue / 255;
        const rsrgb = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
        const gsrgb = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
        const bsrgb = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
        return 0.2126 * rsrgb + 0.7152 * gsrgb + 0.0722 * bsrgb;
    }
    /**
     * 判断颜色是否为深色
     */
    static isDarkColor(color: ColorInfo, threshold: number = 0.5): boolean {
        return ColorPickerUtil.calculateLuminance(color) < threshold;
    }
    /**
     * 获取对比色（用于状态栏文字等）
     */
    static getContrastColor(color: ColorInfo): string {
        const luminance = ColorPickerUtil.calculateLuminance(color);
        return luminance > 0.5 ? '#FF000000' : '#FFFFFFFF';
    }
    /**
     * 调整颜色以适应深色/浅色模式
     * @param color 原始颜色
     * @param isDarkMode 是否为深色模式
     * @param adjustment 调整强度 (0-1)
     */
    static adjustColorForTheme(color: ColorInfo, isDarkMode: boolean, adjustment: number = 0.3): ColorInfo {
        const hsl = ColorPickerUtil.rgbToHsl(color.red, color.green, color.blue);
        if (isDarkMode) {
            hsl.l = Math.max(0.15, hsl.l * (1 - adjustment * 0.6));
            hsl.s = Math.min(1, hsl.s * (1 + adjustment * 0.2));
        }
        else {
            hsl.l = Math.min(0.85, hsl.l * (1 + adjustment * 0.2));
        }
        const rgb = ColorPickerUtil.hslToRgb(hsl.h, hsl.s, hsl.l);
        const result: ColorInfo = {
            red: rgb.r,
            green: rgb.g,
            blue: rgb.b,
            alpha: color.alpha
        };
        return result;
    }
    /**
     * 计算两个颜色之间的插值（用于动画过渡）
     * @param color1 起始颜色
     * @param color2 目标颜色
     * @param progress 进度 (0-1)
     */
    static interpolateColor(color1: ColorInfo, color2: ColorInfo, progress: number): ColorInfo {
        const p = Math.max(0, Math.min(1, progress));
        const result: ColorInfo = {
            red: Math.round(color1.red + (color2.red - color1.red) * p),
            green: Math.round(color1.green + (color2.green - color1.green) * p),
            blue: Math.round(color1.blue + (color2.blue - color1.blue) * p),
            alpha: Math.round(color1.alpha + (color2.alpha - color1.alpha) * p)
        };
        return result;
    }
    /**
     * 获取默认结果
     */
    private static getDefaultResult(strategy: ColorExtractStrategy): ColorExtractResult {
        const defaultColor: ColorInfo = {
            red: 255,
            green: 255,
            blue: 255,
            alpha: 255
        };
        const result: ColorExtractResult = {
            color: defaultColor,
            hex: '#FFFFFFFF',
            strategy: strategy,
            confidence: 0
        };
        return result;
    }
}
