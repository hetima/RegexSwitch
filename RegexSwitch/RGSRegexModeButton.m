//
//  RGSRegexModeButton.m
//  RegexSwitch
//
//  Created by hetima on 2014/05/02.
//  Copyright (c) 2014 hetima. All rights reserved.
//

#import "RGSRegexModeButton.h"

@implementation RGSRegexModeButton

+ (instancetype)regexModeButton
{
    static NSImage* onImage=nil;
    static NSImage* offImage=nil;
    
    if (!onImage || offImage) {
        NSBundle* bundle=[NSBundle bundleForClass:[RGSRegexModeButton class]];
        NSString* path=[bundle pathForResource:@"regex_on" ofType:@"png"];
        onImage=[[NSImage alloc]initWithContentsOfFile:path];
        path=[bundle pathForResource:@"regex_off" ofType:@"png"];
        offImage=[[NSImage alloc]initWithContentsOfFile:path];
    }
    
    
    RGSRegexModeButton* btn=[[RGSRegexModeButton alloc]initWithFrame:NSMakeRect(0, 0, RGSRegexModeButtonSize, RGSRegexModeButtonSize)];
    [btn setButtonType:NSSwitchButton];
    [btn setImagePosition:NSImageOnly];
    [[btn cell]setImageScaling:NSImageScaleProportionallyDown];
    [btn setImage:offImage];
    [btn setAlternateImage:onImage];
    
    return btn;
}


- (unsigned long long)findType
{
    if ([self state]==NSOnState) {
        return 1;
    }
    return 0;
}


- (void)setFindType:(unsigned long long)type
{
    if (type==1) {
        [self setState:NSOnState];
    }else{
        [self setState:NSOffState];
    }
}

@end
