//
//  InputFingerprintViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "iflyMSC/iflyMSC.h"
#import "PcmPlayer.h"

@class IFlySpeechSynthesizer;

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,    //Normal TTS
    UriType             = 6,    //URI TTS
};

//state of TTS
typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2,
    Paused              = 4,
};

@protocol inputFingerprinDelegate <NSObject>

@optional

-(void) inputFingerprintOver;

@end

@interface InputFingerprintViewController : BaseViewController<IFlySpeechSynthesizerDelegate>
@property(nonatomic,assign) NSInteger deviceNum;
@property (nonatomic,weak) id<inputFingerprinDelegate> delegate;
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;

@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, assign) BOOL hasError;

@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, strong) PcmPlayer *audioPlayer;

@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;

@end
