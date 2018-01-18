//
//  PickerChoiceView.m
//  TFPickerView
//
//  Created by TF_man on 16/5/11.
//  Copyright © 2016年 tituanwang. All rights reserved.
//
//屏幕宽和高
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

//RGB
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

// 缩放比
#define kScale ([UIScreen mainScreen].bounds.size.width) / 375

#define hScale ([UIScreen mainScreen].bounds.size.height) / 667

//字体大小
#define kfont 15

#import "PickerChoiceView.h"
#import "Masonry.h"

@interface PickerChoiceView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *_colorArray;
}

@property (nonatomic,strong)UIView *bgV;

@property (nonatomic,strong)UIButton *cancelBtn;

@property (nonatomic,strong)UIButton *conpleteBtn;

@property (nonatomic,strong)UIPickerView *pickerV;

@property (nonatomic,strong)UIDatePicker *datePickeV;

@property (nonatomic,strong)UIView *line;


@property (nonatomic,strong)NSMutableArray *array;
@end

@implementation PickerChoiceView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.array = [NSMutableArray array];
        
        [self creatUIFrame:frame];
        
    }
    return self;
}

- (void)creatUIFrame:(CGRect)frame{
    
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.bgV = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, kScreenWidth, 260*hScale)];
    self.bgV.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgV];
    [self showAnimation];
    
    //取消
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgV addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(44);
        
    }];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:kfont];
    //[self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    //[self.cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn setTitleColor:RGBA(0, 122, 255, 1) forState:UIControlStateNormal];
    //完成
    self.conpleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgV addSubview:self.conpleteBtn];
    [self.conpleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(44);
        
    }];
    self.conpleteBtn.titleLabel.font = [UIFont systemFontOfSize:kfont];
    [self.conpleteBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.conpleteBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.conpleteBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    
    //选择titi
    self.selectLb = [UILabel new];
    [self.bgV addSubview:self.selectLb];
    [self.selectLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgV.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.conpleteBtn.mas_centerY).offset(0);
    }];
    self.selectLb.font = [UIFont systemFontOfSize:kfont];
    self.selectLb.textAlignment = NSTextAlignmentCenter;
    
    //线
    UIView *line = [UIView new];
    self.line = line;
    [self.bgV addSubview:self.line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.cancelBtn.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(0.5);
        
    }];
    line.backgroundColor = RGBA(224, 224, 224, 1);
    
    //选择器
    self.pickerV = [UIPickerView new];
    [self.bgV addSubview:self.pickerV];
    [self.pickerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line.mas_bottom).offset(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        
    }];
    self.pickerV.delegate = self;
    self.pickerV.dataSource = self;
    
}

- (void)setCustomArr:(NSArray *)customArr{
    
    _customArr = customArr;
    [self.array addObject:customArr];
    
}

- (void)setSelectStr:(NSString *)selectStr{
    
    if (selectStr.length == 0) return;
    _selectStr = selectStr;
    
    switch (self.arrayType) {
        case GenderArray:{
            NSArray *genderArr = [self.array objectAtIndex:0];
            
            [self.pickerV selectRow:[self indexOfNSArray:genderArr WithStr:selectStr] inComponent:0 animated:YES];
        }
            break;
        case HeightArray:{
            NSArray *heightArr = [self.array objectAtIndex:0];
            [self.pickerV selectRow:[self indexOfNSArray:heightArr WithStr:selectStr] inComponent:0 animated:YES];
        }
            break;
        case weightArray:{
            NSArray *weightArr = [self.array objectAtIndex:0];
            [self.pickerV selectRow:[self indexOfNSArray:weightArr WithStr:selectStr] inComponent:0 animated:YES];
        }
            break;
        case DeteArray:{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:selectStr];
            if (date) {
                [self.datePickeV setDate:date animated:YES];
            }
            
        }
            break;
        case DeteAndTimeArray:{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *date = [dateFormatter dateFromString:selectStr];
            if (date) {
                [self.datePickeV setDate:date animated:YES];
            }
        }
            break;
        case ColourArray:{
            
            NSArray *colourArr = [self.array objectAtIndex:0];
            [self.pickerV selectRow:[self indexOfNSArray:colourArr WithStr:selectStr] inComponent:0 animated:YES];
        }
            break;
        default:
            break;
    }
    
    //自定义动画
    if (self.customArr) {
        NSArray *customArr = [self.array objectAtIndex:0];
        [self.pickerV selectRow:[self indexOfNSArray:customArr WithStr:selectStr] inComponent:0 animated:YES];
    }
    
    
}

- (void)setArrayType:(ARRAYTYPE)arrayType
{
    _arrayType = arrayType;
    switch (arrayType) {
        case GenderArray:{
            [self GenderArray];
        }
            break;
        case HeightArray:{
            [self HeightArray];
        }
            break;
        case weightArray:
        {
            [self weightArray];
        }
            break;
        case DeteArray:
        {
            self.selectLb.text = @"选择生日";
            [self creatDate:UIDatePickerModeDate];
            NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
            self.datePickeV.locale = locale;
            self.datePickeV.minuteInterval = 1;
            NSDate *date = [NSDate date];
            self.datePickeV.maximumDate = date;
        }
            break;
        case DeteAndTimeArray:
        {
            self.selectLb.text = @"选择比赛时间";
            [self creatDate:UIDatePickerModeDateAndTime];
        }
            break;
        case ColourArray:{
            [self ColourArray];
        }
            break;
        default:
            break;
    }
}

