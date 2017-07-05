//
//  ThemeConfigModel.m
//  testTheme
//
//  Created by 伟运体育 on 2017/7/5.
//  Copyright © 2017年 伟运体育. All rights reserved.
//

#import "ThemeConfigModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ThemeManager.h"


static NSString * const ThemeChangingNotificaiton = @"ThemeChangingNotificaiton";
static NSString * const ThemeAddTagNotificaiton = @"ThemeAddTagNotificaiton";
static NSString * const ThemeRemoveTagNotificaiton = @"ThemeRemoveTagNotificaiton";
static NSString * const ThemeCurrentTag = @"ThemeCurrentTag";

#pragma mark - ----------------主题设置模型----------------

@interface ThemeConfigModel ()

@property (nonatomic , copy ) void(^modelUpdateCurrentThemeConfig)();
@property (nonatomic , copy ) void(^modelConfigThemeChangingBlock)();

@property (nonatomic , copy ) ThemeChangingBlock modelChangingBlock;

@property (nonatomic , copy ) NSString *modelCurrentThemeTag;

// @{tag : @{block : value}}
@property (nonatomic , strong ) NSMutableDictionary <NSString * , NSMutableDictionary *>*modelThemeBlockConfigInfo;
// @{keypath : @{tag : value}}
@property (nonatomic , strong ) NSMutableDictionary <NSString * , NSMutableDictionary *>*modelThemeKeyPathConfigInfo;
// @{selector : @{tag : @[@[parameter, parameter,...] , @[...]]}}
@property (nonatomic , strong ) NSMutableDictionary <NSString * , NSMutableDictionary *>*modelThemeSelectorConfigInfo;

@end

@implementation ThemeConfigModel

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    objc_removeAssociatedObjects(self);
    
    _modelCurrentThemeTag = nil;
    _modelThemeBlockConfigInfo = nil;
    _modelThemeKeyPathConfigInfo = nil;
    _modelThemeSelectorConfigInfo = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (ConfigThemeToChangingBlock)ThemeChangingBlock{
    
    __weak typeof(self) weakSelf = self;
    
    return ^(ThemeChangingBlock changingBlock){
        
        if (changingBlock) {
            
            weakSelf.modelChangingBlock = changingBlock;
            
            if (weakSelf.modelConfigThemeChangingBlock) weakSelf.modelConfigThemeChangingBlock();
        }
        
        return weakSelf;
    };
}

@end

#pragma mark - ----------------主题设置----------------

@implementation NSObject (ThemeConfigObject)

- (void)theme_dealloc{
    
    if ([self isTheme]) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ThemeChangingNotificaiton object:nil];
        
        objc_removeAssociatedObjects(self);
    }
    
    [self theme_dealloc];
}

- (BOOL)isChangeTheme{
    
    return (!self.theme.modelCurrentThemeTag || ![self.theme.modelCurrentThemeTag isEqualToString:[ThemeManager currentThemeTag]]) ? YES : NO;
}

- (void)Theme_ChangeThemeConfigNotify:(NSNotification *)notify{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self isChangeTheme]) {
            
            if (self.theme.modelChangingBlock) self.theme.modelChangingBlock([ThemeManager currentThemeTag] , self);
            
            [CATransaction begin];
            
            [CATransaction setDisableActions:YES];
            
            [self changeThemeConfig];
            
            [CATransaction commit];
        }
    });
}

- (void)setInv:(NSInvocation *)inv Sig:(NSMethodSignature *)sig Obj:(id)obj Index:(NSInteger)index{
    
    if (sig.numberOfArguments <= index) return;
    
    char *type = (char *)[sig getArgumentTypeAtIndex:index];
    
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
    BOOL unsupportedType = NO;
    
    switch (*type) {
        case 'v': // 1: void
        case 'B': // 1: bool
        case 'c': // 1: char / BOOL
        case 'C': // 1: unsigned char
        case 's': // 2: short
        case 'S': // 2: unsigned short
        case 'i': // 4: int / NSInteger(32bit)
        case 'I': // 4: unsigned int / NSUInteger(32bit)
        case 'l': // 4: long(32bit)
        case 'L': // 4: unsigned long(32bit)
        { // 'char' and 'short' will be promoted to 'int'.
            int value = [obj intValue];
            [inv setArgument:&value atIndex:index];
        } break;
            
        case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
        case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
        {
            long long value = [obj longLongValue];
            [inv setArgument:&value atIndex:index];
        } break;
            
        case 'f': // 4: float / CGFloat(32bit)
        { // 'float' will be promoted to 'double'.
            double value = [obj doubleValue];
            float valuef = value;
            [inv setArgument:&valuef atIndex:index];
        } break;
            
        case 'd': // 8: double / CGFloat(64bit)
        {
            double value = [obj doubleValue];
            [inv setArgument:&value atIndex:index];
        } break;
            
        case '*': // char *
        case '^': // pointer
        {
            if ([obj isKindOfClass:UIColor.class]) obj = (id)[obj CGColor]; //CGColor转换
            if ([obj isKindOfClass:UIImage.class]) obj = (id)[obj CGImage]; //CGImage转换
            void *value = (__bridge void *)obj;
            [inv setArgument:&value atIndex:index];
        } break;
            
        case '@': // id
        {
            id value = obj;
            [inv setArgument:&value atIndex:index];
        } break;
            
        case '{': // struct
        {
            if (strcmp(type, @encode(CGPoint)) == 0) {
                CGPoint value = [obj CGPointValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGSize)) == 0) {
                CGSize value = [obj CGSizeValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGRect)) == 0) {
                CGRect value = [obj CGRectValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGVector)) == 0) {
                CGVector value = [obj CGVectorValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                CGAffineTransform value = [obj CGAffineTransformValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                CATransform3D value = [obj CATransform3DValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(NSRange)) == 0) {
                NSRange value = [obj rangeValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(UIOffset)) == 0) {
                UIOffset value = [obj UIOffsetValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                UIEdgeInsets value = [obj UIEdgeInsetsValue];
                [inv setArgument:&value atIndex:index];
            } else {
                unsupportedType = YES;
            }
        } break;
            
        case '(': // union
        {
            unsupportedType = YES;
        } break;
            
        case '[': // array
        {
            unsupportedType = YES;
        } break;
            
        default: // what?!
        {
            unsupportedType = YES;
        } break;
    }
    
    NSAssert(unsupportedType == NO, @"方法的参数类型暂不支持");
}

