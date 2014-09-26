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

@class AppDelegate;
@class GPPSignInButton;
@class HPFloatingUI;

/**
 * Main view of app. Shows list of haikus.
 * Signed-in user can:
 *  -- Create a haiku
 *  -- Filter haikus by friends
 *  -- Sign out
 *  -- Disconnect
 */
@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
    HPCommunicatorDelegate>

@property(nonatomic, weak) AppDelegate *appDelegate;

/**
 * Haiku+ objects.
 */
@property(nonatomic, weak) HPCommunicator *communicator;
@property(nonatomic, strong) NSArray *haikus;
@property(nonatomic, assign, getter=isFilteringByFriends) BOOL filteringByFriends;

/**
 * Buttons.
 */
@property(retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property(nonatomic, weak) IBOutlet UIButton *signOutButton;
@property(nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *createButton;

/**
 * Labels and data views.
 */
@property(nonatomic, weak) IBOutlet UILabel *introductionLabel;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UIImageView *displayImageView;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

/**
 * This object shows UI to the user when actions take place.
 */
@property(nonatomic, weak) HPFloatingUI *floatingUI;

/**
 * Return haiku ID of the selected haiku.
 *
 * Usually returns the haiku ID from the selected item in the tableView. If a developer has called
 * -(void)overrideSelectedHaikuIDOnce:(NSString *), then this method will return
 * the overriden ID once. Subsequent calls to this method will return the ID from the selected
 * haiku tem in the tableView.
 *
 * @return Haiku ID from table view or overriden value.
 */
- (NSString *)selectedHaikuID;

/**
 * Overrides the return value from (NSString *)selectedHaikuID for one method call.
 *
 * @param haikuID The Haiku ID to be returned by -(NSString *)selectedHaikuID.
 */
- (void)overrideSelectedHaikuIDOnce:(NSString *)haikuID;

/**
 * Tell haiku view to vote for haiku during next segue.
 */
- (void)voteAfterHaikuSegueOnce;

@end
