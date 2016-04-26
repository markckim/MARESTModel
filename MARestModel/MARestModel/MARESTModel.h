//
//  MARESTModel.h
//  MARestModel
//
//  Created by Mark Kim on 4/25/16.
//  Copyright © 2016 Mark Kim. All rights reserved.
//

#import <JSONModel/JSONModel.h>

typedef void (^MARequestObjectCompletionHandler)(id obj, NSDictionary *userInfo);
typedef void (^MARequestErrorHandler)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);
typedef void (^MARequestSuccessHandler)(id JSON, NSString *jsonKey, NSString *objectString);
typedef void (^MARequestFailureHandler)(id JSON, NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,
                                        NSString *method, NSString *objectId, NSString *objectString, NSDictionary *jsonData);

@interface MARESTModel : JSONModel

// rest api
+ (NSUInteger)postWithJsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler;
+ (NSUInteger)getWithObjectId:(NSString *)objectId jsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler;
+ (NSUInteger)putWithObjectId:(NSString *)objectId jsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler;
+ (NSUInteger)deleteWithObjectId:(NSString *)objectId jsonData:(NSDictionary *)jsonData completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler;
+ (NSUInteger)getObjectsWithJsonData:(NSDictionary *)jsonData urlParams:(NSDictionary *)urlParams jsonKey:(NSString *)jsonKey completionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler;

// over-ride
+ (NSString *)baseUrl;
+ (NSString *)api;
+ (NSString *)username;
+ (NSString *)password;
+ (NSString *)contentType;
+ (NSString *)accept;
+ (NSDictionary *)authHeaderParams;
+ (NSString *)urlStringWithObjectId:(NSString *)objectId;

// private
+ (NSUInteger)_runWithMethod:(NSString *)method
                    objectId:(NSString *)objectId
            objectReturnType:(NSString *)objectReturnType
                    jsonData:(NSDictionary *)jsonData
                     jsonKey:(NSString *)jsonKey
                   urlParams:(NSDictionary *)urlParams
                headerParams:(NSDictionary *)headerParams
           completionHandler:(MARequestObjectCompletionHandler)completionHandler
                errorHandler:(MARequestErrorHandler)errorHandler;
@end
