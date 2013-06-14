//
//  AFACBasicAuthorizationDelegate.h
//  AFAuthorizedClient
//
//  Created by Patric Schenke on 14.06.13.
//
//

#import "AFACAuthorizationDelegate.h"

@interface AFACBasicAuthorizationDelegate : NSObject <AFACAuthorizationDelegate>

- (void) setCredentialsWithUsername:(NSString *) username password:(NSString *) password;

@end
