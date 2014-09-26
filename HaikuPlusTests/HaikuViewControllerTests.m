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

#import <XCTest/XCTest.h>

#import "FakeHPNetworkClient.h"
#import "HaikuViewController.h"
#import "HPConstants.h"

@interface HaikuViewControllerTests : XCTestCase

@end

@implementation HaikuViewControllerTests {
  HaikuViewController *_viewController;
  HPCommunicator *_communicator;
  FakeHPNetworkClient *_fakeNetwork;
  NSDictionary *_userAttributes;
  NSDictionary *_haikuAttributes;

  UINavigationItem *_haikuViewNavigation;
  UILabel *_lineOneLabel;
  UILabel *_lineTwoLabel;
  UILabel *_lineThreeLabel;
  UILabel *_votesLabel;
  UILabel *_authorDisplayNameUI;
  UILabel *_authorDisplayNameLabel;
  UIImageView *_authorDisplayImageView;
  UILabel *_dateCreatedLabel;
}

- (void)setUp {
  [super setUp];
  _communicator = [[HPCommunicator alloc] init];
  NSURL *baseUrl = [NSURL URLWithString:kHPConstantsAppBaseURLString];
  _fakeNetwork = [[FakeHPNetworkClient alloc] initWithBaseURL:baseUrl];
  _communicator.networkClient = _fakeNetwork;
  _viewController = [[HaikuViewController alloc] init];
  _viewController.haikuID = @"testid";
  _lineOneLabel = [[UILabel alloc] init];
  _viewController.lineOneLabel = _lineOneLabel;
  _lineTwoLabel = [[UILabel alloc] init];
  _viewController.lineTwoLabel = _lineTwoLabel;
  _lineThreeLabel = [[UILabel alloc] init];
  _viewController.lineThreeLabel = _lineThreeLabel;
  _viewController.communicator = _communicator;
  _votesLabel = [[UILabel alloc] init];
  _viewController.votesLabel = _votesLabel;
  _authorDisplayNameLabel = [[UILabel alloc] init];
  _viewController.authorDisplayNameLabel = _authorDisplayNameLabel;
  _authorDisplayImageView = [[UIImageView alloc] init];
  _viewController.authorDisplayImageView = _authorDisplayImageView;
  _dateCreatedLabel = [[UILabel alloc] init];
  _viewController.dateCreatedLabel = _dateCreatedLabel;
  _userAttributes = @{
    @"id" : @"testid",
    @"google_plus_id" : @"testgoogleid",
    @"google_display_name" : @"testdisplayname",
    @"google_photo_url" : @"testphotourl",
    @"google_profile_url" : @"testprofileurl",
    @"last_updated" : @"2013-09-30T00:25:45Z"
  };
  _haikuAttributes = @{
    @"id" : @"TestHaikuID",
    @"author" : _userAttributes,
    @"title" : @"testtitle",
    @"line_one" : @"testlineone",
    @"line_two" : @"testlinetwo",
    @"line_three" : @"testlinethree",
    @"votes" : @"67",
    @"creation_time" : @"2013-09-30T00:25:45Z"
  };
}

- (void)testSucceed {
  // TODO(cartland): Write tests
}

@end
