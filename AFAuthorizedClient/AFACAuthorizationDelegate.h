//
//  AFACAuthorizationDelegate.h
//  AFAuthorizedClient
//
//  Created by Patric Schenke on 14.06.13.
//
//

#import <Foundation/Foundation.h>

@protocol AFACAuthorizationDelegate <NSObject>

@property (nonatomic, readonly) NSString *authorizationHeader;

- (void) clearCredentials;

@end
