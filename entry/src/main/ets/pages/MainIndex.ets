import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State isDark: boolean = false;
  @State isBluetoothOn: boolean = false;
  @State connectedDevice: string = "无设备连接";
  @State stepData: number[] = [5200, 6800, 7500, 6200, 8900, 9200, 10500];

  build() {
    Column() {
      Row() {
        Text(this.isBluetoothOn ? "✅ 蓝牙已开启" : "❌ 蓝牙未开启")
          .fontSize(13)
          .fontColor(this.isBluetoothOn ? "#66BB6A" : "#FF7043");
        Text(` | 已连：${this.connectedDevice}`)
          .fontSize(13)
          .fontColor(this.isDark ? Color.White : Color.Black);
      }
      .width('90%')
      .padding(8)
      .backgroundColor(this.isDark ? "#252525" : "#F0F4F8")
      .borderRadius(10)

      Row() {
        Text("健康数据中心")
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? Color.White : Color.Black);
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.isDark })
          .onChange((val: boolean) => { this.isDark = val; })
      }
      .width('90%')
      .padding(16)

      Scroll() {
        Column() {
          Row() {
            Circle().width(55).height(55).fill(this.isDark ? "#252525" : "#E3F2FD");
            Column() {
              Text("健康用户").fontSize(19).fontColor(this.isDark ? Color.White : Color.Black);
              Text(`授权设备：${this.connectedDevice}`).fontSize(12).fontColor(this.isDark ? "#AAA" : "#666");
            }.margin({ left:12 });
            Blank()
            Text("健康Lv.3").backgroundColor("#42A5F5").fontColor(Color.White).padding(6).borderRadius(20);
          }
          .width('90%').padding(20).backgroundColor(this.isDark ? "#1E1E1E" : Color.White).borderRadius(22)

          Column(){}.height(16)
          this.menuItem("数据来源", "蓝牙设备管理", "#42A5F5", "pages/DataSourceIndex")
          this.menuItem("采样数据", "录入/同步健康数据", "#26A69A", "pages/SamplePointIndex")
          this.menuItem("锻炼记录", "运动数据多维度记录", "#FF7043", "pages/ExerciseSequenceIndex")
          this.menuItem("健康记录", "身体档案编辑", "#7986CB", "pages/HealthSequenceIndex")
          this.menuItem("授权管理", "设备权限管控", "#EC407A", "pages/AuthIndex")
          this.menuItem("运动联动", "设备同步状态", "#66BB6A", "pages/WorkoutIndex")
        }.padding({ bottom:40 })
      }
    }
    .width('100%').height('100%').backgroundColor(this.isDark ? "#121212" : "#F7F8FA")
  }

  @Builder menuItem(title:string, desc:string, color:string, url:string) {
    Row() {
      Circle().width(34).height(34).fill(color+"20")
      Column() {
        Text(title).fontSize(16).fontColor(this.isDark ? Color.White : Color.Black)
        Text(desc).fontSize(11).fontColor(this.isDark ? "#888" : "#777")
      }.flexGrow(1).margin({ left:12 })
      Text(">").fontColor("#999")
    }
    .width('90%').padding(18).backgroundColor(this.isDark ? "#1E1E1E" : Color.White).borderRadius(18)
    .onClick(()=>{ router.pushUrl({ url:url }) })
    Column(){}.height(10)
  }
}
export default Index;