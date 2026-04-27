import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface DeviceItem { name:string; addr:string; status:string; }
@Entry
@Component
struct DataSourceIndex {
  @State isDark:boolean = false;
  @State isBluetoothOn:boolean = false;
  @State deviceList:DeviceItem[] = [];
  @State connectedDevice:string = "无设备连接";

  build() {
    Column() {
      Row() {
        Text("<").fontSize(22).onClick(()=>{ router.back() });
        Text("设备连接管理").fontSize(22).fontWeight(FontWeight.Bold).flexGrow(1).textAlign(TextAlign.Center)
      }.width('90%').padding(16)

      Row() {
        Text(this.isBluetoothOn?"✅蓝牙已开启":"❌蓝牙已关闭")
          .fontColor(this.isBluetoothOn?"#66BB6A":"#FF7043").fontWeight(FontWeight.Medium)
        Button("切换蓝牙").backgroundColor("#42A5F5").padding(6).borderRadius(10)
          .onClick(()=>{
            this.isBluetoothOn = !this.isBluetoothOn;
            this.deviceList = [];
            this.connectedDevice = "无设备连接";
            promptAction.showToast({message: this.isBluetoothOn ? "蓝牙已开启" : "蓝牙已关闭"});
          })
      }.width('90%').padding(12).backgroundColor(this.isDark?"#252525":"#F0F4F8").borderRadius(12)

      Button("🔍 扫描周边可连健康设备")
        .width('90%').backgroundColor("#42A5F5").borderRadius(20).padding(10)
        .onClick(()=>{
          if(!this.isBluetoothOn){ promptAction.showToast({message:"请先开启蓝牙"}); return; }
          this.deviceList = [
            {name:"华为WatchGT5", addr:"AA:BB:CC:11", status:"可连接"},
            {name:"小米Band9", addr:"DD:EE:FF:22", status:"可连接"},
            {name:"智能体脂秤", addr:"11:22:33:44", status:"可连接"}
          ];
          promptAction.showToast({message:"扫描完成，发现3台可连接设备"});
        })
      Column(){}.height(16)

      Scroll() {
        Column() {
          ForEach(this.deviceList, (item:DeviceItem)=>{
            Row() {
              Text(item.name).fontSize(16).fontColor(this.isDark?Color.White:Color.Black).flexGrow(1)
              Text(item.addr).fontSize(11).fontColor("#888")
              Button(item.status)
                .width(90).backgroundColor(item.status=="可连接"?"#42A5F5":"#66BB6A").borderRadius(12)
                .onClick(()=>{
                  this.connectedDevice = item.name;
                  item.status = "已连接";
                  promptAction.showToast({message:`成功连接【${item.name}】`});
                })
            }.width('90%').padding(20).backgroundColor(this.isDark?"#1E1E1E":Color.White).borderRadius(18)
            Column(){}.height(12)
          })
        }
      }
    }.width('100%').height('100%').backgroundColor(this.isDark?"#121212":"#F7F8FA")
  }
}
export default DataSourceIndex;