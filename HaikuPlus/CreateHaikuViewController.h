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

#import "HPCommunicator.h"

@class HomeViewController;
@class HPCommunicator;
@class HPFloatingUI;

/**
 * View controller for haiku creation.
 * Allows users to submit a haiku with a title, and three lines of text.
 */
@interface CreateHaikuViewController : UIViewController <UITextFieldDelegate,
    HPCommunicatorDelegate>

/**
 * Communicator that handles the Haiku+ API. Supplied by external class.
 */
@property(nonatomic, weak) HPCommunicator *communicator;

/**
 * IBOutlets.
 */
@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIButton *createButton;
@property(nonatomic, weak) IBOutlet UITextField *haikuTitle;
@property(nonatomic, weak) IBOutlet UITextField *lineOne;
@property(nonatomic, weak) IBOutlet UITextField *lineTwo;
@property(nonatomic, weak) IBOutlet UITextField *lineThree;

/**
 * This object shows UI to the user when actions take place.
 */
@property(nonatomic, weak) HPFloatingUI *floatingUI;

/**
 * Parent view controller.
 */
@property(nonatomic, weak) HomeViewController *parent;

@end
