//
//  MAIntercomModel.h
//  MARestModel
//
//  Created by Mark Kim on 4/25/16.
//  Copyright © 2016 Mark Kim. All rights reserved.
//

#import "MARESTModel.h"

@interface MAIntercomModel : MARESTModel
+ (NSUInteger)testWithCompletionHandler:(MARequestObjectCompletionHandler)completionHandler errorHandler:(MARequestErrorHandler)errorHandler;
@end
