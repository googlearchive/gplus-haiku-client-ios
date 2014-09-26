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

#import "HPUser.h"

#import <objc/runtime.h>

#import "HPConstants.h"

@implementation HPUser

- (void)setValue:(id)value forKey:(NSString *)key {
  if ([key isEqual:@"last_updated"]) {
    // "creation_time" is provided as a string, so we must convert it to an NSDate.
    // The formatter works for a subset of ISO 8601.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kHPConstantsAPIDateFormat];
    _last_updated = [dateFormatter dateFromString:value];
  } else {
    [super setValue:value forKey:key];
  }
}

/**
 * Called from - (NSDictionary *)attributesDictionary
 * through [self dictionaryWithValuesForKeys:propertyNames].
 */
- (id)valueForKey:(NSString *)key {
  if ([key isEqual:@"last_updated"]) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kHPConstantsAPIDateFormat];
    NSString *last_updated = [dateFormatter stringFromDate:_last_updated];
    return last_updated;
  } else {
    return [super valueForKey:key];
  }
}

@end
