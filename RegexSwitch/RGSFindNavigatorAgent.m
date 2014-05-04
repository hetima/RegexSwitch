//
//  RGSFindNavigatorAgent.m
//  RegexSwitch
//
//  Created by hetima on 2014/05/02.
//  Copyright (c) 2014 hetima. All rights reserved.
//

#import "RGSFindNavigatorAgent.h"
#import "RGSRegexModeButton.h"

@implementation RGSFindNavigatorAgent

+ (BOOL)shouldLoadPlugin
{
    Class findNaviClass=NSClassFromString(@"IDEBatchFindNavigator");
    if (!findNaviClass) return NO;
    Ivar ivar;
    ivar=class_getInstanceVariable(findNaviClass, "_firstLevelIndex");
    if (!ivar) return NO;
    //ivar=class_getInstanceVariable(findNaviClass, "_secondLevelIndex");
    //if (!ivar) return NO;
    //ivar=class_getInstanceVariable(findNaviClass, "_thirdLevelIndex");
    //if (!ivar) return NO;
    ivar=class_getInstanceVariable(findNaviClass, "_pathControl");
    if (!ivar) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"selectedNavigable")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"setSelectedNavigable:")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"_setSelectedNavigable:")]) return NO;
    if (![findNaviClass instancesRespondToSelector:NSSelectorFromString(@"rootNavigables")]) return NO;
    
    return YES;
}

+ (void)actRegexButtonClick:(RGSRegexModeButton*)sender
{
    id findNavi=sender.reference;
    id selectedNavigable=objc_msgSend(findNavi, NSSelectorFromString(@"selectedNavigable"));
    if (!selectedNavigable) {
        return;
    }

    Ivar ivar=class_getInstanceVariable([findNavi class], "_firstLevelIndex");
    int firstLevelIndex=(int)(__bridge void*)object_getIvar(findNavi, ivar);
    //ivar=class_getInstanceVariable([findNavi class], "_secondLevelIndex");
    //int secondLevelIndex=(int)(__bridge void*)object_getIvar(findNavi, ivar);
    //ivar=class_getInstanceVariable([findNavi class], "_thirdLevelIndex");
    //int thirdLevelIndex=(int)(__bridge void*)object_getIvar(findNavi, ivar);
    
    //LOG(@"L:%d,%d,%d", firstLevelIndex, secondLevelIndex, thirdLevelIndex);
    // find > regex ==0,3,0
    // replace > regex ==1,1,0
    id firstLevelItem; //IDEBatchFindPathControlNavigable : IDENavigableItem
    
    NSArray *rootNavigables=objc_msgSend(findNavi, NSSelectorFromString(@"rootNavigables"));
    if (firstLevelIndex==0) {
        firstLevelItem=[rootNavigables firstObject];
        
    }else if (firstLevelIndex==1){
        firstLevelItem=[rootNavigables lastObject];
    }
    if (firstLevelItem) {
        NSArray *secondLevelItems=objc_msgSend(firstLevelItem, NSSelectorFromString(@"arrangedChildItems"));
        id textItem=[secondLevelItems firstObject];
        id regexItem=[secondLevelItems lastObject];
        id itemToSelect=nil;
        if (regexItem!=selectedNavigable) {
            itemToSelect=regexItem;
        }else if(textItem){
            itemToSelect=textItem;
        }
        if (itemToSelect) {
            objc_msgSend(findNavi, NSSelectorFromString(@"setSelectedNavigable:"), itemToSelect);
        }
    }
}

+ (void)findNavigator:(id)findNavi navigableItemSelected:(id)navigableItem
{
    //IDEBatchFindPathControlNavigable
    //represents: IDEBatchFindPathBarMatchStyleType or IDEBatchFindPathBarMatchStyleTypeOption

    if (![navigableItem respondsToSelector:@selector(representedObject)]) {
        return;
    }
    RGSRegexModeButton* regexModeButton=[self regexModeButtonForFindNavi:findNavi];
    if (!regexModeButton) {
        return;
    }
    
    int findType=0;
    id rep=[navigableItem representedObject];
    if ([[rep className]isEqualToString:@"IDEBatchFindPathBarMatchStyleType"] &&
        [rep respondsToSelector:NSSelectorFromString(@"findType")]) {
        findType=(int)objc_msgSend(rep, NSSelectorFromString(@"findType"));
    }
    [regexModeButton setFindType:findType];
}


+ (RGSRegexModeButton*)regexModeButtonForFindNavi:(id)findNavi
{
    Ivar ivar=class_getInstanceVariable([findNavi class], "_pathControl");
    NSView* pathControl=object_getIvar(findNavi, ivar);
    
    NSView* superview=[pathControl superview];
    NSArray* views=[superview subviews];
    for (NSView* view in views) {
        if ([view isKindOfClass:[RGSRegexModeButton class]]) {
            return (RGSRegexModeButton*)view;
        }
    }

    if (!pathControl) {
        return nil;
    }
    
    RGSRegexModeButton* btn=[RGSRegexModeButton regexModeButton];
    btn.reference=findNavi;
    
    // layout
    NSRect frame=[pathControl frame];
    
    NSRect newRect, remainRect;
    NSDivideRect(frame, &newRect, &remainRect, (CGFloat)18, NSMinXEdge);
    [pathControl setFrame:remainRect];
    [superview addSubview:btn];
    newRect.size.height=RGSRegexModeButtonSize;
    newRect.size.width=RGSRegexModeButtonSize;
    newRect.origin.y+=(CGFloat)1;
    [btn setFrame:newRect];
    
    [btn setAction:@selector(actRegexButtonClick:)];
    [btn setTarget:[self class]];
    
    return btn;
}

+ (void)installButtonToFindNavi:(id)findNavi
{
    id selectedNavigable=objc_msgSend(findNavi, NSSelectorFromString(@"selectedNavigable"));
    if (!selectedNavigable) {
        return;
    }

    [self findNavigator:findNavi navigableItemSelected:selectedNavigable];
}

+ (void)setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        KZRMETHOD_SWIZZLING_WITHBLOCK("IDEBatchFindNavigator", "_setSelectedNavigable:", KZRInstanceMethod, call, sel,
        ^(id slf, id navigableItem){
            call.as_void(slf, sel, navigableItem);
            [RGSFindNavigatorAgent findNavigator:slf navigableItemSelected:navigableItem];
        });

        KZRMETHOD_SWIZZLING_WITHBLOCK("IDEBatchFindNavigator", "viewDidInstall", KZRInstanceMethod, call, sel,
        ^(id slf){
            call.as_void(slf, sel);
            [RGSFindNavigatorAgent installButtonToFindNavi:slf];
            
        });
        
    });
}

@end
