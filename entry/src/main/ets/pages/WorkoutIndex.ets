import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface LinkItem { name: string; status: boolean; }
@Entry
@Component
struct WorkoutIndex {
  @State isDark: boolean = false;
  @State connectedDevice:string = "华为WatchGT5";
  @State isDeviceConnected: boolean = true;
  @State linkList: LinkItem[] = [
    { name: "运动数据实时同步", status: false },
    { name: "心率异常提醒", status: false }
  ];

  build() {
    Column() {
      Row() {
        Text("<").fontSize(22).onClick(() => { router.back(); })
        Text("运动设备联动").fontSize(22).fontWeight(FontWeight.Bold).flexGrow(1).textAlign(TextAlign.Center)
      }.width('90%').padding(16)

      // 显示当前同步设备
      Button(`📶 同步设备：${this.connectedDevice}`)
        .width('90%').backgroundColor(this.isDeviceConnected?"#66BB6A":"#FF7043").borderRadius(20).padding(10)
        .onClick(() => {
          this.isDeviceConnected = !this.isDeviceConnected;
          if(!this.isDeviceConnected){
            this.linkList.forEach(i=>i.status=false);
            promptAction.showToast({message:"已断开设备同步，所有联动关闭"});
          }else{
            promptAction.showToast({message:`已连接【${this.connectedDevice}】，可开启联动`});
          }
        })

      Column(){}.height(20)
      Text(`仅对【${this.connectedDevice}】生效`).fontSize(12).fontColor("#888")

      Scroll() {
        Column() {
          ForEach(this.linkList, (item: LinkItem, index: number) => {
            Row() {
              Text(item.name).fontSize(16).fontColor(this.isDark ? Color.White : Color.Black).flexGrow(1)
              Checkbox()
                .select(item.status)
                .enabled(this.isDeviceConnected)
                .onChange((val: boolean) => {
                  this.linkList[index].status = val;
                  promptAction.showToast({ message: `${item.name}${val ? "✅已开启" : "❌已关闭"}` });
                })
            }.width('90%').padding(20).backgroundColor(this.isDark?"#1E1E1E":Color.White).borderRadius(18)
            Column(){}.height(14)
          })
        }
      }
    }.width('100%').height('100%').backgroundColor(this.isDark?"#121212":"#F7F8FA")
  }
}
export default WorkoutIndex;