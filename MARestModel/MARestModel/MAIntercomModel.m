//
//  MAIntercomModel.m
//  MARestModel
//
//  Created by Mark Kim on 4/25/16.
//  Copyright © 2016 Mark Kim. All rights reserved.
//

#import "MAIntercomModel.h"

@implementation MAIntercomModel

+ (NSString *)api
{
    return @"users";
}

+ (NSUInteger)testWithCompletionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler
{
    return [self getObjectsWithJsonData:nil urlParams:@{@"user_id": @"skinner"} jsonKey:@"id" completionHandler:completionHandler errorHandler:errorHandler];
}

+ (NSString *)contentType
{
    return @"application/x-www-form-urlencoded";
}

+ (NSString *)accept
{
    return @"application/json";
}

+ (NSString *)urlStringWithObjectId:(NSString *)objectId
{
    NSString *baseUrl = @"";
    NSString *objectIdFormatted = objectId ? [NSString stringWithFormat:@"/%@", objectId] : @"";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", baseUrl, [self api], objectIdFormatted];
    return urlString;
}

@end
