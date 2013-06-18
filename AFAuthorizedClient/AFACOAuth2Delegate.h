//
//  AFACOAuth2Delegate.h
//  Roomboard
//
//  Created by Patric Schenke on 14.06.13.
//
//

#import "AFACAuthorizationDelegate.h"
#import "AFOAuth2Client.h"

@interface AFACOAuth2Delegate : NSObject <AFACAuthorizationDelegate>

- (id) initWithBaseURL:(NSURL *) url
              clientID:(NSString *) clientID
                secret:(NSString *)secret
     tokenEndpointPath:(NSString *)tokenEndpointPath
                 scope:(NSString *)scope;

- (void) setCredentialsWithUsername:(NSString *) username
                           password:(NSString *) password;

- (void) setCredentialsWithAuthcode:(NSString *) authCode
                        redirectURI:(NSString *) redirectURI;

- (void) setCredentialsWithRefreshToken:(NSString *) refreshToken;

- (void) setCredentialsWithAFOAuthCredential:(AFOAuthCredential *) afOAuthCredential;

@end
