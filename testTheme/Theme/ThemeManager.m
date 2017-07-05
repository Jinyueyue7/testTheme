/*!
 *  @header LEETheme.m
 *
 *  @brief  LEE主题管理
 *
 *  @author LEE
 *  @copyright    Copyright © 2016 - 2017年 lee. All rights reserved.
 *  @version    V1.1.5
 */


#import "ThemeManager.h"

#import <objc/runtime.h>
#import <objc/message.h>

static NSString * const ThemeChangingNotificaiton = @"ThemeChangingNotificaiton";
static NSString * const ThemeCurrentTag = @"ThemeCurrentTag";

@interface ThemeManager ()

@property (nonatomic , copy ) NSString *currentTag;

@property (nonatomic,strong)NSUserDefaults *userDeaults;

@end

@implementation ThemeManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userDeaults=[NSUserDefaults standardUserDefaults];
    }
    return self;
}

+ (ThemeManager *)shareTheme{
    
    static ThemeManager *themeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        themeManager = [[ThemeManager alloc]init];
    });
    
    return themeManager;
}

+ (void)startTheme:(NSString *)tag{
    
//    NSAssert([[LEETheme shareTheme].allTags containsObject:tag], @"所启用的主题不存在 - 请检查是否添加了该%@主题的设置" , tag);
    
    if (!tag) return;
    
    [ThemeManager shareTheme].currentTag = tag;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChangingNotificaiton object:nil userInfo:nil];
}

#pragma mark Public
+ (NSString *)currentThemeTag{
    
    return [ThemeManager shareTheme].currentTag ? [ThemeManager shareTheme].currentTag : [[ThemeManager shareTheme].userDeaults objectForKey:ThemeCurrentTag];
}

+ (void)changeTheme:(NSString *)themeType
{
    if (!themeType) return;
    
    [ThemeManager shareTheme].currentTag = themeType;
    
//    [[LEETheme shareTheme]setCurrentTag:themeType];
    

    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChangingNotificaiton object:nil userInfo:nil];
}

-(void)setCurrentTag:(NSString *)currentTag
{
    _currentTag = currentTag;
    
    [self.userDeaults setObject:currentTag forKey:ThemeCurrentTag];
    
    [self.userDeaults synchronize];
}

-(UIImage *)themeWithImage:(NSString *)imageName
{
    // 拼接image前面的路径
    NSString *imageNamePath = [NSString stringWithFormat:@"%@/%@",[ThemeManager shareTheme].currentTag,imageName];
    
    // 创建对应UIImage对象
    return [UIImage imageNamed:imageNamePath];
}

-(UIColor *)themeWithTextColor
{
    // 1.获取plist文件的路径
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.plist", [ThemeManager shareTheme].currentTag,[ThemeManager shareTheme].currentTag];
    NSString *textColorFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    // 2.加载plist文件
    NSDictionary *textColorDict = [NSDictionary dictionaryWithContentsOfFile:textColorFilePath];
    
    // 3.获取字典中对应的RGB的值
    NSString *textColorString = textColorDict[@"textColor"];
    
//    // 4.取出对应的RGB值
//    NSArray *textColorArray = [textColorString componentsSeparatedByString:@","];
//    NSInteger red = [textColorArray[0] integerValue];
//    NSInteger green = [textColorArray[1] integerValue];
//    NSInteger blue = [textColorArray[2] integerValue];
    
//    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
    
    return [self leeTheme_ColorWithHexString:textColorString];
}

- (UIColor *)leeTheme_ColorWithHexString:(NSString *)hexString{
    
    if (!hexString) return nil;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
        case 0:
            return nil;
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start: 0 length: 1];
            green = [self colorComponentFrom:colorString start: 1 length: 1];
            blue  = [self colorComponentFrom:colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start: 0 length: 1];
            red   = [self colorComponentFrom:colorString start: 1 length: 1];
            green = [self colorComponentFrom:colorString start: 2 length: 1];
            blue  = [self colorComponentFrom:colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start: 0 length: 2];
            green = [self colorComponentFrom:colorString start: 2 length: 2];
            blue  = [self colorComponentFrom:colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start: 0 length: 2];
            red   = [self colorComponentFrom:colorString start: 2 length: 2];
            green = [self colorComponentFrom:colorString start: 4 length: 2];
            blue  = [self colorComponentFrom:colorString start: 6 length: 2];
            break;
        default:
            alpha = 0, red = 0, blue = 0, green = 0;
            break;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (CGFloat)colorComponentFrom:(NSString *) string start:(NSUInteger)start length:(NSUInteger) length{
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0f;
}

@end

