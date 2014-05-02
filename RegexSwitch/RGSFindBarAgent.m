//
//  RGSFindBarAgent.m
//  RegexSwitch
//
//  Created by hetima on 2014/05/01.
//  Copyright (c) 2014 hetima. All rights reserved.
//

#import "RGSFindBarAgent.h"
#import "KZRMethodSwizzlingWithBlock.h"
#import "RGSRegexModeButton.h"


@implementation RGSFindBarAgent

+ (BOOL)shouldLoadPlugin
{
    Class findNaviClass=NSClassFromString(@"DVTFindBar");
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"_optionsChanged:")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"viewDidInstall")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"optionsCtrl")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"_findField")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"_replaceField")]) return NO;
    
    return YES;
}


+ (id)optionCtrlOfFindBar:(id)findBar
{
    id optionCtl=objc_msgSend(findBar, NSSelectorFromString(@"optionsCtrl"));
    if (![optionCtl respondsToSelector:NSSelectorFromString(@"findType")]) {
        return nil;
    }
    if (![optionCtl respondsToSelector:NSSelectorFromString(@"setFindType:")]) {
        return nil;
    }
    return optionCtl;
}


+ (void)actRegexButtonClick:(RGSRegexModeButton*)sender
{
    id findBar=sender.reference;
    id optionCtl=[RGSFindBarAgent optionCtrlOfFindBar:findBar];
    if (!optionCtl) {
        return;
    }
    unsigned long long findType=[sender findType];
    unsigned long long current=(unsigned long long)objc_msgSend(optionCtl, NSSelectorFromString(@"findType"));
    if (findType != current) {
        objc_msgSend(optionCtl, NSSelectorFromString(@"setFindType:"), findType);
    }
}


+ (RGSRegexModeButton*)regexModeButtonForFindBar:(id)findBar
{
    NSView* findField=objc_msgSend(findBar, NSSelectorFromString(@"_findField"));
    NSView* superview=[findField superview];
    NSArray* views=[superview subviews];
    for (NSView* view in views) {
        if ([view isKindOfClass:[RGSRegexModeButton class]]) {
            return (RGSRegexModeButton*)view;
        }
    }
    return nil;
}


+ (void)installButtonToFindBar:(id)findBar
{

    if ([RGSFindBarAgent regexModeButtonForFindBar:findBar]) {
        return;
    }
    
    id optionCtl=[RGSFindBarAgent optionCtrlOfFindBar:findBar];
    if (!optionCtl) {
        return;
    }
    
    //Ivar ivar=class_getInstanceVariable([findBar class], "_findStringField");
    //NSView* findStringField=object_getIvar(findBar, ivar);
    NSView* findField=objc_msgSend(findBar, NSSelectorFromString(@"_findField"));
    if (!findField) {
        return;
    }
    
    RGSRegexModeButton* btn=[RGSRegexModeButton regexModeButton];
    btn.reference=findBar;
    
    // layout
    NSView* superview=[findField superview];
    NSRect frame=[findField frame];

    NSRect newRect, remainRect;
    NSDivideRect(frame, &newRect, &remainRect, (CGFloat)18, NSMinXEdge);
    [findField setFrame:remainRect];
    [superview addSubview:btn];
    newRect.size.height=RGSRegexModeButtonSize;
    newRect.size.width=RGSRegexModeButtonSize;
    newRect.origin.y+=(CGFloat)2;
    [btn setFrame:newRect];
    
    NSView* replaceField=objc_msgSend(findBar, NSSelectorFromString(@"_replaceField"));
    if (replaceField) {
        frame=[replaceField frame];
        NSDivideRect(frame, &newRect, &remainRect, (CGFloat)18, NSMinXEdge);
        [replaceField setFrame:remainRect];
    }
    
    // set state
    unsigned long long findType=(unsigned long long)objc_msgSend(optionCtl, NSSelectorFromString(@"findType"));
    [btn setFindType:findType];
    [btn setAction:@selector(actRegexButtonClick:)];
    [btn setTarget:[self class]];
    
}


+ (void)optionsChangedFindBar:(id)findBar
{
    RGSRegexModeButton* btn=[RGSFindBarAgent regexModeButtonForFindBar:findBar];
    if (btn) {
        id optionCtl=[RGSFindBarAgent optionCtrlOfFindBar:findBar];
        if (!optionCtl) {
            return;
        }
        unsigned long long findType=(unsigned long long)objc_msgSend(optionCtl, NSSelectorFromString(@"findType"));
        [btn setFindType:findType];
    }
}


+ (void)setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

    KZRMETHOD_SWIZZLING_WITHBLOCK("DVTFindBar", "_optionsChanged:", KZRInstanceMethod, call, sel,
    ^(id slf, id notification){
        call.as_void(slf, sel, notification);
        [RGSFindBarAgent optionsChangedFindBar:slf];
    });

    KZRMETHOD_SWIZZLING_WITHBLOCK("DVTFindBar", "viewDidInstall", KZRInstanceMethod, call, sel,
    ^(id slf){
        call.as_void(slf, sel);
        [RGSFindBarAgent installButtonToFindBar:slf];
    });


    });
}

@end
