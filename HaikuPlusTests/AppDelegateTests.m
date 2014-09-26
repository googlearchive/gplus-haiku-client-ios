/*
 *
 * Copyright 2013 Google Inc.
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

#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <XCTest/XCTest.h>

#import "AppDelegate.h"
#import "HPConstants.h"
#import "HPCommunicator.h"
#import "HPNetworkClient.h"

@interface AppDelegateTests : XCTestCase

@end

@implementation AppDelegateTests {
  AppDelegate *_delegate;
}

- (void)setUp {
  [super setUp];
  _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)testCommunicatorObjectIsCorrectType {
  HPCommunicator *comm = _delegate.communicator;
  XCTAssertTrue([comm isKindOfClass:[HPCommunicator class]],
      @"Communicator must be of correct type");
}

- (void)testDelegateHasGPPSignIn {
  XCTAssertNotNil(_delegate.communicator.gppSignIn, @"App must have Google+ Sign-In object");
}

- (void)testGPPSignInIsConfigured {
  GPPSignIn *gppSignIn = _delegate.communicator.gppSignIn;
  XCTAssertNotNil(gppSignIn.clientID, @"Sign-in must have client ID");
  XCTAssertTrue([gppSignIn.scopes containsObject:kGTLAuthScopePlusLogin],
                @"%@ not in %@", kGTLAuthScopePlusLogin, gppSignIn.scopes);
  XCTAssertTrue([gppSignIn.actions containsObject:@"http://schemas.google.com/AddActivity"],
                @"%@", gppSignIn.actions);
  XCTAssertTrue([gppSignIn.actions containsObject:@"http://schemas.google.com/ReviewActivity"],
                @"%@", gppSignIn.actions);
  XCTAssertNotNil(gppSignIn.delegate, @"Sign-in must have delegate");
}

- (void)testCommunicatorIsAssignedNetworkClient {
  HPNetworkClient *network = _delegate.communicator.networkClient;
  XCTAssertTrue([network isKindOfClass:[HPNetworkClient class]],
      @"App delegate must set network client for communicator");
}

- (void)testCommunicatorNetworkIsConfigured {
  HPNetworkClient *network = _delegate.communicator.networkClient;
  XCTAssertEqualObjects([network.baseURL absoluteString], kHPConstantsAppBaseURLString,
      @"Network must point to app base URL");
}

@end
