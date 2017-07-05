
/*!
 *  @header LEETheme.h
 *  @brief  LEE主题管理
 *
 *  @author LEE
 *  @copyright    Copyright © 2016 - 2017年 lee. All rights reserved.
 *  @version    V1.1.5
 */

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


