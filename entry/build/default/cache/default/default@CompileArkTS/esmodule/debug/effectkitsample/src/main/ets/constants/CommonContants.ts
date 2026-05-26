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
export default class CommonConstants {
    /**
     * Height and width is 100%.
     * */
    public static readonly FULL_PARENT: string = '100%';
    /**
     * Window background color.
     * */
    public static readonly START_WINDOW_BACKGROUND: string = '#FFFFFFF';
    /**
     * Swiper interval.
     * */
    public static readonly SWIPER_INTERVAL: number = 3500;
    /**
     * Key prefix.
     * */
    public static readonly KEY_PREFIX: string = 'effectKit';
    /**
     * The duration of each image in the swiper.
     * */
    public static readonly SWIPER_DURATION: number = 500;
    /**
     * The space of swiper item.
     * */
    public static readonly SWIPER_ITEM_SPACE: number = 10;
    /**
     * Hexadecimal.
     * */
    public static readonly HEXADECIMAL: number = 16;
    /**
     * The duration of the animation.
     * */
    public static readonly ANIMATION_DURATION: number = 500;
    /**
     * The iterations of the animation.
     * */
    public static readonly ANIMATION_ITERATIONS: number = 1;
    /**
     * The start gradient range.
     * */
    public static readonly START_GRADIENT_RANGE: number = 0.0;
    /**
     * The end gradient range.
     * */
    public static readonly END_GRADIENT_RANGE: number = 0.5;
    /**
     * Color transition animation duration.
     * */
    public static readonly COLOR_TRANSITION_DURATION: number = 400;
    /**
     * Color transition animation curve.
     * */
    public static readonly COLOR_TRANSITION_CURVE: Curve = Curve.EaseInOut;
    /**
     * Image loading timeout.
     * */
    public static readonly IMAGE_LOAD_TIMEOUT: number = 10000;
    /**
     * Default background color for loading state.
     * */
    public static readonly LOADING_BG_COLOR: string = '#FFF5F5F5';
    /**
     * Default background color for error state.
     * */
    public static readonly ERROR_BG_COLOR: string = '#FFE0E0E0';
}
