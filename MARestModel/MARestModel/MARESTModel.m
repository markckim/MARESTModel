//
//  MARESTModel.m
//  MARestModel
//
//  Created by Mark Kim on 4/25/16.
//  Copyright © 2016 Mark Kim. All rights reserved.
//

#import "MARESTModel.h"
#import "MASessionManager.h"
#import "AFNetworking.h"
#import "NSDictionary+UrlEncoding.h"

@implementation MARESTModel

+ (NSString *)baseUrl
{
    // over-ride
    return @"";
}

+ (NSString *)api
{
    // over-ride
    return @"";
}

+ (NSString *)username
{
    // over-ride
    return @"";
}

+ (NSString *)password
{
    // over-ride
    return @"";
}

+ (NSString *)contentType
{
    // over-ride
    return @"";
}

+ (NSString *)accept
{
    // over-ride
    return @"";
}

+ (NSDictionary *)authHeaderParams
{
    // over-ride, if needed
    
    // username and password value
    NSString *username = [self username];
    NSString *password = [self password];
    
    // HTTP basic authentication
    NSString *authenticationString = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authenticationData = [authenticationString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authenticationValue = [authenticationData base64EncodedStringWithOptions:0];
    NSString *authHeaderValue = [NSString stringWithFormat:@"Basic %@", authenticationValue];
    NSDictionary *authHeaderParams = @{
                                       @"Authorization": authHeaderValue,
                                       };
    return authHeaderParams;
}

+ (NSString *)urlStringWithObjectId:(NSString *)objectId
{
    // over-ride, if needed
    NSString *baseUrl = [self baseUrl];
    NSString *objectIdFormatted = objectId ? [NSString stringWithFormat:@"/%@", objectId] : @"";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", baseUrl, [self api], objectIdFormatted];
    return urlString;
}

+ (id<AbstractJSONModelProtocol>)_getObjectForJSON:(id)JSON objectReturnType:(NSString *)objectReturnType
{
    id <AbstractJSONModelProtocol> obj = nil;
    if (objectReturnType) {
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            NSError *error = nil;
            if ([objectReturnType isEqualToString:@"NSDictionary"]) {
                obj = JSON;
            } else {
                obj = [[NSClassFromString(objectReturnType) alloc] initWithDictionary:JSON error:&error];
                if (error) {
                    NSLog(@"_get Object For JSON: something went wrong with json deserialization; error: %@", error.description);
                    obj = nil;
                }
            }
        } else {
            NSLog(@"JSON is not an NSDictionary: %@", JSON);
        }
    }
    return obj;
}

+ (id)_dataToReturnForJSON:(id)JSON jsonKey:(NSString *)jsonKey objectReturnType:(NSString *)objectReturnType
{
    id dataToReturn = nil;
    if (jsonKey) {
        id keyedJSON = [JSON objectForKey:jsonKey];
        if ([keyedJSON isKindOfClass:[NSArray class]]) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            for (id dict in keyedJSON) {
                id <AbstractJSONModelProtocol> obj = [self _getObjectForJSON:dict objectReturnType:objectReturnType];
                if (obj) {
                    [tmpArray addObject:obj];
                }
            }
            dataToReturn = tmpArray;
        } else if ([keyedJSON isKindOfClass:[NSString class]]) {
            dataToReturn = keyedJSON;
        } else {
            NSLog(@"keyedJSON is not an NSArray: %@", keyedJSON);
        }
    } else {
        id <AbstractJSONModelProtocol> obj = [self _getObjectForJSON:JSON objectReturnType:objectReturnType];
        dataToReturn = obj;
    }
    return dataToReturn;
}

+ (NSString *)_encodedStringFromParams:(NSDictionary *)params
{
    NSString *paramsString = nil;
    NSMutableDictionary *paramsToPopulate = [[NSMutableDictionary alloc] init];
    if (params) {
        [paramsToPopulate addEntriesFromDictionary:params];
        NSMutableDictionary *tmpParams = [paramsToPopulate mutableCopy];
        [tmpParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsToPopulate setObject:[obj description] forKey:key];
        }];
        if ([paramsToPopulate count] > 0) {
            paramsString = [paramsToPopulate urlEncodedString];
        }
    }
    return paramsString;
}

+ (NSString *)_urlParamsString:(NSDictionary *)urlParams
{
    NSString *urlParamsString = nil;
    NSString *encodedString = [self _encodedStringFromParams:urlParams];
    urlParamsString = [NSString stringWithFormat:@"?%@", encodedString];
    return urlParamsString;
}

