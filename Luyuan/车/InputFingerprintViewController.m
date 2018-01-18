//
//  InputFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "InputFingerprintViewController.h"
#import "SuccessInputFingerprint.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>
#import "TTSConfig.h"

@interface InputFingerprintViewController ()<SuccessInputFingerprintDelegate>{
    int time;
    NSInteger fingerNum;
    NSInteger fingerPressNum;
    NSInteger callBackCount;
    BOOL speechcompletion;
}
@property(nonatomic,weak)UIImageView *fingerIcon;
@property(nonatomic,strong)MSWeakTimer *countTimer;
//@property(nonatomic,strong)MSWeakTimer *testFinger;
@property(nonatomic,strong)SuccessInputFingerprint *successVc;
@property(nonatomic,weak)UILabel *countLab;
@end

@implementation InputFingerprintViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initSynthesizer];
    [self startSynBtnHandler:@"您好，请按语音提示操作"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_iFlySpeechSynthesizer stopSpeaking];
    [_audioPlayer stop];
    _iFlySpeechSynthesizer.delegate = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureNavgationItemTitle:@"录入指纹"];
    time = 20;
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.successVc = [[SuccessInputFingerprint alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight)];
    self.successVc.delegate = self;
    [self getfingernumber];
    [self setupView];
    [self setupTime];
    [self TestFingerpress];
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_FingerPrint object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3004"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                //[self removeFingerPressTest];
                self ->fingerPressNum = 0;
                [self.countTimer invalidate];
                [self uploadFingerPrint];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                self ->speechcompletion = NO;
                [self startSynBtnHandler:@"请再按手指"];
                [self TestFingerpress];
                self.fingerIcon.image = [UIImage imageNamed:@"fingerprint_step_one"];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"02"]){
                self ->speechcompletion = NO;
                [self startSynBtnHandler:@"请最后按下手指"];
                [self TestFingerpress];
                self.fingerIcon.image = [UIImage imageNamed:@"fingerprint_step_two"];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"FF"]){
                //[self removeFingerPressTest];
                [SVProgressHUD showSimpleText:@"指纹录入失败"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                
                [SVProgressHUD showSimpleText:@"指纹录入失败"];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                self->speechcompletion = NO;
                [self startSynBtnHandler:@"请按手指"];
                [self sendInputfingerHex];
            }
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_TestFingerPress object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3006"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]&& self->speechcompletion) {
                self ->fingerPressNum++;
                if (self ->fingerPressNum == 1) {
                    
                    NSString *passwordHEX;
                    if (self ->fingerNum == 10) {
                        passwordHEX = [NSString stringWithFormat:@"A500000730050A"];
                    }else{
                        passwordHEX = [NSString stringWithFormat:@"A500000730050%d",self ->fingerNum];
                    }
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                }else if (self ->fingerPressNum == 2){
                    
                    //[self removeFingerPressTest];
                    NSString *passwordHEX = [NSString stringWithFormat:@"A50000073004F1"];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    self->time = 20;
                }else if (self ->fingerPressNum == 3){
                    
                    //[self removeFingerPressTest];
                    NSString *passwordHEX = [NSString stringWithFormat:@"A50000073004F2"];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    self->time = 20;
                }
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                //[self startSpeech];
                [self TestFingerpress];
            }else{
                
                [self TestFingerpress];
            }
        }
    }];
    
#pragma mark - Setting For URI TTS
    
    //URI TTS: -(void)synthesize:(NSString *)text toUri:(NSString*)uri
    //If uri is nil, the audio file is saved in library/cache by defailt.
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //Set the audio file name for URI TTS
    _uriPath = [NSString stringWithFormat:@"%@/%@",prePath,@"uri.pcm"];
    _audioPlayer = [[PcmPlayer alloc] init];
    
}


