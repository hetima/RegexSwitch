//
//  RGSRegexSwitch.m
//  RGSRegexSwitch
//
//  Created by hetima on 2014/04/30.
//  Copyright (c) 2014 hetima. All rights reserved.
// 

#import "RGSRegexSwitch.h"
#import "RGSFindBarAgent.h"
#import "RGSFindNavigatorAgent.h"

static RGSRegexSwitch *sharedPlugin;

@interface RGSRegexSwitch()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation RGSRegexSwitch


+ (BOOL)shouldLoadPlugin
{
    NSString *currentApplicationName = [[NSBundle mainBundle]infoDictionary][@"CFBundleName"];
    if (![currentApplicationName isEqual:@"Xcode"]){
        return NO;
    }
    
    // check something
    if (![RGSFindBarAgent shouldLoadPlugin]) {
        return NO;
    }
    if (![RGSFindNavigatorAgent shouldLoadPlugin]) {
        return NO;
    }
    
    return YES;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    if ([self shouldLoadPlugin]) {
        dispatch_once(&onceToken, ^{
            [RGSFindBarAgent setup];
            [RGSFindNavigatorAgent setup];
        });
    }else{
        NSLog(@"RGSRegexSwitch was not loaded. shouldLoadPlugin==NO");
    }
}

- (instancetype)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        _bundle = plugin;
    }


    return self;
}



@end
