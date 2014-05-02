//
//  RGSRegexModeButton.h
//  RegexSwitch
//
//  Created by hetima on 2014/05/02.
//  Copyright (c) 2014 hetima. All rights reserved.
//

#import <AppKit/AppKit.h>

#define RGSRegexModeButtonSize (CGFloat)15

@interface RGSRegexModeButton : NSButton

@property (nonatomic, weak) id reference;

+ (instancetype)regexModeButton;

- (unsigned long long)findType;
- (void)setFindType:(unsigned long long)type;

@end
