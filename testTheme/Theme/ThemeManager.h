//
//  ThemeManager.h
//  testTheme
//
//  Created by 伟运体育 on 2017/7/5.
//  Copyright © 2017年 伟运体育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double ThemeVersionNumber;
FOUNDATION_EXPORT const unsigned char ThemeVersionString[];


@interface ThemeManager : NSObject

+ (ThemeManager *)shareTheme;

+ (void)startTheme:(NSString *)tag;

/**
 *  当前主题标签
 *
 *  @return 主题标签 tag
 */
+ (NSString *)currentThemeTag;

+ (void)changeTheme:(NSString *)themeType;

-(UIImage *)themeWithImage:(NSString *)imageName;

-(UIColor *)themeWithTextColor;

@end


