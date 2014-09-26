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

#import "FakeGTMOAuth2Authentication.h"
#import "FakeHPNetworkClient.h"
#import "HPCommunicator.h"
#import "HPConstants.h"

@interface HPCommunicatorTests : XCTestCase

@end

@implementation HPCommunicatorTests {
  HPCommunicator *_communicator;
  FakeHPNetworkClient *_fakeNetwork;
  FakeGTMOAuth2Authentication *_fakeAuth;
  NSDictionary *_userAttributes;
  NSDictionary *_haikuAttributes;
  NSArray *_haikusAttributesArray;
  NSError *_errorToReturn;
  HPUser *_fakeUser;
  BOOL _hasCompletedTest;
}

- (void)setUp {
  [super setUp];
  _communicator = [[HPCommunicator alloc] init];
  NSURL *baseURL = [NSURL URLWithString:kHPConstantsAppBaseURLString];
  _fakeNetwork = [[FakeHPNetworkClient alloc] initWithBaseURL:baseURL];
  _fakeAuth = [[FakeGTMOAuth2Authentication alloc] init];
  _userAttributes = @{
    @"id" : @"testid",
    @"google_plus_id" : @"testgoogleid",
    @"google_display_name" : @"testdisplayname",
    @"google_photo_url" : @"testphotourl",
    @"google_profile_url" : @"testprofileurl",
    @"last_updated" : @"2014-09-30T00:25:45Z"
  };
  _fakeUser = [[HPUser alloc] initWithAttributes:_userAttributes];

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
  _haikusAttributesArray = [NSArray arrayWithObject:_haikuAttributes];
  _errorToReturn = [NSError errorWithDomain:FakeHPNetworkClientErrorDomain
                                      code:FakeHPNetworkClientErrorCode
                                   userInfo:nil];

  _communicator.networkClient = _fakeNetwork;
  _hasCompletedTest = NO;
}

- (void)testCommunicatorSetsUserAgent {
  XCTAssertTrue([_fakeNetwork didSetUserAgentIOS],
      @"Setting client must set User-Agent");
}

- (void)testCommunicatorSetsAuthorizationHeader {
  GTMOAuth2Authentication *auth = [[GTMOAuth2Authentication alloc] init];
  auth.accessToken = @"TEST ACCESS TOKEN";
  [_fakeNetwork expectAccessToken:@"TEST ACCESS TOKEN"];
  _communicator.auth = auth;
}