-(void)getfingernumber{
    NSArray *array1 = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    NSMutableArray *posary = [[NSMutableArray alloc] init];
    for (FingerprintModel *fpmodel in fingerprintmodals) {
        [posary addObject:[NSString stringWithFormat:@"%d",fpmodel.pos]];
    }
    
    NSArray *array2 = [posary copy];
    NSMutableSet *set1 = [NSMutableSet setWithArray:array1];
    NSMutableSet *set2 = [NSMutableSet setWithArray:array2];
    [set1 minusSet:set2];      //取差集后 set1中为2，3，5，6
    NSMutableArray *posary2 = [[NSMutableArray alloc] init];
    for (NSString *num in set1) {
        [posary2 addObject: num];
    }
    
    NSArray *sort2Array = [[posary2 copy] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (([obj1 integerValue]) > ([obj2 integerValue])) { //不使用intValue比较无效
            return NSOrderedDescending;//降序
        }else if ([obj1 integerValue] < [obj2 integerValue]){
            return NSOrderedAscending;//升序
        }else {
            return NSOrderedSame;//相等
        }
    }];
    fingerNum = [sort2Array.firstObject integerValue];
}

#pragma mark -  SuccessInputFingerprintDelegate
-(void)InputFingerprintNext{
    
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    
    if (fingerprintmodals.count >= 10) {
        [SVProgressHUD showSimpleText:@"录入已达上限"];
        return;
    }
    
    [self.successVc removeFromSuperview];
    self.fingerIcon.image = [UIImage imageNamed:@"fingerprint_nomal"];
    self.countLab.text = @"20s";
    time = 20;
    [self getfingernumber];
    [self setupTime];
    [self TestFingerpress];
}
#pragma mark -  SuccessInputFingerprintDelegate
-(void)InputFingerprintSuccess{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupView{
    
    UILabel *PromptLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, ScreenWidth - 40, 20)];
    PromptLab.textAlignment = NSTextAlignmentCenter;
    PromptLab.textColor = [UIColor blackColor];
    PromptLab.text = @"放置手指";
    [self.view addSubview:PromptLab];
    
    UILabel *operationLab = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(PromptLab.frame)+20, ScreenWidth - 80, 50)];
    operationLab.textAlignment = NSTextAlignmentCenter;
    operationLab.textColor = [UIColor blackColor];
    operationLab.numberOfLines = 0;
    operationLab.text = @"将手指放在车辆指纹传感器上再移开，重复三次此操作";
    [self.view addSubview:operationLab];
    
    UIImageView *fingerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*.28, CGRectGetMaxY(operationLab.frame)+50, ScreenWidth*.44, ScreenWidth*.44*1.48)];
    fingerIcon.image = [UIImage imageNamed:@"fingerprint_nomal"];
    [self.view addSubview:fingerIcon];
    self.fingerIcon = fingerIcon;
    
    UILabel *countLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 20, CGRectGetMaxY(fingerIcon.frame)+60, 40, 20)];
    countLab.textAlignment = NSTextAlignmentCenter;
    countLab.textColor = [UIColor blackColor];
    countLab.text = @"20s";
    [self.view addSubview:countLab];
    self.countLab = countLab;
    
    [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
}