- (void)changeThemeConfig{
    
    self.theme.modelCurrentThemeTag = [ThemeManager currentThemeTag];
    
    NSString *tag = [ThemeManager currentThemeTag];
    
    // Block
    
    for (id blockKey in self.theme.modelThemeBlockConfigInfo[tag]) {
        
        id value = self.theme.modelThemeBlockConfigInfo[tag][blockKey];
        
        if ([value isKindOfClass:NSNull.class]) {
            
            ThemeConfigBlock block = (ThemeConfigBlock)blockKey;
            
            if (block) block(self);
            
        } else {
            
            ThemeConfigBlockToValue block = (ThemeConfigBlockToValue)blockKey;
            
            if (block) block(self , value);
        }
    }
    
    // KeyPath
    
    for (id keyPath in self.theme.modelThemeKeyPathConfigInfo) {
        
        NSDictionary *info = self.theme.modelThemeKeyPathConfigInfo[keyPath];
        
        id value = info[tag];
        
        if ([keyPath isKindOfClass:NSString.class]) {
            
            [self setValue:value forKeyPath:keyPath];
        }
    }
    
    // Selector
    
    for (NSString *selector in self.theme.modelThemeSelectorConfigInfo) {
        
        NSDictionary *info = self.theme.modelThemeSelectorConfigInfo[selector];
        
        NSArray *valuesArray = info[tag];
        
        for (NSArray *values in valuesArray) {
            
            SEL sel = NSSelectorFromString(selector);
            
            NSMethodSignature * sig = [self methodSignatureForSelector:sel];
            
            if (!sig) [self doesNotRecognizeSelector:sel];
            
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            
            if (!inv) [self doesNotRecognizeSelector:sel];
            
            [inv setTarget:self];
            
            [inv setSelector:sel];
            
            if (sig.numberOfArguments == values.count + 2) {
                
                [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSInteger index = idx + 2;
                    
                    [self setInv:inv Sig:sig Obj:obj Index:index];
                }];
                
                [inv invoke];
                
            } else {
                
                NSAssert(YES, @"参数个数与方法参数个数不匹配");
            }
        }
    }
}

- (ThemeConfigModel *)theme{
    
    ThemeConfigModel *model = objc_getAssociatedObject(self, _cmd);
    
    if (!model) {
        
        NSAssert(![self isKindOfClass:[ThemeConfigModel class]], @"是不是点多了? ( *・ω・)✄╰ひ╯ ");
        
        model = [ThemeConfigModel new];
        
        objc_setAssociatedObject(self, _cmd, model , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Theme_ChangeThemeConfigNotify:) name:ThemeChangingNotificaiton object:nil];
        
        [self setIsTheme:YES];
        
        __weak typeof(self) weakSelf = self;
        
        model.modelUpdateCurrentThemeConfig = ^{
            
            if (weakSelf) [weakSelf changeThemeConfig];
        };
        
        model.modelConfigThemeChangingBlock = ^{
            
            if (weakSelf) weakSelf.theme.modelChangingBlock([ThemeManager currentThemeTag], weakSelf);
        };
    }
    return model;
}

- (void)setTheme:(ThemeConfigModel *)theme{
    
    if(self) objc_setAssociatedObject(self, @selector(theme), theme , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTheme{
    
    return self ? [objc_getAssociatedObject(self, _cmd) boolValue] : NO;
}

- (void)setIsTheme:(BOOL)isTheme{
    
    if (self) objc_setAssociatedObject(self, @selector(isTheme), @(isTheme) , OBJC_ASSOCIATION_ASSIGN);
}

@end

