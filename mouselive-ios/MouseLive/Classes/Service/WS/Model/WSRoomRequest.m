//
//  WSRoomRequest.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/16.
//  Copyright © 2020 sy. All rights reserved.
//

#import "WSRoomRequest.h"
#import <YYModel.h>


//@interface WSBaseRequestS : NSObject
//
//@property (nonatomic, copy) NSString* cmd;
//@property (nonatomic) id body;
//
//@end
//
//@implementation WSBaseRequestS
//
//@end

@implementation WSRoomRequest


//- (NSDictionary *)_yy_dictionaryWithJSON:(id)json {
//    if (!json || json == (id)kCFNull) return nil;
//    NSDictionary *dic = nil;
//    NSData *jsonData = nil;
//    if ([json isKindOfClass:[NSDictionary class]]) {
//        dic = json;
//    } else if ([json isKindOfClass:[NSString class]]) {
//        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
//    } else if ([json isKindOfClass:[NSData class]]) {
//        jsonData = json;
//    }
//    if (jsonData) {
//        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
//        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
//    }
//    return dic;
//}
//
//- (void)test {
//    // Convert model to json:
//    NSDictionary *json;
//    WSBaseRequestS* req = [WSBaseRequestS alloc];
//    req.body = self;
//    self.Uid = 213;
//    self.LiveRid = 123123;
//    req.cmd = @"owu0198";
//    json = [req yy_modelToJSONObject];
//
//    NSLog(@"[WebSocket] send, json = %@", json);
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
//    NSString* js = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    NSDictionary* response = [self _yy_dictionaryWithJSON:js];
//
//    NSLog(@"[WebSocket] send, json = %@", response);
//
//    WSCommonRequest* q = (WSCommonRequest*)[WSCommonRequest yy_modelWithJSON:response[@"body"]];
//
//    NSLog(@"[WebSocket] send, json = %@", q);
//}

@end
