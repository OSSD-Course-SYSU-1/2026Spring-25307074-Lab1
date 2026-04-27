import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface RecordItem { name:string; time:string; distance:string; duration:string; calorie:string; }
@Entry
@Component
struct ExerciseSequenceIndex {
  @State isDark:boolean = false;
  @State recordList:RecordItem[] = [];
  @State sportType:string = "户外跑步";
  @State distance:string = "";
  @State duration:string = "";

  build() {
    Column() {
      Row() { Text("<").fontSize(22).onClick(()=>{ router.back() });
        Text("运动锻炼记录").fontSize(22).fontWeight(FontWeight.Bold).flexGrow(1).textAlign(TextAlign.Center)
      }.width('90%').padding(16)

      Scroll() {
        Column() {
          // 运动类型选择（预设，不粗糙手动输）
          Row() {
            Text("运动类型：").fontSize(15).flexGrow(1)
            Button(this.sportType).backgroundColor("#42A5F520").borderRadius(10)
              .onClick(()=>{
                let types = ["户外跑步","室内骑行","健走","游泳"];
                let idx = types.indexOf(this.sportType);
                this.sportType = types[(idx+1)%types.length];
              })
          }.width('90%').padding(12).backgroundColor(this.isDark?"#252525":"#F0F4F8").borderRadius(10)

          // 距离+时长输入
          Row() {
            TextInput({placeholder:"运动距离(公里)"}).width('43%').height(42).backgroundColor("#F0F4F8")
              .onChange((val)=>{ this.distance = val; })
            TextInput({placeholder:"运动时长(分钟)"}).width('43%').height(42).backgroundColor("#F0F4F8")
              .onChange((val)=>{ this.duration = val; })
          }.width('90%')

          Button("➕ 添加多维度运动记录")
            .width('90%').backgroundColor("#FF7043").borderRadius(20).padding(10)
            .onClick(()=>{
              if(!this.distance||!this.duration){ promptAction.showToast({message:"请填写距离和时长"}); return; }
              let calorie = (Number(this.distance)*60 + Number(this.duration)*2).toFixed(0);
              let now = new Date().toLocaleString();
              this.recordList.unshift({
                name:this.sportType, time:now, distance:this.distance+"公里",
                duration:this.duration+"分钟", calorie:calorie+"千卡"
              });
              promptAction.showToast({message:"运动记录添加成功，已自动计算卡路里"});
            })
          Column(){}.height(20)

          // 精致运动记录卡片
          ForEach(this.recordList, (item:RecordItem, index:number)=>{
            Column() {
              Row() {
                Text(item.name).fontSize(16).fontWeight(FontWeight.Medium).flexGrow(1)
                Text(item.distance).fontSize(14)
              }
              Row() {
                Text(`时长：${item.duration}`).fontSize(12).fontColor("#888").flexGrow(1)
                Text(`消耗：${item.calorie}`).fontSize(12).fontColor("#FF7043")
              }
              Text(item.time).fontSize(11).fontColor("#AAA").width('100%').margin({top:4})
              Button("删除此记录").backgroundColor("#FF4444").width('100%').padding(4).borderRadius(8)
                .onClick(()=>{ this.recordList.splice(index,1); })
            }.width('90%').padding(18).backgroundColor(this.isDark?"#1E1E1E":Color.White).borderRadius(18)
            Column(){}.height(12)
          })
        }
      }
    }.width('100%').height('100%').backgroundColor(this.isDark?"#121212":"#F7F8FA")
  }
}
export default ExerciseSequenceIndex;