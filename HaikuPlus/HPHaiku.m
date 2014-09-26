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

#import <objc/runtime.h>

#import "HPConstants.h"
#import "HPUser.h"

@implementation HPHaiku

/**
 * Builds an array of HPHaiku objects using an array of attributes.
 */
+ (NSArray *)haikuObjectsWithAttributes:(NSArray *)array {
  if (!array) {
    return nil;
  }
  NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[array count]];
  for (NSDictionary *attributes in array) {
    HPHaiku *item = [[HPHaiku alloc] initWithAttributes:attributes];
    [mutableArray addObject:item];
  }
  return mutableArray;
}

- (void)setValue:(id)value forKey:(NSString *)key {
  if ([key isEqual:@"creation_time"]) {
    // "creation_time" is provided as a string, so we must convert it to an NSDate.
    // The formatter works for a subset of ISO 8601.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kHPConstantsAPIDateFormat];
    _creation_time = [dateFormatter dateFromString:value];
  } else if ([key isEqual:@"author"]) {
    // "author" is passed as an NSDictionary, so we must construct the HPUser object manually.
    _author = [[HPUser alloc] initWithAttributes:value];
  } else {
    [super setValue:value forKey:key];
  }
}

/**
 * Called from - (NSDictionary *)attributesDictionary
 * through [self dictionaryWithValuesForKeys:propertyNames].
 */
- (id)valueForKey:(NSString *)key {
  if ([key isEqual:@"creation_time"]) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kHPConstantsAPIDateFormat];
    NSString *creation_time = [dateFormatter stringFromDate:_creation_time];
    return creation_time;
  } else if ([key isEqual:@"author"]) {
    return [_author attributesDictionary];
  } else {
    return [super valueForKey:key];
  }
}

@end
