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

#import <objc/runtime.h>

#import "HPObject.h"

@implementation HPObject

- (id)initWithAttributes:(NSDictionary *)attributes {
  self = [super init];
  if (!self) {
    return nil;
  }
  if (!attributes) {
    return nil;
  }
  // Dynamically sets object properties with attributes.
  // Will call [self setValue:forUndefinedKey:] for unknown keys.
  [self setValuesForKeysWithDictionary:attributes];
  return self;
}

- (NSDictionary *)attributesDictionary {
  NSMutableArray *propertyNames = [NSMutableArray array];
  unsigned int outCount, i;
  objc_property_t *properties = class_copyPropertyList([self class], &outCount);
  for (i = 0; i < outCount; i++) {
    objc_property_t property = properties[i];
    const char *propName =  property_getName(property);
    if (propName) {
      NSString *propertyName = [NSString stringWithUTF8String:propName];
      if ([propertyName isEqual:@"identifier"]) {
        // Properties named "identifier" are designed to be called "id" in an NSDictionary.
        [propertyNames addObject:@"id"];
      } else {
        [propertyNames addObject:propertyName];
      }
    }
  }
  NSDictionary *attributes = [self dictionaryWithValuesForKeys:propertyNames];
  return attributes;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  if ([key isEqual:@"id"]) {
    // "id" cannot be assigned directly, so we provide a manual mapping to the |identifier|
    // property on this object.
    _identifier = value;
  } else {
    [super setValue:value forUndefinedKey:key];
  }
}

- (id)valueForUndefinedKey:(NSString *)key {
  if ([key isEqual:@"id"]) {
    // "id" cannot be referenced directly, so we provide a manual mapping to the |identifier|
    // property on this object.
    return _identifier;
  } else {
    return [super valueForUndefinedKey:key];
  }
}

@end
