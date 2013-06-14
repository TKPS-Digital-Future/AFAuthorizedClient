//
//  AFAuthorizedClient.m
//  AFAuthorizedClient
//
//  Created by Patric Schenke on 14.06.13.
//
//

#import "AFAuthorizedClient.h"
#import "AFURLConnectionOperation.h"

@implementation AFAuthorizedClient

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    void (^authorizationFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *request, NSError *error)
    {
        BOOL investigateHTTP = NO;
        BOOL authorizationFailed = NO;
        
        NSInteger errorCode = error.code;
        
        switch (errorCode)
        {
            case NSURLErrorUserAuthenticationRequired:
            {
                authorizationFailed = YES;
            } break;
                
            case NSURLErrorUnknown:
            default:
            {
                investigateHTTP = YES;
            } break;
        }
        
        if (investigateHTTP)
        {
            NSDictionary *userInfo = error.userInfo;
            NSHTTPURLResponse *httpResponse = userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            NSInteger statusCode = httpResponse.statusCode;
            
            switch (statusCode)
            {
                case 401:
                {
                    authorizationFailed = YES;
                } break;
                    
                default:
                    break;
            }
        }
        
        if (authorizationFailed)
        {
            NSMutableURLRequest *mutableRequest = urlRequest.mutableCopy;
            
            NSMutableDictionary *headers = mutableRequest.allHTTPHeaderFields.mutableCopy;
            [headers setValue:self.authorizationDelegate.authorizationHeader forKey:@"Authorization"];
            
            mutableRequest.allHTTPHeaderFields = headers;
            
            AFHTTPRequestOperation *retryOperation = [self HTTPRequestOperationWithRequest:mutableRequest success:success failure:failure];
            [self enqueueHTTPRequestOperation:retryOperation];
        }
        else
        {
            failure(request, error);
        }
    };
    
    return [super HTTPRequestOperationWithRequest:urlRequest success:success failure:authorizationFailure];
}
@end
