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

#import "HPCommunicator.h"

@class HPFloatingUI;

/**
 * View a single haiku. Users can vote on haiku and share.
 */
@interface HaikuViewController : UIViewController<HPCommunicatorDelegate>

/**
 * Communicator that handles the Haiku+ API. Supplied by external class.
 */
@property(nonatomic, weak) HPCommunicator *communicator;
@property(nonatomic, strong) NSString *haikuID;
@property(nonatomic, strong) HPHaiku *haiku;
@property BOOL votePending;

/**
 * UI labels.
 */
@property(nonatomic, weak) IBOutlet UILabel *haikuTitleLabel;
@property(nonatomic, weak) IBOutlet UILabel *lineOneLabel;
@property(nonatomic, weak) IBOutlet UILabel *lineTwoLabel;
@property(nonatomic, weak) IBOutlet UILabel *lineThreeLabel;
@property(nonatomic, weak) IBOutlet UILabel *votesLabel;
@property(nonatomic, weak) IBOutlet UILabel *authorDisplayNameLabel;
@property(nonatomic, weak) IBOutlet UIImageView *authorDisplayImageView;
@property(nonatomic, weak) IBOutlet UILabel *dateCreatedLabel;

/**
 * This class shows UI to the user when actions take place.
 */
@property(nonatomic, weak) HPFloatingUI *floatingUI;

@end
