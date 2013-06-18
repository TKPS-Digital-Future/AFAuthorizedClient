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

- (void) clearAuthorizationHeader
{
    [self.authorizationDelegate clearCredentials];
    [super clearAuthorizationHeader];
}

// Adds a custom failure-block that will handle request which need to be authenticated
- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    // Custom failure-block
    void (^authorizationFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *request, NSError *error)
    {
        // Status-tracking-variables to produce readable code
        BOOL investigateHTTP = NO;
        BOOL authorizationFailed = NO;
        
        // Get the original error-code
        NSInteger errorCode = error.code;
        
        // Investigate the original error-code
        switch (errorCode)
        {
            // NSURLRequest failed and tells us that authentication is required
            // Effect: get authorization-header from delegate and retry request
            case NSURLErrorUserAuthenticationRequired:
            {
                authorizationFailed = YES;
            } break;
                
            // Something else went wrong or NSURLConnection misinterpreted the server-response
            // Effect: investigate the HTTP-response
            case NSURLErrorUnknown:
            default:
            {
                investigateHTTP = YES;
            } break;
        }
        
        // In case we decided to take a closer look above
        if (investigateHTTP)
        {
            // Extract the HTTP-status-code from the response
            NSDictionary *userInfo = error.userInfo;
            NSHTTPURLResponse *httpResponse = userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            NSInteger statusCode = httpResponse.statusCode;
            
            // Investigate the HTTP-status-code
            switch (statusCode)
            {
                // "401: Unauthorized" is the only code that should be handled here if you want to conform to RFC2616
                // Effect: get authorization-header from delegate and retry request
                case 401:
                {
                    authorizationFailed = YES;
                } break;
                    
                // Default: do nothing
                // Effect: original failure-block will be called
                default:
                    break;
            }
        }
        
        // In case we decided that authorization is required above
        if (authorizationFailed)
        {
            // Create a mutable copy of the request
            NSMutableURLRequest *mutableRequest = urlRequest.mutableCopy;
            
            // Update the authorization-header-field with the value from the delegate
            NSMutableDictionary *headers = mutableRequest.allHTTPHeaderFields.mutableCopy;
            [headers setValue:self.authorizationDelegate.authorizationHeader forKey:@"Authorization"];
            
            // Update the header-fields of the original request
            mutableRequest.allHTTPHeaderFields = headers;
            
            // Enqueue the updated request again. Use original failure-block, so it will be called directly if authorization fails again.
            AFHTTPRequestOperation *retryOperation = [self HTTPRequestOperationWithRequest:mutableRequest success:success failure:failure];
            [self enqueueHTTPRequestOperation:retryOperation];
        }
        // Error not related to authorization
        else
        {
            // Call original failure-block
            failure(request, error);
        }
    };
    
    // Add new failure-block to the request and return it
    return [super HTTPRequestOperationWithRequest:urlRequest success:success failure:authorizationFailure];
}

@end
