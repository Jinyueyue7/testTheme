//
//  secondViewController.m
//  testTheme
//
//  Created by 伟运体育 on 2017/7/5.
//  Copyright © 2017年 伟运体育. All rights reserved.
//

#import "secondViewController.h"
#import "ThemeManager.h"
#import "ThemeConfigModel.h"

@interface secondViewController ()

@end

@implementation secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 80, 100, 100);
    
    [btn setTitle:@"hello" forState:UIControlStateNormal];
    
    btn.backgroundColor = [UIColor yellowColor];
    
    btn.theme.ThemeChangingBlock(^{
        [btn setImage:[[ThemeManager shareTheme]themeWithImage:@"1"] forState:UIControlStateNormal];
        
        [btn setTitleColor:[[ThemeManager shareTheme] themeWithTextColor] forState:UIControlStateNormal];
    });
    
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(100, 200, 100, 100);
    
    [btn2 setTitle:@"hello" forState:UIControlStateNormal];
    
    btn2.backgroundColor = [UIColor yellowColor];
    
    btn2.theme.ThemeChangingBlock(^{
        [btn2 setImage:[[ThemeManager shareTheme]themeWithImage:@"0"] forState:UIControlStateNormal];
        
        [btn2 setTitleColor:[[ThemeManager shareTheme] themeWithTextColor] forState:UIControlStateNormal];
    });
    
    //    [btn2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn2];
}

-(void)btnAction:(UIButton *)btn
{
    if (btn.selected) {
        btn.selected = NO;
        
        [ThemeManager changeTheme:@"red"];
        
    }else{
        btn.selected = YES;
        
        [ThemeManager changeTheme:@"blue"];
        
    }
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
