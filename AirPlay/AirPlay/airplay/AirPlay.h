//
//  AirPlay.h
//  AirPlay
//
//  Created by XH-LWR on 2017/11/27.
//  Copyright © 2017年 XH-LWR. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AirPlayHandler)(void);

@interface AirPlay : NSObject

/** Returns Device's name if connected, if not, it returns `nil` */
@property (nonatomic, copy) NSString *connectedDevice;

@property (nonatomic, copy) AirPlayHandler whenAvailable;
@property (nonatomic, copy) AirPlayHandler whenUnavailable;
@property (nonatomic, copy) AirPlayHandler whenRouteChanged;

+ (instancetype)share;

- (void)start;

- (void)stop;

@end
