//
//  HelpViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/11/3.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "HelpViewController.h"
#import "SettingModel.h"
#import "HelpDetailViewController.h"

@interface HelpViewController ()<UITableViewDataSource,UITableViewDelegate>
    {
        
        SettingModel *setmodel;
    }
    @property (nonatomic, weak) UITableView *setingTable;
    
    @end

@implementation HelpViewController
    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
    }
    
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"帮助中心"];
    setmodel = [[SettingModel alloc] init];
    WS(weakself);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself.navigationController popViewControllerAnimated:YES];
    }];
    
    _sectionArray = [NSMutableArray arrayWithObjects:@"如何绑定车辆?",@"一直搜索不到车辆怎么办?",@"绑定车辆提示失败，但有车却一直连不上？",@"手机app怎么连接车辆并遥控?",@"为什么要绑定车辆?",@"一键启动怎么使用?",@"为什么手机APP操作老是提示设备未连接?",@"遥控手柄锁车一直锁不上车怎么办?",@"什么是分享车辆?",@"固件版本是什么，为什么要升级?",@"钥匙忘带了，怎么启动车辆?",@"白片片(蓝牙感应钥匙)怎么使用?",@"手机感应和感应钥匙感应有什么区别?",@"二合一感应钥匙怎么使用?",@"车辆会自动锁车怎么回事？",@"车放车棚老是叫怎么办?",@"开启车辆坐垫锁有哪些方法?", @"钥匙丢了怎么办?",@"如何解绑车辆?",@"车辆体检功能有什么用?",@"感应钥匙失效了怎么办?",@"钥匙不灵敏了,无法开坐垫锁了?",@"地图定位不准，骑行导航准不准?",@"温度和电压是什么意思?",@"我还遇到了其它问题怎么办?",nil];
    
    UITableView *setingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin) style:UITableViewStyleGrouped];
    setingTable.delegate = self;
    setingTable.dataSource = self;
    setingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [setingTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:setingTable];
    self.setingTable = setingTable;
    
}
    
#pragma mark -UITableViewDataSource
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sectionArray.count;
}
    
    
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}
    
    
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cell_id = @"profile";
    // 先从重用池中找cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell == nil) {
        //cell必须先进行初始化
        cell = [[UITableViewCell alloc]init];
        //  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID andDataArr:[_courArrayM objectAtIndex:indexPath.row] andIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        cell.separatorInset=UIEdgeInsetsZero;
        cell.clipsToBounds = YES;
        
        //设置cell点击无任何效果和背景色
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    
    return cell;
}
    
    
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        [self.view endEditing:YES];
    }
    
- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
    {
        
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 45;
    
}
    
    //section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
    {
        
        return 1.0;
    }
    
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}
    
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
        if (indexPath.section == 0) {
            return 80;
        }else if (indexPath.section == 1){
            return 250;
        }else if (indexPath.section == 2){
            return 440;
        }else if (indexPath.section == 3){
            return 140;
        }else if (indexPath.section == 4){
            return 140;
        }else if (indexPath.section == 5){
            return 160;
        }else if (indexPath.section == 6){
            return 80;
        }else if (indexPath.section == 7){
            return 270;
        }else if (indexPath.section == 8){
            return 100;
        }
    }
    
    return 0;
}
    
    
    //section头部显示的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    header.backgroundColor = [UIColor whiteColor];
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, ScreenWidth - 40, 20)];
    myLabel.text = [NSString stringWithFormat:@"%@",_sectionArray[section]];
    myLabel.textColor = [UIColor blackColor];
    myLabel.font = [UIFont systemFontOfSize:15];
    [header addSubview:myLabel];
    
    // 单击的 Recognizer ,收缩分组cell
    header.tag = section;
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    image.image = [UIImage imageNamed:@"arrow"];
    [header addSubview:image];
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [singleRecognizer setNumberOfTouchesRequired:1];//1个手指操作
    [header addGestureRecognizer:singleRecognizer];//添加一个手势监测；
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [UIView new];
    return header;
}

