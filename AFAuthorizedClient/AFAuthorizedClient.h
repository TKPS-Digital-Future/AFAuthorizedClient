//
//  AFAuthorizedClient.h
//  AFAuthorizedClient
//
//  Created by Patric Schenke on 14.06.13.
//
//

#import "AFHTTPClient.h"
#import "AFACAuthorizationDelegate.h"

@interface AFAuthorizedClient : AFHTTPClient

@property (nonatomic, strong) id<AFACAuthorizationDelegate> authorizationDelegate;

@end
