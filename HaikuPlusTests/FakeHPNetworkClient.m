/*
 *
 * Copyright 2014 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "HPConstants.h"
#import "FakeHPNetworkClient.h"

@implementation FakeHPNetworkClient {
  BOOL _hasSetUserAgentIOS;
  NSString *_expectedAccessToken;
  BOOL _hasSetAccessToken;
}

NSString *FakeHPNetworkClientErrorDomain = @"FakeHPNetworkClientErrorDomain";

- (void)setDefaultHeader:(NSString *)header
                   value:(NSString *)value {
  [super setDefaultHeader:header value:value];
  if ([header isEqual:@"User-Agent"] && [value isEqual:kHPConstantsUserAgent]) {
    _hasSetUserAgentIOS = YES;
  }
  NSString *expectedBearer = [NSString stringWithFormat:@"Bearer %@", _expectedAccessToken];
  if ([header isEqual:@"Authorization"] && [value isEqual:expectedBearer]) {
    _hasSetAccessToken = YES;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSURL *networkURL = [NSURL URLWithString:kHPConstantsAppBaseURLString];
    NSDictionary *properties = @{
      NSHTTPCookieOriginURL : networkURL,
      NSHTTPCookiePath : @"/",
      NSHTTPCookieName : kHPConstantsSessionCookieName,
      NSHTTPCookieValue : @"sessionstring"
    };
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    [cookieStorage setCookie:cookie];
  }
  NSLog(@"Setting header for testing %@ %@", header, value);
}

- (BOOL)didSetUserAgentIOS {
  return _hasSetUserAgentIOS;
}

- (void)expectAccessToken:(NSString *)accessToken {
  _expectedAccessToken = accessToken;
}

- (BOOL)didSetAccessToken {
  return _hasSetAccessToken;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
    success:(void (^)(AFHTTPRequestOperation *, id))success
    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  self.success = success;
  self.failure = failure;
  return nil;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *, id))success
        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  if ([path isEqual:kHPConstantsUserPath]) {
    if (self.userAttributesToReturn) {
      success(nil, self.userAttributesToReturn);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else if ([path isEqual:kHPConstantsHaikusPath]) {
    if (self.haikusAttributesArrayToReturn) {
      success(nil, self.haikusAttributesArrayToReturn);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else if ([path isEqual:
      [NSString stringWithFormat:@"%@?filter=circles", kHPConstantsHaikusPath]]) {
    if (self.haikusAttributesArrayToReturn) {
      success(nil, self.haikusAttributesArrayToReturn);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else if ([path isEqual:
        [NSString stringWithFormat:kHPConstantsHaikuFormatPath, @"TestHaikuID"]]) {
    if (self.haikuAttributesToReturn) {
      success(nil, self.haikuAttributesToReturn);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else {
    failure(nil, nil);
  }
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *, id))success
         failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  NSString *votePath = [NSString stringWithFormat:kHPConstantsHaikuVoteFormatPath, @"TestHaikuID"];
  if ([path isEqual:kHPConstantsSignoutPath]) {
    if (self.signoutToSucceed) {
      success(nil, nil);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else if ([path isEqual:kHPConstantsDisconnectPath]) {
    if (self.disconnectToSucceed) {
      success(nil, nil);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else if ([path isEqual:votePath]) {
    if (self.voteToSucceed) {
      success(nil, nil);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else if ([path isEqual:kHPConstantsHaikusPath]) {
    if (self.haikuCreationToSucceed) {
      NSDictionary *haikuAttributes = [parameters mutableCopy];
      // Server should ignore supplied "id", "author", "votes", "creation_time" and create values.
      [haikuAttributes setValue:@"0" forKey:@"votes"];
      success(nil, haikuAttributes);
    } else {
      failure(nil, self.errorToReturn);
    }
  } else {
    failure(nil, nil);
  }
}

@end
