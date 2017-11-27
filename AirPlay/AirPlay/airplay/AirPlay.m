//
//  AirPlay.m
//  AirPlay
//
//  Created by XH-LWR on 2017/11/27.
//  Copyright © 2017年 XH-LWR. All rights reserved.
//

#import "AirPlay.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AirPlay ()

@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, weak) UIButton *airplayButton;
/** Returns `true` | `false` if there are or not available devices for casting via AirPlay */
@property (nonatomic, assign) BOOL isAvailable;
/** Returns `true` | `false` if AirPlay availability is being monitored or not */
@property (nonatomic, assign) BOOL isBeingMonitored;

@end

static NSString *AirPlayKVOButtonAlphaKey = @"alpha";

static AirPlay *airplay = nil;

@implementation AirPlay

+ (instancetype)share {
    
    @synchronized (self) {
        
        if (airplay ==  nil) {
            
            airplay = [[AirPlay alloc] init];
        }
    }
    return airplay;
}

#pragma mark - Private Methods

- (void)audioRouteHasChanged {
    
    __weak typeof(self) weakSelf = self;
    [[AVAudioSession sharedInstance].currentRoute.outputs enumerateObjectsUsingBlock:^(AVAudioSessionPortDescription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.portType isEqualToString:@"AirPlay"]) {
            
            weakSelf.connectedDevice = obj.portName;
            *stop = YES;
        }
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:AirPlayKVOButtonAlphaKey]) {
        
        if (object && [object isKindOfClass:UIButton.class]) {
            
            BOOL newAvailabilityStatus;
            if ([change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]]) {
                
                newAvailabilityStatus = [change[NSKeyValueChangeNewKey] floatValue] == 1;
            } else {
                
                newAvailabilityStatus = NO;
            }
            if (self.isAvailable != newAvailabilityStatus) {
                
                self.isAvailable = newAvailabilityStatus;
                if (self.isAvailable && self.whenAvailable) {
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteHasChanged) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
                    self.whenAvailable();
                } else if (self.whenUnavailable) {
                    
                    self.whenUnavailable();
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
                }
            }
            self.isAvailable = newAvailabilityStatus;
        }
    }
}

#pragma mark - Public Methods

- (void)start {
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.window = window;
    [self.window addSubview:self.volumeView];
    
    for (UIView *v in self.volumeView.subviews) {
        
        if ([NSStringFromClass(v.class) containsString:@"Button"]) {
            
            self.airplayButton = (UIButton *)v;
            [self.airplayButton addObserver:self forKeyPath:AirPlayKVOButtonAlphaKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
            [self.airplayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            self.isBeingMonitored = YES;
        }
    }
}

- (void)stop {
    
    if (self.airplayButton) {
        
        [self.airplayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self.airplayButton removeObserver:self forKeyPath:AirPlayKVOButtonAlphaKey];
        self.isBeingMonitored = NO;
    }
}

#pragma mark - Geter/Setter

- (void)setConnectedDevice:(NSString *)connectedDevice {
    
    _connectedDevice = connectedDevice;
    if (connectedDevice && self.whenRouteChanged) {
        
        self.whenRouteChanged();
    }
}

- (MPVolumeView *)volumeView {
    
    if (!_volumeView) {
        
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 1, 1)];
        _volumeView.showsRouteButton = YES;
        _volumeView.showsVolumeSlider = NO;
    }
    return _volumeView;
}

@end
