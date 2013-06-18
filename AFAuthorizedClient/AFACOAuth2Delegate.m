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
    // Type-definition for readable code
    typedef void (^failureBlock)(NSError *);
    
    // Blocks used to request a token with various methods
    void (^refreshTokenRequest)(failureBlock);
    void (^usernamePasswordRequest)(failureBlock);
    void (^authCodeRequest)(failureBlock);
    void (^implicitRequest)(failureBlock);
    
    // Request a token using a refresh
    refreshTokenRequest = ^(failureBlock refreshFailure)
    {
        // Find a refresh token, either set with the setCredentials-method or provided by the existing credential
        NSString *refreshToken = self.refreshToken?self.refreshToken:((self.afOAuthCredential && self.afOAuthCredential.refreshToken)?self.afOAuthCredential.refreshToken:nil);
        
        if (refreshToken) {
            [self.oauth2Client authenticateUsingOAuthWithPath:self.tokenEndpoint refreshToken:refreshToken success:success failure:refreshFailure];
        }
        // If no refresh-token is present, the failure-block gets called with a specific error-object
        else
        {
            NSError *noRefreshTokenError = [NSError errorWithDomain:kAFAuthorizedClientErrorDomain code:kNoRefreshTokenError userInfo:nil];
            refreshFailure(noRefreshTokenError);
        }
    };
    
    // Request a token using username-password-authentication
    usernamePasswordRequest = ^(failureBlock upFailure)
    {
        // Check for username and password set by the setCredentials-method
        if (self.username && self.password) {
            [self.oauth2Client authenticateUsingOAuthWithPath:self.tokenEndpoint username:self.username password:self.password scope:self.scope success:success failure:upFailure];
        }
        // If either username or password are not set, a specific error is handed to the failure-block
        else
        {
            NSError *noUsernamePasswordError = [NSError errorWithDomain:kAFAuthorizedClientErrorDomain code:kNoUsernamePasswordError userInfo:nil];
            upFailure(noUsernamePasswordError);
        }
    };
    
    // Request a token using auth-code and redirect-URI
    authCodeRequest = ^(failureBlock acFailure)
    {
        if (self.authCode && self.redirectURI) {
            [self.oauth2Client authenticateUsingOAuthWithPath:self.tokenEndpoint code:self.authCode redirectURI:self.redirectURI success:success failure:acFailure];
        }
        // If either auth-code or redirect-URI are not set, a specific error is handed to the failure-block
        else
        {
            NSError *noAuthcodeRedirectURIError = [NSError errorWithDomain:kAFAuthorizedClientErrorDomain code:kNoAuthcodeRedirectURIError userInfo:nil];
            acFailure(noAuthcodeRedirectURIError);
        }
    };
    
    // Request a token using implicit authentication
    implicitRequest = ^(failureBlock impFailure)
    {
        [self.oauth2Client authenticateUsingOAuthWithPath:self.tokenEndpoint scope:self.scope success:success failure:impFailure];
    };
    
    // If auth-code-request fails, try implicit request
    failureBlock acFailure = ^(NSError *error)
    {
        // If implicit request fails, fail completely
        implicitRequest(failure);
    };
    
    // If username-password fails, try auth-code
    failureBlock upFailure = ^(NSError *error)
    {
        authCodeRequest(acFailure);
    };
    
    // If refresh-token fails, try username-password
    failureBlock refreshFailure = ^(NSError *error)
    {
        usernamePasswordRequest(upFailure);
    };
    
    // Try refresh-request
    refreshTokenRequest(refreshFailure);
}

- (NSString *) authorizationHeader
{
    // TODO: if several parallel requests fail at the same time, don't refresh the token for each of them.
    // CONSIDER: put the handling of parallel fails into the client.
    
    __block BOOL isFinished = NO;
    
    [self authenticateWithSuccess:^(AFOAuthCredential *credential) {
        self.afOAuthCredential = credential;
        isFinished = YES;
    } failure:^(NSError *error) {
        NSLog(@"error getting token: %@", error);
        isFinished = YES;
    }];
    
    NSDate *loopLimit = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!isFinished && [loopLimit timeIntervalSinceNow] > 0)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopLimit];
        loopLimit = [NSDate dateWithTimeIntervalSinceNow:10];
    }
    
    return [NSString stringWithFormat:@"Bearer %@", self.afOAuthCredential.accessToken];
}

- (void) clearCredentials
{
    self.username = nil;
    self.password = nil;
    self.afOAuthCredential = nil;
    self.refreshToken = nil;
    self.authCode = nil;
}

@end
