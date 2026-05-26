if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    imgData?: ImageItem[];
    currentBgColor?: string;
    targetBgColor?: string;
    currentIndex?: number;
    topSafeHeight?: number;
    bottomSafeHeight?: number;
    is2in1Device?: boolean;
    isDarkMode?: boolean;
    statusBarTextColor?: string;
    isProcessingColor?: boolean;
    swiperController?: SwiperController;
    swiperInterval?: number;
    swiperDuration?: number;
    swiperItemSpace?: number;
    context?;
    currentWidthBreakpoint?: string;
    windowUtil?: WindowUtil | undefined;
    colorStrategy?: ColorExtractStrategy;
}
import window from "@ohos:window";
import type resourceManager from "@ohos:resourceManager";
import image from "@ohos:multimedia.image";
import CommonConstants from "@bundle:com.example.effectkit/effectkitsample/ets/constants/CommonContants";
import type common from "@ohos:app.ability.common";
import Logger from "@bundle:com.example.effectkit/effectkitsample/ets/utils/Logger";
import { ImmersiveType } from "@bundle:com.example.effectkit/effectkitsample/ets/utils/WindowUtil";
import type { WindowUtil } from "@bundle:com.example.effectkit/effectkitsample/ets/utils/WindowUtil";
import deviceInfo from "@ohos:deviceInfo";
import { ColorPickerUtil, ColorExtractStrategy } from "@bundle:com.example.effectkit/effectkitsample/ets/utils/ColorPickerUtil";
import type { ColorExtractResult } from "@bundle:com.example.effectkit/effectkitsample/ets/utils/ColorPickerUtil";
const TAG: string = '[Index]';
/** 图片加载状态枚举 */
enum ImageLoadState {
    LOADING = 0,
    SUCCESS = 1,
    ERROR = 2
}
/** 图片项接口 */
interface ImageItem {
    resource: Resource;
    loadState: ImageLoadState;
}
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__imgData = new ObservedPropertyObjectPU([
            { resource: { "id": 16777229, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777230, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777231, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777232, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777233, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777234, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777235, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
            { resource: { "id": 16777236, "type": 20000, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, loadState: ImageLoadState.SUCCESS },
        ], this, "imgData");
        this.__currentBgColor = new ObservedPropertySimplePU(CommonConstants.START_WINDOW_BACKGROUND, this, "currentBgColor");
        this.__targetBgColor = new ObservedPropertySimplePU(CommonConstants.START_WINDOW_BACKGROUND, this, "targetBgColor");
        this.__currentIndex = new ObservedPropertySimplePU(0, this, "currentIndex");
        this.__topSafeHeight = new ObservedPropertySimplePU(0, this, "topSafeHeight");
        this.__bottomSafeHeight = new ObservedPropertySimplePU(0, this, "bottomSafeHeight");
        this.__is2in1Device = new ObservedPropertySimplePU(false, this, "is2in1Device");
        this.__isDarkMode = new ObservedPropertySimplePU(false, this, "isDarkMode");
        this.__statusBarTextColor = new ObservedPropertySimplePU('#FF000000', this, "statusBarTextColor");
        this.isProcessingColor = false;
        this.swiperController = new SwiperController();
        this.swiperInterval = CommonConstants.SWIPER_INTERVAL;
        this.swiperDuration = CommonConstants.SWIPER_DURATION;
        this.swiperItemSpace = CommonConstants.SWIPER_ITEM_SPACE;
        this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        this.__currentWidthBreakpoint = this.createStorageLink(CommonConstants.KEY_PREFIX + 'currentWidthBreakpoint', 'md', "currentWidthBreakpoint");
        this.__windowUtil = this.createStorageLink(CommonConstants.KEY_PREFIX + 'windowUtil', undefined, "windowUtil");
        this.__colorStrategy = new ObservedPropertySimplePU(ColorExtractStrategy.SMART, this, "colorStrategy");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.imgData !== undefined) {
            this.imgData = params.imgData;
        }
        if (params.currentBgColor !== undefined) {
            this.currentBgColor = params.currentBgColor;
        }
        if (params.targetBgColor !== undefined) {
            this.targetBgColor = params.targetBgColor;
        }
        if (params.currentIndex !== undefined) {
            this.currentIndex = params.currentIndex;
        }
        if (params.topSafeHeight !== undefined) {
            this.topSafeHeight = params.topSafeHeight;
        }
        if (params.bottomSafeHeight !== undefined) {
            this.bottomSafeHeight = params.bottomSafeHeight;
        }
        if (params.is2in1Device !== undefined) {
            this.is2in1Device = params.is2in1Device;
        }
        if (params.isDarkMode !== undefined) {
            this.isDarkMode = params.isDarkMode;
        }
        if (params.statusBarTextColor !== undefined) {
            this.statusBarTextColor = params.statusBarTextColor;
        }
        if (params.isProcessingColor !== undefined) {
            this.isProcessingColor = params.isProcessingColor;
        }
        if (params.swiperController !== undefined) {
            this.swiperController = params.swiperController;
        }
        if (params.swiperInterval !== undefined) {
            this.swiperInterval = params.swiperInterval;
        }
        if (params.swiperDuration !== undefined) {
            this.swiperDuration = params.swiperDuration;
        }
        if (params.swiperItemSpace !== undefined) {
            this.swiperItemSpace = params.swiperItemSpace;
        }
        if (params.context !== undefined) {
            this.context = params.context;
        }
        if (params.colorStrategy !== undefined) {
            this.colorStrategy = params.colorStrategy;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__imgData.purgeDependencyOnElmtId(rmElmtId);
        this.__currentBgColor.purgeDependencyOnElmtId(rmElmtId);
        this.__targetBgColor.purgeDependencyOnElmtId(rmElmtId);
        this.__currentIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__topSafeHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__bottomSafeHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__is2in1Device.purgeDependencyOnElmtId(rmElmtId);
        this.__isDarkMode.purgeDependencyOnElmtId(rmElmtId);
        this.__statusBarTextColor.purgeDependencyOnElmtId(rmElmtId);
        this.__currentWidthBreakpoint.purgeDependencyOnElmtId(rmElmtId);
        this.__windowUtil.purgeDependencyOnElmtId(rmElmtId);
        this.__colorStrategy.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__imgData.aboutToBeDeleted();
        this.__currentBgColor.aboutToBeDeleted();
        this.__targetBgColor.aboutToBeDeleted();
        this.__currentIndex.aboutToBeDeleted();
        this.__topSafeHeight.aboutToBeDeleted();
        this.__bottomSafeHeight.aboutToBeDeleted();
        this.__is2in1Device.aboutToBeDeleted();
        this.__isDarkMode.aboutToBeDeleted();
        this.__statusBarTextColor.aboutToBeDeleted();
        this.__currentWidthBreakpoint.aboutToBeDeleted();
        this.__windowUtil.aboutToBeDeleted();
        this.__colorStrategy.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 图片数据 - 初始状态为SUCCESS，图片会直接显示
    private __imgData: ObservedPropertyObjectPU<ImageItem[]>;
    get imgData() {
        return this.__imgData.get();
    }
    set imgData(newValue: ImageItem[]) {
        this.__imgData.set(newValue);
    }
    // 当前背景色（用于渐变）
    private __currentBgColor: ObservedPropertySimplePU<string>;
    get currentBgColor() {
        return this.__currentBgColor.get();
    }
    set currentBgColor(newValue: string) {
        this.__currentBgColor.set(newValue);
    }
    // 目标背景色（用于渐变动画）
    private __targetBgColor: ObservedPropertySimplePU<string>;
    get targetBgColor() {
        return this.__targetBgColor.get();
    }
    set targetBgColor(newValue: string) {
        this.__targetBgColor.set(newValue);
    }
    // 当前Swiper索引
    private __currentIndex: ObservedPropertySimplePU<number>;
    get currentIndex() {
        return this.__currentIndex.get();
    }
    set currentIndex(newValue: number) {
        this.__currentIndex.set(newValue);
    }
    // 安全区域高度
    private __topSafeHeight: ObservedPropertySimplePU<number>;
    get topSafeHeight() {
        return this.__topSafeHeight.get();
    }
    set topSafeHeight(newValue: number) {
        this.__topSafeHeight.set(newValue);
    }
    private __bottomSafeHeight: ObservedPropertySimplePU<number>;
    get bottomSafeHeight() {
        return this.__bottomSafeHeight.get();
    }
    set bottomSafeHeight(newValue: number) {
        this.__bottomSafeHeight.set(newValue);
    }
    // 设备类型
    private __is2in1Device: ObservedPropertySimplePU<boolean>;
    get is2in1Device() {
        return this.__is2in1Device.get();
    }
    set is2in1Device(newValue: boolean) {
        this.__is2in1Device.set(newValue);
    }
    // 是否为深色模式
    private __isDarkMode: ObservedPropertySimplePU<boolean>;
    get isDarkMode() {
        return this.__isDarkMode.get();
    }
    set isDarkMode(newValue: boolean) {
        this.__isDarkMode.set(newValue);
    }
    // 状态栏文字颜色（根据背景色动态调整）
    private __statusBarTextColor: ObservedPropertySimplePU<string>;
    get statusBarTextColor() {
        return this.__statusBarTextColor.get();
    }
    set statusBarTextColor(newValue: string) {
        this.__statusBarTextColor.set(newValue);
    }
    // 是否正在处理颜色提取
    private isProcessingColor: boolean;
    // Swiper控制器
    private swiperController: SwiperController;
    // 配置参数
    private swiperInterval: number;
    private swiperDuration: number;
    private swiperItemSpace: number;
    // 上下文
    private context;
    // 响应式断点
    private __currentWidthBreakpoint: ObservedPropertyAbstractPU<string>;
    get currentWidthBreakpoint() {
        return this.__currentWidthBreakpoint.get();
    }
    set currentWidthBreakpoint(newValue: string) {
        this.__currentWidthBreakpoint.set(newValue);
    }
    private __windowUtil: ObservedPropertyAbstractPU<WindowUtil | undefined>;
    get windowUtil() {
        return this.__windowUtil.get();
    }
    set windowUtil(newValue: WindowUtil | undefined) {
        this.__windowUtil.set(newValue);
    }
    // 取色策略（可通过UI切换）
    private __colorStrategy: ObservedPropertySimplePU<ColorExtractStrategy>;
    get colorStrategy() {
        return this.__colorStrategy.get();
    }
    set colorStrategy(newValue: ColorExtractStrategy) {
        this.__colorStrategy.set(newValue);
    }
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
        }
        catch (error) {
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
            this.topSafeHeight = this.getUIContext().px2vp(windowHeight.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height);
            this.bottomSafeHeight = this.getUIContext().px2vp(windowHeight.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height);
        }
        catch (error) {
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
            const result: ColorExtractResult = await ColorPickerUtil.extractColorFromPixelMap(pixelMap, this.colorStrategy);
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
        }
        catch (error) {
            Logger.error(TAG, `loadImageColor failed: ${JSON.stringify(error)}`);
            this.imgData[index].loadState = ImageLoadState.ERROR;
        }
        finally {
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
        }
        catch (error) {
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(CommonConstants.FULL_PARENT);
            Column.height(CommonConstants.FULL_PARENT);
            Column.linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                    [this.currentBgColor, CommonConstants.START_GRADIENT_RANGE],
                    [this.isDarkMode ? '#FF1A1A1A' : Color.White, CommonConstants.END_GRADIENT_RANGE]
                ]
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 顶部状态栏占位
            Row.create();
            // 顶部状态栏占位
            Row.width('100%');
            // 顶部状态栏占位
            Row.height(this.topSafeHeight);
            // 顶部状态栏占位
            Row.backgroundColor(this.currentBgColor);
        }, Row);
        // 顶部状态栏占位
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Swiper图片轮播
            Stack.create({ alignContent: Alignment.Center });
            // Swiper图片轮播
            Stack.layoutWeight(1);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Swiper.create(this.swiperController);
            Swiper.width(CommonConstants.FULL_PARENT);
            Swiper.height(this.currentWidthBreakpoint === 'lg' || this.currentWidthBreakpoint === 'xl'
                ? 'calc(100% - 16vp)' : 'auto');
            Swiper.padding({ left: { "id": 16777221, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }, right: { "id": 16777222, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" } });
            Swiper.autoPlay(true);
            Swiper.interval(this.swiperInterval);
            Swiper.duration(this.swiperDuration);
            Swiper.loop(true);
            Swiper.itemSpace(this.swiperItemSpace);
            Swiper.indicator(false);
            Swiper.onChange((index: number) => {
                this.currentIndex = index;
                this.loadImageColor(index);
            });
        }, Swiper);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const item = _item;
                this.ImageItemBuilder.bind(this)(item, index);
            };
            this.forEachUpdateFunction(elmtId, this.imgData, forEachItemGenFunction, (item: ImageItem, index: number) => index.toString(), true, true);
        }, ForEach);
        ForEach.pop();
        Swiper.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 左右切换按钮
            Row.create();
            // 左右切换按钮
            Row.width('100%');
            // 左右切换按钮
            Row.padding({ left: 20, right: 20 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 左箭头
            Button.createWithChild({ type: ButtonType.Circle });
            // 左箭头
            Button.width(40);
            // 左箭头
            Button.height(40);
            // 左箭头
            Button.backgroundColor('#66000000');
            // 左箭头
            Button.onClick(() => this.showPreviousImage());
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('<');
            Text.fontColor(Color.White);
            Text.fontSize(24);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        // 左箭头
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 右箭头
            Button.createWithChild({ type: ButtonType.Circle });
            // 右箭头
            Button.width(40);
            // 右箭头
            Button.height(40);
            // 右箭头
            Button.backgroundColor('#66000000');
            // 右箭头
            Button.onClick(() => this.showNextImage());
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('>');
            Text.fontColor(Color.White);
            Text.fontSize(24);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        // 右箭头
        Button.pop();
        // 左右切换按钮
        Row.pop();
        // Swiper图片轮播
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 底部指示器和控制区
            Row.create();
            // 底部指示器和控制区
            Row.width('100%');
            // 底部指示器和控制区
            Row.height(50);
            // 底部指示器和控制区
            Row.padding({ left: 20, right: 20 });
            // 底部指示器和控制区
            Row.backgroundColor(this.currentBgColor);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 页码指示
            Text.create(`${this.currentIndex + 1} / ${this.imgData.length}`);
            // 页码指示
            Text.fontColor(Color.White);
            // 页码指示
            Text.fontSize(14);
        }, Text);
        // 页码指示
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 取色策略切换按钮
            Button.createWithLabel(this.getStrategyName());
            // 取色策略切换按钮
            Button.fontSize(12);
            // 取色策略切换按钮
            Button.height(32);
            // 取色策略切换按钮
            Button.backgroundColor('#66000000');
            // 取色策略切换按钮
            Button.onClick(() => this.cycleColorStrategy());
        }, Button);
        // 取色策略切换按钮
        Button.pop();
        // 底部指示器和控制区
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 底部安全区域
            Row.create();
            // 底部安全区域
            Row.width('100%');
            // 底部安全区域
            Row.height(this.bottomSafeHeight);
            // 底部安全区域
            Row.backgroundColor(this.currentBgColor);
        }, Row);
        // 底部安全区域
        Row.pop();
        Column.pop();
    }
    /**
     * 图片项构建器
     */
    ImageItemBuilder(item: ImageItem, index: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width('100%');
            Stack.height('100%');
            Stack.margin({
                top: this.is2in1Device ? { "id": 16777219, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" } : { "id": 16777220, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" }
            });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (item.loadState === ImageLoadState.LOADING) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 加载中状态
                        Column.create();
                        // 加载中状态
                        Column.width('100%');
                        // 加载中状态
                        Column.height('100%');
                        // 加载中状态
                        Column.justifyContent(FlexAlign.Center);
                        // 加载中状态
                        Column.backgroundColor(CommonConstants.LOADING_BG_COLOR);
                        // 加载中状态
                        Column.borderRadius({ "id": 16777218, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.width(50);
                        LoadingProgress.height(50);
                        LoadingProgress.color(Color.White);
                    }, LoadingProgress);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('加载中...');
                        Text.fontColor(Color.White);
                        Text.fontSize(14);
                        Text.margin({ top: 10 });
                    }, Text);
                    Text.pop();
                    // 加载中状态
                    Column.pop();
                });
            }
            else if (item.loadState === ImageLoadState.ERROR) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 加载失败状态
                        Column.create();
                        // 加载失败状态
                        Column.width('100%');
                        // 加载失败状态
                        Column.height('100%');
                        // 加载失败状态
                        Column.justifyContent(FlexAlign.Center);
                        // 加载失败状态
                        Column.backgroundColor(CommonConstants.ERROR_BG_COLOR);
                        // 加载失败状态
                        Column.borderRadius({ "id": 16777218, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('加载失败');
                        Text.fontColor(Color.Red);
                        Text.fontSize(16);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('重试');
                        Button.margin({ top: 10 });
                        Button.onClick(() => {
                            item.loadState = ImageLoadState.LOADING;
                            this.loadImageColor(index);
                        });
                    }, Button);
                    Button.pop();
                    // 加载失败状态
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 加载成功
                        Image.create(item.resource);
                        // 加载成功
                        Image.width('100%');
                        // 加载成功
                        Image.height('100%');
                        // 加载成功
                        Image.objectFit(ImageFit.Contain);
                        // 加载成功
                        Image.borderRadius({ "id": 16777218, "type": 10007, params: [], "bundleName": "com.example.effectkit", "moduleName": "effectkitsample" });
                        // 加载成功
                        Image.onComplete(() => {
                            if (item.loadState === ImageLoadState.LOADING) {
                                item.loadState = ImageLoadState.SUCCESS;
                            }
                        });
                        // 加载成功
                        Image.onError(() => {
                            item.loadState = ImageLoadState.ERROR;
                        });
                    }, Image);
                });
            }
        }, If);
        If.pop();
        Stack.pop();
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
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.effectkit", moduleName: "effectkitsample", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
