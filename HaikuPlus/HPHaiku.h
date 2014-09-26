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

#import "HPObject.h"

@class HPUser;

/**
 * Haiku object. Each property matches the name of a field in a response from the server.
 */
@interface HPHaiku : HPObject

@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) HPUser *author;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *line_one;
@property(nonatomic, strong) NSString *line_two;
@property(nonatomic, strong) NSString *line_three;
@property(nonatomic, strong) NSString *content_url;
@property(nonatomic, strong) NSString *content_deep_link_id;
@property(nonatomic, strong) NSString *call_to_action_url;
@property(nonatomic, strong) NSString *call_to_action_deep_link_id;
@property(nonatomic) NSInteger votes;
@property(nonatomic, strong) NSDate *creation_time;

/**
 * Builds an array of HPHaiku objects using an array of attributes.
 */
+ (NSArray *)haikuObjectsWithAttributes:(NSArray *)array;

@end
