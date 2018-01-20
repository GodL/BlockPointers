//
//  AppDelegate.m
//  BlockPointers
//
//  Created by imac on 2018/1/11.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#import "NSObject+Block.h"
#import "BPBlock.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSObject *firstObject = [NSObject new];
    __attribute__((objc_precise_lifetime)) NSObject *object = [NSObject new];
    __weak NSObject *secondObject = object;
    NSObject *thirdObject = [NSObject new];
    
    __unused void (^block)(void) = ^{
        __unused NSObject *first = firstObject;
        __unused NSObject *second = secondObject;
        __unused NSObject *third = thirdObject;
        NSLog(@"%p  %p  %p",&first,&second,&third);
    };
    block();
    FBObjectiveCBlock *cb = [[FBObjectiveCBlock alloc] initWithObject:block configuration:[FBObjectGraphConfiguration new]];
    NSSet *objs = [cb allRetainedObjects];
    [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"fb  = %@",obj);
    }];
    id block_ = block;
    NSArray *arr = [block_ blockStrongPointers];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"bpblock == %@",obj);
    }];
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
