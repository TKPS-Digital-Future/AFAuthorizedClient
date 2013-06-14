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

@property (nonatomic, weak) id<AFACAuthorizationDelegate> authorizationDelegate;

@end
