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
 * Object that will show loading spinners and toast messages.
 */
@interface HPFloatingUI : NSObject

/**
 * Show a short message to the user.
 *
 * @param message The string to show to the user.
 */
- (void)showToast:(NSString *)message;

/**
 * Called when a view controller wants to show a loading spinner.
 */
- (void)addLoadingSpinner;

/**
 * Called when a view controller has finished the request that required showing the spinner.
 * The spinner will stop spinning when this remove method has been called the same number of times
 * as the add method.
 */
- (void)removeLoadingSpinner;

@end
