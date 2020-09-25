//
//  WaterMarkAdapter.h
//  MouseLive
//
//  Created by Peter Xi on 2020/6/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThunderEngine.h"

NS_ASSUME_NONNULL_BEGIN

/**
    watermark based on 720P
 */
@interface WaterMarkAdapter : NSObject

@property (nonatomic, assign,readwrite) float DEF_WIDTH;    //default video width
@property (nonatomic, assign,readwrite) float DEF_HEIGHT;   //default video height

@property (nonatomic, assign,readwrite) float startX;   //image point on video view x
@property (nonatomic, assign,readwrite) float startY;   //image point on video view y
@property (nonatomic, assign,readwrite) float width;    //image width
@property (nonatomic, assign,readwrite) float height;   //image height

@property (nonatomic, copy,readwrite) NSString* imgUrl; //image path


-(ThunderImage *)createThunderBoltImage:(float)videoWidth videoHeight:(float)videoHeight rotation:(int)rotation;

@end

NS_ASSUME_NONNULL_END
