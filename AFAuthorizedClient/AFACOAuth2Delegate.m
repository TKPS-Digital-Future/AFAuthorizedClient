//
//  AFACOAuth2Delegate.m
//  Roomboard
//
//  Created by Patric Schenke on 14.06.13.
//
//

#import "AFACOAuth2Delegate.h"

NSString * const kAFAuthorizedClientErrorDomain = @"kAFAuthorizedClientErrorDomain";
NSInteger const kNoRefreshTokenError = 1;
NSInteger const kNoUsernamePasswordError = 2;
NSInteger const kNoAuthcodeRedirectURIError = 3;

@interface AFACOAuth2Delegate ()

@property (nonatomic, strong) AFOAuth2Client * oauth2Client;
@property (nonatomic, strong) NSString * tokenEndpoint;
@property (nonatomic, strong) NSString * scope;

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;

@property (nonatomic, strong) NSString * authCode;
@property (nonatomic, strong) NSString * redirectURI;

@property (nonatomic, strong) NSString * refreshToken;

@property (nonatomic, strong) AFOAuthCredential * afOAuthCredential;

@end

@implementation AFACOAuth2Delegate

- (id) initWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret tokenEndpointPath:(NSString *)tokenEndpointPath scope:(NSString *)scope
{
    self = [super init];
    if (self) {
        self.oauth2Client = [AFOAuth2Client clientWithBaseURL:url clientID:clientID secret:secret];
        self.tokenEndpoint = tokenEndpointPath;
        self.scope = scope;
    }
    return self;
}

- (void) setCredentialsWithUsername:(NSString *) username password:(NSString *) password
{
    self.username = username;
    self.password = password;
}

- (void) setCredentialsWithAuthcode:(NSString *) authCode redirectURI:(NSString *) redirectURI
{
    self.authCode = authCode;
    self.redirectURI = redirectURI;
}

- (void) setCredentialsWithRefreshToken:(NSString *) refreshToken
{
    self.refreshToken = refreshToken;
}

- (void) setCredentialsWithAFOAuthCredential:(AFOAuthCredential *) afOAuthCredential
{
    self.afOAuthCredential = afOAuthCredential;
}

- (void) authenticateWithSuccess:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure
{

}

- (NSString *) authorizationHeader
{
    return [NSString stringWithFormat:@"Bearer %@", self.afOAuthCredential.accessToken];
}

@end
