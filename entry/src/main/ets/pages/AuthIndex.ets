import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface AuthItem { name:string; status:boolean; }
@Entry
@Component
struct AuthIndex {
  @State isDark:boolean = false;
  @State connectedDevice:string = "华为WatchGT5";
  @State authList:AuthItem[] = [
    {name:"读取步数", status:true},{name:"读取心率", status:false},
    {name:"读取睡眠", status:false},{name:"读取血压", status:false}
  ];

  build() {
    Column() {
      Row() { Text("<").fontSize(22).onClick(()=>{ router.back() });
        Text("设备授权管理").fontSize(22).fontWeight(FontWeight.Bold).flexGrow(1).textAlign(TextAlign.Center)
      }.width('90%').padding(16)

      // 授权设备提示
      Text(`当前授权设备：${this.connectedDevice}`)
        .fontSize(14).fontColor("#42A5F5").width('90%').textAlign(TextAlign.Center)

      Scroll() {
        Column() {
          ForEach(this.authList, (item:AuthItem, index:number)=>{
            Row() {
              Text(item.name).fontSize(16).flexGrow(1)
              // 未连设备则敏感权限禁用
              Toggle({ type: ToggleType.Switch, isOn: item.status })
                .enabled(this.connectedDevice!="无设备连接")
                .onChange((val:boolean)=>{
                  this.authList[index].status = val;
                  let tip = val ? `已授权【${this.connectedDevice}】` : `已取消【${this.connectedDevice}】授权`;
                  promptAction.showToast({message: tip});
                })
            }.width('90%').padding(20).backgroundColor(this.isDark?"#1E1E1E":Color.White).borderRadius(18)
            Column(){}.height(12)
          })
        }
      }
    }.width('100%').height('100%').backgroundColor(this.isDark?"#121212":"#F7F8FA")
  }
}
export default AuthIndex;