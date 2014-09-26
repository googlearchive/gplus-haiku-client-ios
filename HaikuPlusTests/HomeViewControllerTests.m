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

#import <GoogleOpenSource/GoogleOpenSource.h>
#import <XCTest/XCTest.h>

#import "AppDelegate.h"
#import "FakeGPPSignIn.h"
#import "FakeHPNetworkClient.h"
#import "HomeViewController.h"
#import "HPConstants.h"
#import "MockHPCommunicator.h"
#import "MockTableView.h"

@interface HomeViewControllerTests : XCTestCase

@end

@implementation HomeViewControllerTests {
  AppDelegate *_fakeAppDelegate;
  HomeViewController *_viewController;
  MockHPCommunicator *_mockCommunicator;
  FakeGPPSignIn *_fakeGPPSignIn;
  NSDictionary *_userAttributes;
  NSError *_error;
}

NSString *HomeViewControllerTestsErrorDomain = @"HomeViewControllerTestsErrorDomain";

enum {
  HomeViewControllerTestsErrorCode
};

- (void)setUp {
  [super setUp];
  _viewController = [[HomeViewController alloc] initWithCoder:nil];
  _userAttributes = @{
    @"id" : @"testid",
    @"google_plus_id" : @"testgoogleid",
    @"google_display_name" : @"testdisplayname",
    @"google_photo_url" : @"testphotourl",
    @"google_profile_url" : @"testprofileurl",
    @"last_updated" : @"2014-09-30T00:25:45Z"
  };
  _error = [NSError errorWithDomain:HomeViewControllerTestsErrorDomain
                              code:HomeViewControllerTestsErrorCode
                          userInfo:nil];
  _mockCommunicator = [[MockHPCommunicator alloc] init];
  _fakeGPPSignIn = [[FakeGPPSignIn alloc] init];
  _fakeAppDelegate = [[AppDelegate alloc] init];
  _fakeAppDelegate.communicator.gppSignIn = (GPPSignIn *)_fakeGPPSignIn;
  _fakeAppDelegate.communicator = _mockCommunicator;
  _viewController.appDelegate = _fakeAppDelegate;
}

- (void)testViewWillAppearAssignsHomeViewControllerToHPCommunicatorDelegate {
  [_viewController viewDidLoad];
  [_viewController viewWillAppear:YES];
  XCTAssertEqualObjects(_viewController.communicator.delegate,
      _viewController, @"HomeViewController should be the GPPSignInDelegate");
}

- (void)testViewDidLoadAssignsCommunicatorFromAppDelegate {
  [_viewController viewDidLoad];
  XCTAssertEqualObjects(_viewController.communicator, _fakeAppDelegate.communicator,
      @"Communicator object should come from AppDelegate property");
}

- (void)testViewDidLoadFetchesHaikus {
  [_viewController viewDidLoad];
  [_viewController viewWillAppear:YES];
  XCTAssertEqual([_mockCommunicator haikuFetchNotFilteredCount], 1,
      @"Communicator should be asked for haikus once");
}

- (void)testSelectedHaikuCanBeOverridenOnce {
  NSString *originalHaikuID = [_viewController selectedHaikuID];
  NSString *haikuIDToOverride = @"SPECIALHAIKUID";
  [_viewController overrideSelectedHaikuIDOnce:haikuIDToOverride];

  NSString *overridenHaikuID = [_viewController selectedHaikuID];
  NSString *thirdHaikuID = [_viewController selectedHaikuID];
  XCTAssertEqualObjects(overridenHaikuID, haikuIDToOverride);
  XCTAssertEqualObjects(thirdHaikuID, originalHaikuID);
}

@end