#pragma mark 展开收缩section中cell 手势监听
-(void)SingleTap:(UITapGestureRecognizer*)recognizer{
    NSInteger didSection = recognizer.view.tag;
    
    HelpDetailViewController *helpVc = [HelpDetailViewController new];
    if (didSection == 0) {
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>打开手机网络和蓝牙进入APP绑定车辆界面，“长按钥匙解锁键”直到车叫；\n2>点击搜索到的车辆，APP自动完成车辆绑定；\n3>车辆可以重复绑定（如A绑定车辆后，B再绑定该车辆，则A自动解绑。A还可再次绑定）。";
        helpVc.needPicture = YES;
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 1){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"确认手机蓝牙已开启。已开启还搜索不到车辆请重启手机蓝牙，部分手机还需开启手机GPS";
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 2){
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.selectNum = 2;
        helpVc.detailLab = @"由于绑定过程中网络和蓝牙信号不稳定造成的，您只需解绑后再次绑定车辆即可";
        
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 3){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"手机绑定过车辆后，开启手机蓝牙打开APP靠近该车辆便会自动去连接该车辆，连接车辆速度很快。（不同手机连接时间不一样，蓝牙信号干扰可能会稍慢）";
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 4){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>我们设备为智能设备，带感应功能和手机APP，通过蓝牙和云服务器使电动车智能起来；\n2>手机APP绑定车辆后，便可通过手机来遥控车辆，跟普通钥匙遥控一样的功能。用户出门忘带钥匙就可以使用手机来启动车辆了，或者也可以不带钥匙出门。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 5){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.selectNum = 5;
        helpVc.detailLab = @"一键启动：\n灯常亮：车辆为骑行状态；（此时按“一键启动”会关电门，车为解锁状态，灯闪烁。正常骑行不会关电门）\n灯闪烁：车辆为解锁状态；（此时按“一键启动”会开电门，车为骑行状态，灯常亮）\n灯关闭：车辆为上锁状态。（此时按“一键启动”不会有任何反应）";
        [self.navigationController pushViewController:helpVc animated:YES];
        
        
    }else if (didSection == 6){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.selectNum = 6;
        helpVc.detailLab = @"绑定过车辆后部分功能需要手机连接上车才可进行操作，如未连接便去操作则会提示“设备未连接”。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 7){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"请确认感应钥匙是否已关闭，因为感应优先级最高，感应钥匙在感应范围内会解锁车辆。如果感应钥匙开启再去上锁车辆的话就会，一上锁车立马解锁。您可关闭感应钥匙后再遥控手柄锁车。";
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 8){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>分享车辆即借车功能，分享给朋友了就相当于朋友手机APP有了你这辆车，他靠近车辆时手机会连上该车，也就可以手机遥控车了。被分享用户（子用户）只能遥控车辆，其它功能没有，主用户也可以随时删除子用户，无需担心安全问题。\n2>绑定过车辆后即可分享您的车辆，点击首页右上角“+”图标选择分享车辆。分享成功后您也可以删除分享用户；\n3>分享车辆无距离限制，任意有网络地方都可以分享。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 9){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>车辆系统（固件版本）是当前车辆软件系统版本，具备可扩展和升级功能。升级就是在给设备扩展功能并优化车辆性能，让骑行更加安全放心。整个升级包很小，升级也很快。\n1>升级过程中由于信号不稳定等原因会升级失败，升级失败系统进入恢复状态会出现短暂无法操控车辆情况，大约两分钟左右车辆系统将会自动重启，您可再次升级。建议您在合适的时间段升级车辆，避免因升级失败给您造成使用不便。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 10){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"绑定过车辆后您可以通过手机连接车辆来遥控车辆，此时手机就是您的车辆钥匙。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 11){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"白片片是一个带有感应功能的钥匙，侧面开关拨到ON或1即为开启，开启后您靠近车辆自动感应解锁，远离车辆自动感应上锁，方便实用您可放心使用。（注：蓝牙信号人体、金属遮挡会有所衰减）";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 12){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"手机感应与钥匙感应功能一样，都是靠近感应解锁，远离感应上锁。手机开启感应功能，建议把APP加入手机白名单，保持后台运行。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 13){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"该钥匙侧面有一个感应功能开关，关闭感应功能便和普通遥控钥匙一样。如拨开开关，钥匙便具有感应功能，建议您开关开启使用感应功能。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 14){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"此功能为自动锁车，车辆解锁且车轮45秒不转的状态下自动锁车功能，防止用户忘记锁车导致丢车；\n如您不需要此功能，可在手机APP绑定车辆的该车详情页进行关闭。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 15){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>车叫是因为车上锁后会防盗报警，有碰触会鸣叫报警（所有防盗器的基本功能）；\n2>请确认您遥控钥匙手柄是否有“静音上锁”功能，如有您按下键就不会报警器鸣叫了；\n2>您还可下载我们APP绑定该车辆，在手机APP里有“静音上锁”按钮，点击后即为锁车报警后不再鸣叫。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 16){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"座垫锁为电子座垫锁：\n1>车辆解锁状态（一键启动灯闪烁），长按一键启动按钮可开启座垫；\n2>遥控钥匙手柄按下“开座垫”键可直接打开座垫；\n3>手机APP绑定车辆后，点击主界面“开启座垫锁”按钮即可开座垫。\n\n座垫锁为机械锁：\n通过机械钥匙开启座垫锁。";
        
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 17){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"只需要购买我们同款类型钥匙配件，在手机APP配件管理里面便可配置钥匙。（感应钥匙配置功能暂未上线）";
        
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 18){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"绑定车辆后，点击首页车辆图片进入该车辆详情页，最下面有解绑车辆按钮；";
        
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 19){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"手机连上车辆，手机会自动体检车辆，并报告车辆故障信息，爱车安全一手掌握。";
        
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 20){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.selectNum = 21;
        helpVc.detailLab = @"1>确保感应钥匙开关打开（开关拨向ON或1），若开关已打开车辆为上锁状态，靠近车辆车辆会自动解锁并有解锁声音；\n2>如果手机APP绑定过车辆，请切换到该钥匙车辆，在手机界面查看感应钥匙连接状态，如显示电量为零请更换电池便可，如为“×”看不到感应钥匙电量即为失效。\n3>打开手机APP，显示感应钥匙已开启且有电，您可调节感应钥匙距离看感应是否恢复。";
        
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 21){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"请到买车门店咨询服务。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 22){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>目前我们产品不带GPS定位追踪功能，地图定位为手机当前位置定位；\n2>骑行导航是根据百度地图进行二次开发，专为电动车定制的骑行导航。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 23){
        
        helpVc.helpDetail =
        helpVc.detailLab = @"1>温度：显示当前车辆的温度；\n2>电压：显示当前车辆的电压，方便您预估车辆可行驶里程。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 24){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = @"1>在侧滑栏“意见反馈”里反馈您遇到的问题，最好留下您的联系方式，便于我们及时帮您解决问题；\n2>在侧滑栏“设置”里面有我们的服务热线及号码，您可以直接拨打客服热线；\n3>在您买车的门店反馈，并让他们帮您解决问题。";
        [self.navigationController pushViewController:helpVc animated:YES];
    }
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
}
    
- (void)dealloc
    {
        NSLog(@"%s dealloc",object_getClassName(self));
    }
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    @end
