//
//  HelpViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/11/3.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : BaseViewController
{
    NSArray *_sectionArray;//每个section的数据
    NSMutableDictionary *_showDic;//用来判断分组展开与收缩的
}
@end
