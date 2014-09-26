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

#import "SimulatedHPNetworkClient.h"

#import "HPConstants.h"
#import "SimulatedAFHTTPRequestOperation.h"
#import "SimulatedNSMutableURLRequest.h"

@implementation SimulatedHPNetworkClient {
  NSString *_userAgentHeader;
  NSError *_error;
  NSError *_userAgentError;
  NSDictionary *_userAttributes;
  NSDictionary *_haikuAttributes;
  NSDictionary *_haikuAttributes2;
  NSArray *_haikuAttributesArray;
}

/**
 * Error domain string for the simulated errors returned by SimulatedHPNetworkClient.
 */
NSString *SimulatedHPNetworkClientErrorDomain = @"SimulatedHPNetworkClientErrorDomain";

/**
 * Prepare fake data that can be returned by the simulated server when API requests are made.
 */
- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  _userAgentHeader = nil;
  _error = [NSError errorWithDomain:SimulatedHPNetworkClientErrorDomain
                              code:SimulatedHPNetworkClientErrorCode
                          userInfo:nil];
  _userAgentError = [NSError errorWithDomain:SimulatedHPNetworkClientErrorDomain
                                       code:SimulatedHPNetworkClientUserAgentErrorCode
                                   userInfo:nil];
  _userAttributes = @{
    @"id" : @"testid",
    @"google_plus_id" : @"testgoogleid",
    @"google_display_name" : @"testdisplayname",
    @"google_photo_url" : @"http://placekitten.com/200/200",
    @"google_profile_url" : @"testprofileurl",
    @"last_updated" : @"2014-09-30T00:25:45Z"
  };
  _haikuAttributes = @{
    @"id" : @"TestHaikuID",
    @"author" : _userAttributes,
    @"title" : @"testtitle",
    @"line_one" : @"testlineone",
    @"line_two" : @"testlinetwo",
    @"line_three" : @"testlinethree",
    @"votes" : @"67",
    @"creation_time" : @"2014-09-30T00:25:45Z"
  };
  _haikuAttributes2 = @{
    @"id" : @"haikuid2",
    @"author" : _userAttributes,
    @"title" : @"testtitle2",
    @"line_one" : @"testlineone2",
    @"line_two" : @"testlinetwo2",
    @"line_three" : @"testlinethree2",
    @"votes" : @"31",
    @"creation_time" : @"2014-10-15T00:25:45Z"
  };
  _haikuAttributesArray = @[
    _haikuAttributes,
    _haikuAttributes2,
  ];
  return self;
}

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
  [super setDefaultHeader:header value:value];
  // This simulated network requires the correct iOS User-Agent header.
  if ([header isEqual:@"User-Agent"]) {
    _userAgentHeader = value;
  }
}