-(void)sendInputfingerHex{
    NSString *passwordHEX;
    if (fingerNum >= 10) {
        passwordHEX = [NSString stringWithFormat:@"A500000730040A"];
    }else{
        
        passwordHEX = [NSString stringWithFormat:@"A500000730040%d",fingerNum];
    }
    
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

-(void)setupTime{
    
    self.countTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTimerFired) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)countTimerFired{
    
    time--;
    self.countLab.text = [NSString stringWithFormat:@"%ds",time];
    
    if (time == 0) {
        
        [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        [self.countTimer invalidate];
        [SVProgressHUD showSimpleText:@"绑定超时"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//-(void)fingerPressTest{
//
//    self.testFinger = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(TestFingerpress) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
//}

-(void)TestFingerpress{
    
    NSString *passwordHEX = [NSString stringWithFormat:@"A50000063006"];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}


//-(void)removeFingerPressTest{
//
//    [self.testFinger invalidate];
//    self.testFinger = nil;
//}

-(void)startSpeech{
    if(callBackCount<1){
        callBackCount++;
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(VoiceAnnouncements) object:nil];
        [self performSelector:@selector(VoiceAnnouncements) withObject:nil afterDelay:2.0];//1秒后点击次数清零
    }
}

-(void)VoiceAnnouncements{
//    [_iFlySpeechSynthesizer stopSpeaking];
//    [_audioPlayer stop];
    callBackCount = 0;
    //[self startSynBtnHandler:@"请抬起手指再按"];
}

-(void)uploadFingerPrint{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/addfingerprint"];
    NSString *token = [QFTools getdata:@"token"];
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    NSNumber* dTime = [NSNumber numberWithDouble:nowTime];
    NSNumber *pos = [NSNumber numberWithDouble:fingerNum];
    NSString *name = [NSString stringWithFormat:@"指纹%d",fingerNum];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSDictionary *fp_info = [NSDictionary dictionaryWithObjectsAndKeys:pos,@"pos",name,@"name",dTime,@"added_time",nil];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_info": fp_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [SVProgressHUD showSimpleText:@"绑定指纹成功"];
            NSDictionary *data = dict[@"data"];
            NSMutableArray *fpsAry = data[@"fps"];
            
            for (NSDictionary *fpsInfo in fpsAry) {
                
                NSNumber *pos = fpsInfo[@"pos"];
                if (pos.integerValue == fingerNum) {
                    NSNumber *fpid = fpsInfo[@"fp_id"];
                    NSNumber *pos = fpsInfo[@"pos"];
                    NSString *name = fpsInfo[@"name"];
                    NSNumber *addedtime = fpsInfo[@"added_time"];
                    
                    FingerprintModel *fingermodel = [FingerprintModel modalWith:self.deviceNum fp_id:fpid.integerValue pos:pos.integerValue name:name added_time:addedtime.integerValue];
                    [LVFmdbTool insertFingerprintModel:fingermodel];
                }
            }
            
            if([self.delegate respondsToSelector:@selector(inputFingerprintOver)])
            {
                [self.delegate inputFingerprintOver];
            }
            
            [self.view addSubview:self.successVc];
            
        }else{
            [SVProgressHUD showSimpleText:@"绑定指纹失败"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}


- (void)startSynBtnHandler:(NSString *)title {
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = NomalType;
    
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    
    self.isCanceled = NO;
    
    _iFlySpeechSynthesizer.delegate = self;
    
    NSString* str= title;
    
    [_iFlySpeechSynthesizer startSpeaking:str];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
}

#pragma mark - IFlySpeechSynthesizerDelegate

/**
 callback of starting playing
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakBegin
{
    self.isCanceled = NO;
    _state = Playing;
}



/**
 callback of buffer progress
 Notice：
 Only apply to normal TTS
 **/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
    //NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}




/**
 callback of playback progress
 Notice：
 Only apply to normal TTS
 **/
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos
{
    //NSLog(@"speak progress %2d%%.", progress);
}


/**
 callback of pausing player
 Notice：
 Only apply to normal TTS
 **/
- (void)onSpeakPaused
{
    _state = Paused;
}


/**
 callback of TTS completion
 **/
- (void)onCompleted:(IFlySpeechError *) error
{
    if (error.errorCode != 0) {
        return;
    }
    NSString *text ;
    if (self.isCanceled) {
        text = NSLocalizedString(@"T_TTS_Cancel", nil);
    }else if (error.errorCode == 0) {
        text = NSLocalizedString(@"T_TTS_End", nil);
    }else {
        text = [NSString stringWithFormat:@"Error：%d %@",error.errorCode,error.errorDesc];
        self.hasError = YES;
        NSLog(@"%@",text);
    }
    
    _state = NotStart;
    
    if (_synType == UriType) {//URI TTS
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:_uriPath]) {
            [self playUriAudio];//play the audio file generated by URI TTS
        }
    }
    speechcompletion = YES;
}


#pragma mark - Initialization

- (void)initSynthesizer
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //TTS singleton
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //set speed,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //set volume,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //set pitch,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //set sample rate
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //set TTS speaker
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //set text encoding mode
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
}


#pragma mark - Playing For URI TTS

- (void)playUriAudio
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    _audioPlayer = [[PcmPlayer alloc] initWithFilePath:_uriPath sampleRate:[instance.sampleRate integerValue]];
    [_audioPlayer play];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    [self.countTimer invalidate];
    self.countTimer = nil;
    
//    [self.testFinger invalidate];
//    self.testFinger = nil;
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
