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

#import <XCTest/XCTest.h>

#import "HPConstants.h"
#import "HPUser.h"

@interface HPUserTests : XCTestCase

@end

@implementation HPUserTests {
  HPUser *_user;
  NSDictionary *_userAttributes;
  NSDate *_date;
  NSDateFormatter *_dateFormatter;
}

- (void)setUp {
  [super setUp];
  _userAttributes = @{
    @"id" : @"testid",
    @"google_plus_id" : @"testgoogleid",
    @"google_display_name" : @"testdisplayname",
    @"google_photo_url" : @"testphotourl",
    @"google_profile_url" : @"testprofileurl",
    @"last_updated" : @"2014-02-05T19:24:38+0000"
  };
  _dateFormatter = [[NSDateFormatter alloc] init];
  [_dateFormatter setDateFormat:kHPConstantsAPIDateFormat];
  _date = [_dateFormatter dateFromString:@"2014-02-05T19:24:38+0000"];
}

- (void)testNilUserFromNilAttributes {
  _user = [[HPUser alloc] initWithAttributes:nil];
  XCTAssertNil(_user, @"Nil attributes should create a nil user");
}

- (void)testNotNilUserFromNotNilAttributes {
  _user = [[HPUser alloc] initWithAttributes:_userAttributes];
  XCTAssertNotNil(_user, @"User should be created");
}

- (void)testUserFromAttributesContainsAttributes {
  _user = [[HPUser alloc] initWithAttributes:_userAttributes];
  XCTAssertEqualObjects(_user.identifier, @"testid", @"ID must match");
  XCTAssertEqualObjects(_user.google_plus_id, @"testgoogleid", @"Google ID must match");
  XCTAssertEqualObjects(_user.google_display_name, @"testdisplayname", @"Display name must match");
  XCTAssertEqualObjects(_user.google_photo_url, @"testphotourl", @"Photo URL must match");
  XCTAssertEqualObjects(_user.google_profile_url, @"testprofileurl", @"Profile URL must match");
  XCTAssertNotNil(_user.last_updated, @"User should have date");
  XCTAssertEqualObjects(_user.last_updated, _date, @"Date updated must match");
}

- (void)testAttributesFromUserMatchUser {
  _user = [[HPUser alloc] initWithAttributes:_userAttributes];
  NSDictionary *retrievedUserAttributes = [_user attributesDictionary];
  XCTAssertEqualObjects([retrievedUserAttributes objectForKey:@"id"],
      [retrievedUserAttributes objectForKey:@"id"], @"ID must match");
  XCTAssertEqualObjects([retrievedUserAttributes objectForKey:@"google_plus_id"],
      _user.google_plus_id, @"Google ID must match");
  XCTAssertEqualObjects([retrievedUserAttributes objectForKey:@"google_display_name"],
      [_userAttributes objectForKey:@"google_display_name"], @"Display name must match");
  XCTAssertEqualObjects([retrievedUserAttributes objectForKey:@"google_photo_url"],
      [_userAttributes objectForKey:@"google_photo_url"], @"Photo URL must match");
  XCTAssertEqualObjects([retrievedUserAttributes objectForKey:@"google_profile_url"],
      [_userAttributes objectForKey:@"google_profile_url"], @"Profile URL must match");
  NSString *retrievedLastUpdatedString = [retrievedUserAttributes objectForKey:@"last_updated"];
  NSDate *retrievedLastUpdated = [_dateFormatter dateFromString:retrievedLastUpdatedString];
  XCTAssertEqual(retrievedLastUpdated.timeIntervalSince1970,
                 _date.timeIntervalSince1970,
                 @"Date updated must match");

}

@end
