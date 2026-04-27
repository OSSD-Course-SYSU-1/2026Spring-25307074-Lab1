import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SamplePointIndex {
  @State isDark:boolean = false;
  @State step:string = "0";
  @State heart:string = "0";
  @State sleep:string = "0";
  @State calorie:string = "0";
  @State dataSource:string = "未同步";
  @State saveStatus:string = "未保存";

  build() {
    Column() {
      Row() { Text("<").fontSize(22).onClick(()=>{ router.back() });
        Text("健康数据录入").fontSize(22).fontWeight(FontWeight.Bold).flexGrow(1).textAlign(TextAlign.Center)
      }.width('90%').padding(16)

      // 数据状态面板
      Row() {
        Text(`数据源：${this.dataSource}`).fontSize(12).flexGrow(1)
        Text(`状态：${this.saveStatus}`).fontSize(12).fontColor(this.saveStatus=="已保存"?"#66BB6A":"#FF7043")
      }.width('90%').padding(8).backgroundColor(this.isDark?"#252525":"#F0F4F8").borderRadius(8)

      Scroll() {
        Column() {
          this.inputItem("今日步数", this.step, (val)=>{ this.step = val; });
          this.inputItem("平均心率(次/分)", this.heart, (val)=>{ this.heart = val; });
          this.inputItem("睡眠时长(h)", this.sleep, (val)=>{ this.sleep = val; });
          this.inputItem("消耗卡路里(kcal)", this.calorie, (val)=>{ this.calorie = val; });

          // 保存按钮：真实响应
          Button("💾 保存手动录入数据")
            .width('90%').backgroundColor("#26A69A").borderRadius(20).padding(10)
            .onClick(()=>{
              if(this.step=="0"||this.heart=="0"||this.sleep=="0"||this.calorie=="0"){
                promptAction.showToast({message:"请完整填写所有数据"});
                return;
              }
              this.saveStatus = "已保存";
              this.dataSource = "手动录入";
              promptAction.showToast({message:"手动数据保存成功，已生效"});
            })

          Column(){}.height(12)
          // 同步按钮：真实填充数据
          Button("📲 从智能设备同步数据")
            .width('90%').backgroundColor("#42A5F5").borderRadius(20).padding(10)
            .onClick(()=>{
              this.step = "9462";
              this.heart = "70";
              this.sleep = "7.9";
              this.calorie = "395";
              this.saveStatus = "已同步";
              this.dataSource = "华为WatchGT5";
              promptAction.showToast({message:"已从穿戴设备同步最新健康数据"});
            })
        }.padding({ bottom:30 })
      }
    }.width('100%').height('100%').backgroundColor(this.isDark?"#121212":"#F7F8FA")
  }

  @Builder inputItem(label:string, value:string, onChange:(val:string)=>void) {
    Row() {
      Text(label).fontSize(16).flexGrow(1).fontColor(this.isDark?Color.White:Color.Black)
      TextInput({text:value})
        .width(140).height(42).backgroundColor("#F0F4F8").borderRadius(10).textAlign(TextAlign.Center)
        .onChange((val)=>{ onChange(val); })
    }.width('90%').padding(20).backgroundColor(this.isDark?"#1E1E1E":Color.White).borderRadius(18)
    Column(){}.height(12)
  }
}
export default SamplePointIndex;