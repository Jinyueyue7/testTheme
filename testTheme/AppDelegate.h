//
//  AppDelegate.h
//  testTheme
//
//  Created by 伟运体育 on 2017/7/5.
//  Copyright © 2017年 伟运体育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

