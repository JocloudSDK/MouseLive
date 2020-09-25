//
//  UICollectionViewCell+Extension.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "UICollectionViewCell+Extension.h"
#import <objc/message.h>

static const void *isAnchorKey = "isAnchorKey";
 
@implementation UICollectionViewCell (Extension)

- (BOOL)hasChildViewController
{
 return [objc_getAssociatedObject(self, isAnchorKey) boolValue];
}

- (void)setYy_isAnchor:(BOOL)isAnchor
{
    objc_setAssociatedObject(self, isAnchorKey, [NSNumber numberWithBool:isAnchor],OBJC_ASSOCIATION_ASSIGN);
}

@end