+ (NSURLRequest *)_getRequestForMethod:(NSString *)method
                              objectId:(NSString *)objectId
                              jsonData:(NSDictionary *)jsonData
                             urlParams:(NSDictionary *)urlParams
                          headerParams:(NSDictionary *)headerParams
{
    NSMutableURLRequest *request = nil;
    NSMutableString *urlString = [NSMutableString stringWithString:[self urlStringWithObjectId:objectId]];
    
    // url params
    NSString *urlParamsString = [self _urlParamsString:urlParams];
    if (urlParamsString && ![urlParamsString isEqualToString:@""]) {
        [urlString appendString:urlParamsString];
    }
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    request.HTTPMethod = method;
    
    // auth
    NSDictionary *authHeaderParams = [self authHeaderParams];
    if (authHeaderParams) {
        [authHeaderParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // header
    if (headerParams) {
        [headerParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // content type
    NSString *contentType = [self contentType];
    if ([contentType length] > 0) {
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    // accept
    NSString *accept = [self accept];
    if ([accept length] > 0) {
        [request addValue:accept forHTTPHeaderField:@"Accept"];
    }
    
    // data
    if (jsonData) {
        NSData *postData = nil;
        if ([contentType isEqualToString:@"application/json"]) {
            NSError *error;
            postData = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
            if (error) {
                NSLog(@"_get Request For Method: something went wrong with json deserialization; error: %@", error.description);
            }
        } else if ([contentType isEqualToString:@"application/x-www-form-urlencoded"]) {
            NSString *encodedString = [self _encodedStringFromParams:jsonData];
            postData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
        }
        if (postData) {
            [request setHTTPBody:postData];
        }
    }
    return request;
}

+ (NSUInteger)_runWithMethod:(NSString *)method
                    objectId:(NSString *)objectId
            objectReturnType:(NSString *)objectReturnType
                    jsonData:(NSDictionary *)jsonData
                     jsonKey:(NSString *)jsonKey
                   urlParams:(NSDictionary *)urlParams
                headerParams:(NSDictionary *)headerParams
           completionHandler:(MARequestObjectCompletionHandler)completionHandler
                errorHandler:(MARequestErrorHandler)errorHandler
{
    NSUInteger taskIdentifier = 0;
    __block MARequestObjectCompletionHandler completionHandlerCopy = [completionHandler copy];
    __block MARequestErrorHandler errorHandlerCopy = [errorHandler copy];
    __block MARequestSuccessHandler successHandler = ^(id JSON, NSString *jsonKey, NSString *objectString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id dataToReturn = [self _dataToReturnForJSON:JSON jsonKey:jsonKey objectReturnType:objectReturnType];
            if (completionHandlerCopy) {
                // TODO: fix and use *userInfo, if needed
                completionHandlerCopy(dataToReturn, nil);
            }
        });
    };
    __block MARequestFailureHandler failureHandler = ^(id JSON, NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,
                                                       NSString *method, NSString *objectId, NSString *objectString, NSDictionary *jsonData) {
        NSLog(@"error statusCode: %ld", (long)response.statusCode);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorHandlerCopy) {
                errorHandlerCopy(request, response, error, JSON);
            }
        });
    };
    __block NSURLRequest *requestToSend = [self _getRequestForMethod:method objectId:objectId jsonData:jsonData urlParams:urlParams headerParams:headerParams];
    AFURLSessionManager *manager = [[MASessionManager sharedInstance] sessionManager];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:requestToSend
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                    NSLog(@"\nhttpResp: %@", response.description);
                                                    if (!error) {
                                                        successHandler(responseObject, jsonKey, NSStringFromClass([self class]));
                                                    } else {
                                                        failureHandler(responseObject, requestToSend, (NSHTTPURLResponse *)response,
                                                                       error, method, objectId, NSStringFromClass([self class]), jsonData);
                                                    }
                                                }];
    taskIdentifier = dataTask.taskIdentifier;
    [dataTask resume];
    return taskIdentifier;
}

+ (NSUInteger)postWithJsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler
{
    return [self _runWithMethod:@"POST" objectId:nil objectReturnType:NSStringFromClass([self class]) jsonData:jsonData jsonKey:nil urlParams:nil headerParams:nil completionHandler:completionHandler errorHandler:errorHandler];
}

+ (NSUInteger)getWithObjectId:(NSString *)objectId jsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler
{
    return [self _runWithMethod:@"GET" objectId:objectId objectReturnType:NSStringFromClass([self class]) jsonData:jsonData jsonKey:nil urlParams:nil headerParams:nil completionHandler:completionHandler errorHandler:errorHandler];
}

+ (NSUInteger)putWithObjectId:(NSString *)objectId jsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler
{
    return [self _runWithMethod:@"PUT" objectId:objectId objectReturnType:NSStringFromClass([self class]) jsonData:jsonData jsonKey:nil urlParams:nil headerParams:nil completionHandler:completionHandler errorHandler:errorHandler];
}

+ (NSUInteger)deleteWithObjectId:(NSString *)objectId jsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler
{
    return [self _runWithMethod:@"DELETE" objectId:objectId objectReturnType:NSStringFromClass([self class]) jsonData:jsonData jsonKey:nil urlParams:nil headerParams:nil completionHandler:completionHandler errorHandler:errorHandler];
}

+ (NSUInteger)getObjectsWithJsonData:(NSDictionary *)jsonData urlParams:(NSDictionary *)urlParams jsonKey:(NSString *)jsonKey completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler
{
    return [self _runWithMethod:@"GET" objectId:nil objectReturnType:NSStringFromClass([self class]) jsonData:jsonData jsonKey:jsonKey urlParams:urlParams headerParams:nil completionHandler:completionHandler errorHandler:errorHandler];
}

@end
