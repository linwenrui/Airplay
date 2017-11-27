//
//  ViewController.m
//  AirPlay
//
//  Created by XH-LWR on 2017/11/27.
//  Copyright © 2017年 XH-LWR. All rights reserved.
//

#import "ViewController.h"
#import "AirPlay.h"

@interface ViewController ()

@property (nonatomic, strong) AirPlay *airPlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.airPlay = [AirPlay share];
    self.airPlay.whenAvailable = ^(){
        
        NSLog(@"激活");
    };
    
    self.airPlay.whenUnavailable = ^() {
        
        NSLog(@"失活");
    };
    
    self.airPlay.whenRouteChanged = ^(){
        
        NSLog(@"%@", self.airPlay.connectedDevice);
    };
}

- (IBAction)start {
    
    [self.airPlay start];
}

- (IBAction)quit {
    
    [self.airPlay stop];
}


@end
