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
#import "HPHaiku.h"
#import "HPUser.h"

@interface HPHaikuTests : XCTestCase

@end

@implementation HPHaikuTests {
  HPHaiku *_haiku;
  HPUser *_author;
  NSDictionary *_haikuAttributes;
  NSDate *_date;
  NSDateFormatter *_dateFormatter;
}

- (void)setUp {
  [super setUp];
  NSDictionary *userAttributes;
  userAttributes = @{
    @"id" : @"testid",
    @"google_plus_id" : @"testgoogleid",
    @"google_display_name" : @"testdisplayname",
    @"google_photo_url" : @"testphotourl",
    @"google_profile_url" : @"testprofileurl",
    @"last_updated" : @"2014-02-05T19:24:38+0000"
  };
  _author = [[HPUser alloc] initWithAttributes:userAttributes];
  _haikuAttributes = @{
    @"id" : @"TestHaikuID",
    @"author" : userAttributes,
    @"title" : @"testtitle",
    @"line_one" : @"testlineone",
    @"line_two" : @"testlinetwo",
    @"line_three" : @"testlinethree",
    @"votes" : @"67",
    @"creation_time" : @"2014-02-05T19:24:38+0000"
  };
  _dateFormatter = [[NSDateFormatter alloc] init];
  [_dateFormatter setDateFormat:kHPConstantsAPIDateFormat];
  _date = [_dateFormatter dateFromString:@"2014-02-05T19:24:38+0000"];
}

- (void)testNilHaikuFromNilAttributes {
  _haiku = [[HPHaiku alloc] initWithAttributes:nil];
  XCTAssertNil(_haiku, @"Nil attributes should create a nil haiku");
}

- (void)testNotNilHaikuFromNotNilAttributes {
  _haiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  XCTAssertNotNil(_haiku, @"Haiku should be created");
}

- (void)testHaikuFromAttributesContainsAttributes {
  _haiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  XCTAssertEqualObjects(_haiku.identifier, @"TestHaikuID", @"ID must match");
  XCTAssertEqualObjects(_haiku.title, @"testtitle", @"Title must match");
  XCTAssertEqualObjects(_haiku.line_one, @"testlineone", @"Line one must match");
  XCTAssertEqualObjects(_haiku.line_two, @"testlinetwo", @"Line two must match");
  XCTAssertEqualObjects(_haiku.line_three, @"testlinethree", @"Line three must match");
  XCTAssertEqual(_haiku.votes, 67, @"Vote count must match");
  XCTAssertEqualObjects(_haiku.creation_time, _date, @"Creation time must match");

  XCTAssertEqualObjects(_haiku.author.identifier, _author.identifier, @"Author ID must match");
  XCTAssertEqualObjects(_haiku.author.google_plus_id, _author.google_plus_id,
      @"Author Google ID must match");
  XCTAssertEqualObjects(_haiku.author.google_display_name, _author.google_display_name,
      @"Author display name must match");
  XCTAssertEqualObjects(_haiku.author.google_photo_url, _author.google_photo_url,
      @"Author photo URL must match");
  XCTAssertEqualObjects(_haiku.author.google_profile_url, _author.google_profile_url,
      @"Author profile URL must match");
  XCTAssertEqualObjects(_haiku.author.last_updated, _author.last_updated,
      @"Author date updated must match");
}

- (void)testAttributesFromHaikuMatchesHaiku {
  _haiku = [[HPHaiku alloc] initWithAttributes:_haikuAttributes];
  NSDictionary *retrievedHaikuAttributes = [_haiku attributesDictionary];
  XCTAssertEqualObjects([retrievedHaikuAttributes objectForKey:@"id"],
      [_haikuAttributes objectForKey:@"id"], @"ID must match");
  XCTAssertEqualObjects([retrievedHaikuAttributes objectForKey:@"title"],
      [_haikuAttributes objectForKey:@"title"], @"Title must match");
  XCTAssertEqualObjects([retrievedHaikuAttributes objectForKey:@"line_one"],
      [_haikuAttributes objectForKey:@"line_one"], @"Line one must match");
  XCTAssertEqualObjects([retrievedHaikuAttributes objectForKey:@"line_two"],
      [_haikuAttributes objectForKey:@"line_two"], @"Line two must match");
  XCTAssertEqualObjects([retrievedHaikuAttributes objectForKey:@"line_three"],
      [_haikuAttributes objectForKey:@"line_three"], @"Line three must match");
  XCTAssertEqualObjects([retrievedHaikuAttributes objectForKey:@"votes"],
      [NSNumber numberWithInt:67], @"Vote count must match");
  NSString *retrievedCreationTimeString = [retrievedHaikuAttributes objectForKey:@"creation_time"];
  NSDate *retrievedCreationTime = [_dateFormatter dateFromString:retrievedCreationTimeString];
  XCTAssertEqual(retrievedCreationTime.timeIntervalSince1970,
      _date.timeIntervalSince1970, @"Creation time must match");

  XCTAssertEqualObjects([[retrievedHaikuAttributes objectForKey:@"author"] objectForKey:@"id"],
      [[_haikuAttributes objectForKey:@"author"] objectForKey:@"id"], @"Author ID must match");
  XCTAssertEqualObjects([[retrievedHaikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_plus_id"],
                        [[_haikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_plus_id"],
                        @"Author Google ID must match");
  XCTAssertEqualObjects([[retrievedHaikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_display_name"],
                        [[_haikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_display_name"],
                        @"Author Google display name must match");
  XCTAssertEqualObjects([[retrievedHaikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_photo_url"],
                        [[_haikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_photo_url"],
                        @"Author Google photo URL must match");
  XCTAssertEqualObjects([[retrievedHaikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_profile_url"],
                        [[_haikuAttributes objectForKey:@"author"]
                         objectForKey:@"google_profile_url"],
                        @"Author Google profile URL must match");
  NSString *retrievedLastUpdatedString = [[retrievedHaikuAttributes objectForKey:@"author"]
                                             objectForKey:@"last_updated"];
  NSDate *retrievedLastUpdated = [_dateFormatter dateFromString:retrievedLastUpdatedString];
  XCTAssertEqual(retrievedLastUpdated.timeIntervalSince1970,
                 _date.timeIntervalSince1970,
                 @"Author last updated time must match");
}

@end