- (void)testCommunicatorReturnsUnfilteredHaikus {
  [_communicator fetchHaikusFiltered:NO
                          completion:^(NSArray *haikus, NSError *error) {
      NSArray *dataArray = _haikusAttributesArray;
      NSArray *expectedArray = [HPHaiku haikuObjectsWithAttributes:dataArray];
      HPHaiku *firstHaiku = [haikus firstObject];
      HPHaiku *firstExpected = [expectedArray firstObject];
      XCTAssertEqualObjects(firstHaiku.identifier, firstExpected.identifier,
          @"Communicator should return data from network");
      _hasCompletedTest = YES;
      XCTAssertNil(error, @"Communicator should not return error when data is retrieved");
  }];
  _fakeNetwork.success(nil, _haikusAttributesArray);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsErrorWhenUnfilteredHaikusFail {
  [_communicator fetchHaikusFiltered:NO completion:^(NSArray *haikus, NSError *error) {
      XCTAssertEqualObjects(_errorToReturn, error, @"Communicator error should match");
      XCTAssertNil(haikus, @"Communicator should not succeed when error occurs");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.failure(nil, _errorToReturn);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsFilteredHaikus {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  [_communicator fetchHaikusFiltered:YES
                          completion:^(NSArray *haikus, NSError *error) {
      NSArray *expectedArray = [HPHaiku haikuObjectsWithAttributes:_haikusAttributesArray];
      HPHaiku *firstHaiku = [haikus firstObject];
      HPHaiku *firstExpected = [expectedArray firstObject];
      XCTAssertEqualObjects(firstHaiku.identifier, firstExpected.identifier,
          @"Communicator should return data from network");
      _hasCompletedTest = YES;
      XCTAssertNil(error, @"Communicator should not return error when data is retrieved");
  }];
  _fakeNetwork.success(nil, _haikusAttributesArray);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsErrorWhenFilteredHaikusFail {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  [_communicator fetchHaikusFiltered:YES completion:^(NSArray *haikus, NSError *error) {
      XCTAssertEqualObjects(_errorToReturn, error, @"Communicator error should match");
      XCTAssertNil(haikus, @"Communicator should not succeed when error occurs");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.failure(nil, _errorToReturn);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsOnSuccessfulSignout {
  [_communicator signOutWithCompletion:^(NSError *error) {
      XCTAssertNil(error, @"Communicator should not return error when call succeeds");
      XCTAssertNil(_communicator.auth, @"Signing out should remove auth information");
      XCTAssertFalse([self sessionCookieExists], @"Should delete session cookie");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.success(nil, nil);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorSignoutDoesNotCrashWithNilCompletion {
  XCTAssertNoThrow([_communicator signOutWithCompletion:nil]);
}

- (void)testCommunicatorReturnsErrorOnFailedSignout {
  _fakeNetwork.errorToReturn = _errorToReturn;
  [_communicator signOutWithCompletion:^(NSError *error) {
      XCTAssertEqual(_errorToReturn, error, @"Communicator error should match");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.failure(nil, _errorToReturn);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsOnSuccessfulDisconnect {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  [_communicator disconnectWithCompletion:^(NSError *error) {
      XCTAssertNil(error, @"Communicator should not return error when call succeeds");
      XCTAssertNil(_communicator.auth, @"Signing out should remove auth information");
      XCTAssertFalse([self sessionCookieExists], @"Should delete session cookie");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.success(nil, nil);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsErrorOnFailedDisconnect {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  [_communicator disconnectWithCompletion:^(NSError *error) {
      XCTAssertEqual(_errorToReturn, error, @"Communicator error should match");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.failure(nil, _errorToReturn);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsHaikuOnSuccess {
  _fakeNetwork.haikuAttributesToReturn = _haikuAttributes;
  HPHaiku *expectedHaiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  NSString *haikuID = expectedHaiku.identifier;
  [_communicator fetchHaikuWithID:haikuID
                       completion:^(HPHaiku *haiku, NSError *error) {
      XCTAssertEqualObjects(haiku.identifier, expectedHaiku.identifier,
          @"Communicator should return data from network");
      XCTAssertNil(error, @"Communicator should not return error when call succeeds");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.success(nil, _haikuAttributes);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsErrorWhenHaikuFail {
  HPHaiku *expectedHaiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  NSString *haikuID = expectedHaiku.identifier;
  [_communicator fetchHaikuWithID:haikuID
                       completion:^(HPHaiku *haiku, NSError *error) {
      XCTAssertEqual(_errorToReturn, error, @"Communicator error should match");
      XCTAssertNil(haiku, @"Communicator should not succeed when error occurs");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.failure(nil, _errorToReturn);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsOnSuccessfulVote {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  HPHaiku *expectedHaiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  NSString *haikuID = expectedHaiku.identifier;
  [_communicator voteForHaikuWithID:haikuID
                         completion:^(NSError *error) {
      XCTAssertNil(error, @"Communicator should not succeed when error occurs");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.success(nil, _haikuAttributes);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsErrorOnFailedVote {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  HPHaiku *expectedHaiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  NSString *haikuID = expectedHaiku.identifier;
  [_communicator voteForHaikuWithID:haikuID
                         completion:^(NSError *error) {
      XCTAssertEqual(_errorToReturn, error, @"Communicator error should match");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.failure(nil, _errorToReturn);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testCommunicatorReturnsHaikuOnSuccessfulCreation {
  _fakeAuth.errorToReturn = nil;
  _communicator.auth = _fakeAuth;
  HPHaiku *haikuToUpload = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  haikuToUpload.votes = 0;
  [_communicator createHaiku:haikuToUpload
                  completion:^(HPHaiku *haiku, NSError *error) {
      XCTAssertNotNil(haiku.identifier, @"ID should exist");
      XCTAssertNotNil(haiku.author, @"Author should exist");
      XCTAssertNotNil(haiku.creation_time, @"Creation time should exist");
      XCTAssertEqual(haiku.votes, 0, @"Vote should be 0");
      XCTAssertEqualObjects(haiku.title, haikuToUpload.title, @"Title should match");
      XCTAssertEqualObjects(haiku.line_one, haikuToUpload.line_one, @"Line one should match");
      XCTAssertEqualObjects(haiku.line_two, haikuToUpload.line_two, @"Line two should match");
      XCTAssertEqualObjects(haiku.line_three, haikuToUpload.line_three,
          @"Line three should match");
      XCTAssertNil(error, @"Communicator should not return error when call succeeds");
      _hasCompletedTest = YES;
  }];
  _fakeNetwork.success(nil, [haikuToUpload attributesDictionary]);
  XCTAssertTrue(_hasCompletedTest, @"Communicator must return something");
}

- (void)testFinishedWithAuthFetchesUserOnSuccess {
  GTMOAuth2Authentication *auth = [[GTMOAuth2Authentication alloc] init];
  auth.accessToken = @"testtoken";
  [_communicator finishedWithAuth:auth error:nil];
  XCTAssertEqualObjects(_communicator.auth.accessToken, auth.accessToken,
      @"Communicator should have auth set");
}

- (BOOL)sessionCookieExists {
  NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSURL *url = [NSURL URLWithString:kHPConstantsAppBaseURLString];
  NSArray *cookies = [cookieStorage cookiesForURL:url];
  for (NSHTTPCookie *cookie in cookies) {
    NSString *name = [cookie name];
    if ([name isEqual:kHPConstantsSessionCookieName]) {
      return YES;
    }
  }
  return NO;
}

@end
