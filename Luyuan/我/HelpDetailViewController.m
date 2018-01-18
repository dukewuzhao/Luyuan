//
//  HelpDetailViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "HelpDetailViewController.h"
#import "TopLeftLabel.h"
@interface HelpDetailViewController ()

@end

@implementation HelpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"帮助中心"];
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self setupView];
    
}

-(void)setupView{

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin)];
    [self.view addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    CGPoint scrollPoint = CGPointMake(0, 0);
    scrollView.bounces = NO;
    [scrollView setContentOffset:scrollPoint animated:YES];
    
    UIView *cursorView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, 2, 20)];
    cursorView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [scrollView addSubview:cursorView];
    
    UILabel *helpDetail = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cursorView.frame)+20, cursorView.y, ScreenWidth - 40, 20)];
    helpDetail.textColor = [UIColor blackColor];
    helpDetail.text = self.helpDetail;
    helpDetail.font = [UIFont systemFontOfSize:16];
    helpDetail.numberOfLines = 0;
    [scrollView addSubview:helpDetail];
    
    if (self.selectNum == 2|| self.selectNum == 6 || self.selectNum == 21) {
        helpDetail.height = 40;
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(cursorView.x, CGRectGetMaxY(helpDetail.frame)+20, ScreenWidth - 15, 0.5)];
    lineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [scrollView addSubview:lineView];
    
    if (self.needPicture) {
        
        scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight + 20);
        UIImageView *mainImg = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(lineView.frame)+20, ScreenWidth-60, (ScreenWidth-60)*1.31)];
        mainImg.image = [UIImage imageNamed:@"binding_help"];
        [scrollView addSubview:mainImg];
        
        TopLeftLabel *detailLab = [[TopLeftLabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(mainImg.frame)+20, ScreenWidth - 30, ScreenHeight - (ScreenWidth-60)*1.31 - 75)];
        detailLab.text = self.detailLab;
        detailLab.font = [UIFont systemFontOfSize:14];
        detailLab.textColor = [QFTools colorWithHexString:@"#333333"];
        detailLab.numberOfLines = 0;
        detailLab.attributedText = [self getAttributedStringWithString:self.detailLab lineSpace:5];
        [scrollView addSubview:detailLab];
    }else{
        scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin);
        TopLeftLabel *detailLab = [[TopLeftLabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(lineView.frame)+20, ScreenWidth - 30, ScreenHeight - 75)];
        detailLab.text = self.detailLab;
        detailLab.font = [UIFont systemFontOfSize:14];
        detailLab.textColor = [QFTools colorWithHexString:@"#666666"];
        detailLab.numberOfLines = 0;
        detailLab.attributedText = [self getAttributedStringWithString:self.detailLab lineSpace:5];
        [scrollView addSubview:detailLab];
    }
}

-(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

- (void)dealloc{
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
