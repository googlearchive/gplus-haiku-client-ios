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

#import "HPObject.h"

/**
 * User object. Each property matches the name of a field in a response from the server.
 */
@interface HPUser : HPObject

@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *google_plus_id;
@property(nonatomic, strong) NSString *google_display_name;
@property(nonatomic, strong) NSString *google_photo_url;
@property(nonatomic, strong) NSString *google_profile_url;
@property(nonatomic, strong) NSDate *last_updated;

@end
