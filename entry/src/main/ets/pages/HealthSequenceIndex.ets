import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface HealthItem { name:string; value:string; }
@Entry
@Component
struct HealthSequenceIndex {
  @State isDark:boolean = false;
  @State healthList:HealthItem[] = [
    {name:"身高(cm)", value:"175"},{name:"体重(kg)", value:"65"},
    {name:"血压(mmHg)", value:"120/80"},{name:"血糖(mmol/L)", value:"5.3"},{name:"体脂率(%)", value:"18"}
  ];

  build() {
    Column() {
      Row() { Text("<").fontSize(22).onClick(()=>{ router.back() });
        Text("健康档案编辑").fontSize(22).fontWeight(FontWeight.Bold).flexGrow(1).textAlign(TextAlign.Center)
      }.width('90%').padding(16)

      Scroll() {
        Column() {
          Button("💾 保存所有档案修改")
            .width('90%').backgroundColor("#66BB6A").borderRadius(20).padding(10)
            .onClick(()=>{ promptAction.showToast({message:"健康档案已保存至本地设备"}); })
          Column(){}.height(20)

          ForEach(this.healthList, (item:HealthItem, index:number)=>{
            Row() {
              Text(item.name).fontSize(16).flexGrow(1).fontColor(this.isDark?Color.White:Color.Black)
              TextInput({text:item.value})
                .width(140).height(42).backgroundColor("#F0F4F8").borderRadius(10).textAlign(TextAlign.Center)
                .onChange((val)=>{ this.healthList[index].value = val; })
            }.width('90%').padding(20).backgroundColor(this.isDark?"#1E1E1E":Color.White).borderRadius(18)
            Column(){}.height(12)
          })
        }
      }
    }.width('100%').height('100%').backgroundColor(this.isDark?"#121212":"#F7F8FA")
  }
}
export default HealthSequenceIndex;