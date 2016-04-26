//
//  MASessionManager.m
//  MARestModel
//
//  Created by Mark Kim on 4/25/16.
//  Copyright © 2016 Mark Kim. All rights reserved.
//

#import "MASessionManager.h"
#import "AFNetworking.h"

@interface MASessionManager ()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation MASessionManager

+ (instancetype)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    // initialize sharedObject as nil (first call only)
    __strong static MASessionManager *_sharedObject = nil;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        [_sharedObject _setup];
    });
    // returns the same object each time
    return _sharedObject;
}

- (void)_setup
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    _manager = manager;
}

- (AFURLSessionManager *)sessionManager
{
    return _manager;
}

@end