- (void)ColourArray{
    
    self.selectLb.text = @"选择颜色";
    [self.array addObject:@[@"橙",@"紫",@"灰",@"白",@"红",@"蓝",@"黄",@"黑",@"绿",@"青"]];
    _colorArray = @[[UIColor orangeColor],
                    [UIColor purpleColor],
                    [UIColor grayColor],
                    [UIColor whiteColor],
                    [UIColor redColor],
                    [UIColor blueColor],
                    [UIColor yellowColor],
                    [UIColor blackColor],
                    [UIColor greenColor],
                    [UIColor cyanColor]];
    
}

- (void)GenderArray{
    self.selectLb.text = @"选择性别";
    [self.array addObject:@[@"男",@"女"]];
}

- (void)HeightArray{
    self.selectLb.text = @"选择身高";
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 100; i <= 250; i++) {
        
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [arr addObject:str];
    }
    [self.array addObject:(NSArray *)arr];
}
- (void)weightArray{
    self.selectLb.text = @"选择体重";
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 30; i <= 200; i++) {
        
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [arr addObject:str];
    }
    [self.array addObject:(NSArray *)arr];
}

- (void)creatDate:(UIDatePickerMode)DatePickerMode{
    
    [self.pickerV removeFromSuperview];
    //选择器
    self.datePickeV = [UIDatePicker new];
    [self.bgV addSubview:self.datePickeV];
    [self.datePickeV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom).offset(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        
    }];

    self.datePickeV.datePickerMode = DatePickerMode;
}

#pragma mark-----UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerVie{
    return self.array.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSArray * arr = (NSArray *)[self.array objectAtIndex:component];
    return arr.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label=[[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    if (self.arrayType == ColourArray) {
        UIView *colorV = [UIView new];
        colorV.backgroundColor = [_colorArray objectAtIndex:row];
        colorV.clipsToBounds = YES;
        colorV.layer.borderWidth = 0.5;
        colorV.layer.borderColor = [UIColor grayColor].CGColor;
        colorV.layer.cornerRadius = 6;
        [label addSubview:colorV];
        [colorV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.mas_equalTo(label.mas_centerY);
            make.right.equalTo(label.mas_left).offset(10);
            make.width.mas_equalTo(12);
            make.height.mas_equalTo(12);
        }];
    }
    return label;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSArray *arr = (NSArray *)[self.array objectAtIndex:component];
    return [arr objectAtIndex:row % arr.count];
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 110;
}

//防止崩溃
- (NSUInteger)indexOfNSArray:(NSArray *)arr WithStr:(NSString *)str{
    
    NSUInteger chosenDxInt = 0;
    if (str && ![str isEqualToString:@""]) {
        chosenDxInt = [arr indexOfObject:str];
        if (chosenDxInt == NSNotFound)
            chosenDxInt = 0;
    }
    return chosenDxInt;
}

- (void)cancelBtnClick{
    
    [self hideAnimation];
}

- (void)completeBtnClick{
    
    NSString *fullStr = [NSString string];
    if (self.arrayType == DeteArray) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd"];
        fullStr = [outputFormatter stringFromDate:self.datePickeV.date];
    }else if (self.arrayType == DeteAndTimeArray){
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        fullStr = [outputFormatter stringFromDate:self.datePickeV.date];
        
    }else{
        for (int i = 0; i < self.array.count; i++) {
            
            NSArray *arr = [self.array objectAtIndex:i];
            NSString *str = [arr objectAtIndex:[self.pickerV selectedRowInComponent:i]];
            if (self.arrayType == ColourArray) {
                UIColor *color = [_colorArray objectAtIndex:[self.pickerV selectedRowInComponent:i]];
                
                if([self.delegate respondsToSelector:@selector(PickerSelectorIndixColour:)])
                {
                    [self.delegate PickerSelectorIndixColour:color];
                }
            }
            fullStr = [fullStr stringByAppendingString:str];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(PickerSelectorIndixString:)])
    {
        [self.delegate PickerSelectorIndixString:fullStr];
    }
    
    [self hideAnimation];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self hideAnimation];
    
}

//隐藏动画
- (void)hideAnimation{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect frame = self.bgV.frame;
        frame.origin.y = self.frame.size.height;
        self.bgV.frame = frame;
        
    } completion:^(BOOL finished) {
        
        [self.bgV removeFromSuperview];
        [self removeFromSuperview];
    }];
}

//显示动画
- (void)showAnimation{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect frame = self.bgV.frame;
        frame.origin.y = self.frame.size.height-260*hScale;
        self.bgV.frame = frame;
    }];
    
}


@end