/**
 * @param method HTTP method such as @"GET" or @"POST".
 * @param path The URL string for the network resource.
 * @param parameters The body parameters.
 * @return The simulated request that contains the response information from the fake server.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
  SimulatedNSMutableURLRequest *request = [[SimulatedNSMutableURLRequest alloc] init];
  NSString *filterPath = [NSString stringWithFormat:@"%@?filter=circles", kHPConstantsHaikusPath];
  NSString *haikuPath1 = [NSString stringWithFormat:kHPConstantsHaikuFormatPath, @"TestHaikuID"];
  NSString *haikuPath2 = [NSString stringWithFormat:kHPConstantsHaikuFormatPath, @"haikuid2"];
  NSString *haikuPath1Vote = [NSString stringWithFormat:@"%@/vote", haikuPath1];
  NSLog(@"method %@", method);
  NSLog(@"path %@", path);
  if ([method isEqual:@"GET"]) {
    if (![_userAgentHeader isEqual:kHPConstantsUserAgent]) {
      // Require the correct iOS User-Agent header.
      NSLog(@"Incorrect User-Agent header");
      [request setResponse:nil withError:_userAgentError];
    } else if ([path isEqual:kHPConstantsUserPath]) {
      id object = [_userAttributes copy];
      [request setResponse:object withError:nil];
    } else if ([path isEqual:kHPConstantsHaikusPath]) {
      // Get unfiltered haikus.
      id object = [_haikuAttributesArray copy];
      [request setResponse:object withError:nil];
    } else if ([path isEqual:filterPath]) {
      // Get filtered haikus.
      id object = [_haikuAttributesArray copy];
      [request setResponse:object withError:nil];
    } else if ([path isEqual:haikuPath1]) {
      // Get a haiku with ID "TestHaikuID".
      id object = [_haikuAttributes copy];
      [request setResponse:object withError:nil];
    } else if ([path isEqual:haikuPath2]) {
      // Get a haiku with ID "haikuid2".
      id object = [_haikuAttributes2 copy];
      [request setResponse:object withError:nil];
    } else {
      NSLog(@"Request to haiku server not recognized");
      [request setResponse:nil withError:_error];
    }
  } else if ([method isEqual:@"POST"]) {
    if (![_userAgentHeader isEqual:kHPConstantsUserAgent]) {
      // Require the correct iOS User-Agent header.
      NSLog(@"Incorrect User-Agent header");
      [request setResponse:nil withError:_userAgentError];
    } else if ([path isEqual:kHPConstantsSignoutPath]) {
      // Sign out.
      [request setResponse:nil withError:nil];
    } else if ([path isEqual:kHPConstantsDisconnectPath]) {
      // Disconnect.
      [request setResponse:nil withError:nil];
    } else if ([path isEqual:haikuPath1Vote]) {
      // Vote for haiku with ID "TestHaikuID".
      NSMutableDictionary *newAttributes;
      newAttributes = [NSMutableDictionary dictionaryWithDictionary:_haikuAttributes];
      int votes = [[_haikuAttributes objectForKey:@"votes"] intValue];
      NSString *newVotesValue = [NSString stringWithFormat:@"%d", votes + 1];
      [newAttributes setValue:newVotesValue forKey:@"votes"];
      _haikuAttributes = newAttributes;
      [request setResponse:nil withError:nil];
    } else if ([path isEqual:kHPConstantsHaikusPath]) {
      // Create haiku.
      NSMutableDictionary *newHaiku = [NSMutableDictionary dictionaryWithDictionary:parameters];
      [newHaiku setValue:_userAttributes forKey:@"author"];
      _haikuAttributesArray = [_haikuAttributesArray arrayByAddingObject:newHaiku];
      id object = [newHaiku copy];
      [request setResponse:object withError:nil];
    } else {
      NSLog(@"Fall through simulation error");
      [request setResponse:nil withError:_error];
    }
  }
  return request;
}

/**
 * Prepares a simulated operation.
 *
 * @param urlRequest The simulated request that contains object and error properties.
 * @param success The success block that will be called when there is no error.
 * @param failure The failure block that will be called when an error is supplied in the request.
 * @return Simulated request operation that contains the request and completion blocks.
 */
- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(AFSuccessBlock)success
                                                    failure:(AFFailureBlock)failure {
  SimulatedNSMutableURLRequest *request = (SimulatedNSMutableURLRequest *)urlRequest;
  SimulatedAFHTTPRequestOperation *op = [[SimulatedAFHTTPRequestOperation alloc] init];
  op.request = request;
  op.successBlock = success;
  op.failureBlock = failure;
  return op;
}

/**
 * Use the simulated operation to call the success or failure block with the correct object.
 *
 * @param operation Simulated operation with a request and completion blocks.
 */
- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
  SimulatedAFHTTPRequestOperation *op = (SimulatedAFHTTPRequestOperation *)operation;
  SimulatedNSMutableURLRequest *request = op.request;
  if (request.error) {
    op.failureBlock(nil, request.error);
  } else {
    op.successBlock(nil, request.object);
  }
}

@end
