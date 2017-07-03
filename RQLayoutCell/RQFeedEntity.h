//
//  RQFeedEntity.h
//  RQLayoutCell
//
//  Created by 蜂巢网络科技 on 2017/7/3.
//  Copyright © 2017年 fengchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RQFeedEntity : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *time;
@property (nonatomic, copy, readonly) NSString *imageName;

@end
