//
//  main.m
//  CommonControllers-C08
//
//  Created by BobZhang on 16/6/15.
//  Copyright © 2016年 BobZhang. All rights reserved.
//

//#define TBVC_01
//#define TBVC_03
#define TBVC_06

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "TestBedViewController.h"

@interface TestBedAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong,nonatomic) UIWindow *window;
@end

@implementation TestBedAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.tintColor = COOKBOOK_PURPLE_COLOR;
    
#ifdef TBVC_01
    TBVC_01_Pick_Snap_Image *tbvc = [[TBVC_01_Pick_Snap_Image alloc]init];
#endif
    
#ifdef TBVC_03
    TBVC_03_Record_Trim_Save_Play_Video *tbvc = [[TBVC_03_Record_Trim_Save_Play_Video alloc]init];
#endif

#ifdef TBVC_06
    TBVC_06_Edit_Video *tbvc = [[TBVC_06_Edit_Video alloc]init];
#endif
    
    UINavigationController *rootVC = [[UINavigationController alloc]initWithRootViewController:tbvc];
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([TestBedAppDelegate class]));
    }
}
