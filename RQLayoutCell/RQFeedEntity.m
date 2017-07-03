//
//  RQFeedEntity.m
//  RQLayoutCell
//
//  Created by 蜂巢网络科技 on 2017/7/3.
//  Copyright © 2017年 fengchao. All rights reserved.
//

#import "RQFeedEntity.h"

@implementation RQFeedEntity

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = super.init;
    if (self) {
        _identifier = [self uniqueIdentifier];
        _title = dictionary[@"title"];
        _content = dictionary[@"content"];
        _username = dictionary[@"username"];
        _time = dictionary[@"time"];
        _imageName = dictionary[@"imageName"];
    }
    return self;
}

- (NSString *)uniqueIdentifier
{
    static NSInteger counter = 0;
    
    return [NSString stringWithFormat:@"unique-id-%@", @(counter++)];
}


@end
