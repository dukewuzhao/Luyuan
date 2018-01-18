//
//  PickerChoiceView.h
//  TFPickerView
//
//  Created by TF_man on 16/5/11.
//  Copyright © 2016年 tituanwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TFPickerDelegate <NSObject>

@optional;

- (void)PickerSelectorIndixString:(NSString *)str;

- (void)PickerSelectorIndixColour:(UIColor *)color;


@end

typedef NS_ENUM(NSInteger, ARRAYTYPE) {
    GenderArray,
    HeightArray,
    weightArray,
    DeteArray,
    DeteAndTimeArray,
    ColourArray
    
    
};

@interface PickerChoiceView : UIView
//设置类型
@property (nonatomic, assign) ARRAYTYPE arrayType;
//自定义类型
@property (nonatomic, strong) NSArray *customArr;

@property (nonatomic,strong)UILabel *selectLb;

@property (nonatomic,weak)id<TFPickerDelegate>delegate;

@property (nonatomic,strong)NSString *selectStr;


@end
