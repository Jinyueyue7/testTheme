//
//  ThemeConfigModel.h
//  testTheme
//
//  Created by 伟运体育 on 2017/7/5.
//  Copyright © 2017年 伟运体育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class ThemeConfigModel;

typedef void(^ThemeConfigBlock)(id item);
typedef void(^ThemeConfigBlockToValue)(id item , id value);
typedef void(^ThemeChangingBlock)();
typedef ThemeConfigModel *(^ConfigThemeToChangingBlock)(ThemeChangingBlock);
typedef ThemeConfigModel *(^ConfigThemeToT_Block)(NSString *tag , ThemeConfigBlock);
typedef ThemeConfigModel *(^ConfigThemeToTs_Block)(NSArray *tags , ThemeConfigBlock);
typedef ThemeConfigModel *(^ConfigThemeToIdentifierAndBlock)(NSString *identifier , ThemeConfigBlockToValue);

@interface ThemeConfigModel : NSObject

/** ----默认设置方式---- */

/** Block */

/** 主题改变Block -> 格式: .ThemeChangingBlock(^(NSString *tag , id item){ code... }) */
@property (nonatomic , copy , readonly ) ConfigThemeToChangingBlock ThemeChangingBlock;

@end


@interface NSObject (ThemeConfigObject)

@property (nonatomic , strong ) ThemeConfigModel *theme;

@end
