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

/**
 * Each property matches the name of a field in a response from the server.
 * Subclasses can dynamically load data from NSDictionary objects. Key values of "id" will be
 * translated to properties named |identifier| because |id| is a keyword in Objective-C.
 */
@interface HPObject : NSObject

@property(nonatomic, strong) NSString *identifier;

/**
 * Initialize with a dictionary of property names and values.
 *
 * @param attributes Dictionary of object attributes, or nil.
 * @return Object or nil.
 */
- (id)initWithAttributes:(NSDictionary *)attributes;

/**
 * @return Dictionary of object attributes.
 */
- (NSDictionary *)attributesDictionary;

@end
