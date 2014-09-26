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

#import "HPHaiku.h"
#import "HPNetworkClient.h"
#import "HPUser.h"

extern NSString *FakeHPNetworkClientErrorDomain;

enum {
  FakeHPNetworkClientErrorCode
};

@interface FakeHPNetworkClient : HPNetworkClient

@property (nonatomic, weak) NSDictionary *userAttributesToReturn;
@property (nonatomic, weak) NSArray *haikusAttributesArrayToReturn;
@property (nonatomic, weak) NSDictionary *haikuAttributesToReturn;
@property (nonatomic, weak) NSError *errorToReturn;
@property BOOL signoutToSucceed;
@property BOOL disconnectToSucceed;
@property BOOL voteToSucceed;
@property BOOL haikuCreationToSucceed;
@property (nonatomic, copy) void (^success)(AFHTTPRequestOperation *, id);
@property (nonatomic, copy) void (^failure)(AFHTTPRequestOperation *, id);

- (BOOL)didSetUserAgentIOS;

- (void)expectAccessToken:(NSString *)accessToken;

- (BOOL)didSetAccessToken;

@end
