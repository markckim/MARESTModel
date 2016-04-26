//
//  MASessionManager.h
//  MARestModel
//
//  Created by Mark Kim on 4/25/16.
//  Copyright © 2016 Mark Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFURLSessionManager;

@interface MASessionManager : NSObject

+ (instancetype)sharedInstance;

- (AFURLSessionManager *)sessionManager;

@end
