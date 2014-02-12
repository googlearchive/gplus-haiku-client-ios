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

#import "HomeViewController.h"

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#import "AppDelegate.h"
#import "CreateHaikuViewController.h"
#import "HaikuViewController.h"
#import "HPConstants.h"
#import "HPFloatingUI.h"
#import "HPHaiku.h"
#import "HPUser.h"

enum {
  kHaikuViewTitleLabel = 100,
  kHaikuViewLineOneLabel = 101,
  kHaikuViewLineTwoLabel = 102,
  kHaikuViewLineThreeLabel = 103,
  kHaikuViewVotesLabel = 104,
  kHaikuViewAuthorLabel = 105,
  kHaikuViewDateLabel = 106,
  kHaikuViewImageLabel = 107,
  kHaikuOptionsViewFilterControl = 108
};

@implementation HomeViewController {
  // This view controller keeps track of the sign-in state so that when the communicator
  // tells this object about sign-in updates, this view controller knows whether or not to fetch
  // haiku information.
  BOOL _isSignedIn;
  NSDateFormatter* _dateFormatter;
  NSString *_overriddenHaikuID;
  BOOL _voteAfterNextSegue;
}

- (id)init {
  self = [super init];
  if (self) {
    [self doesNotRecognizeSelector:_cmd];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:kHPConstantsVisibleDateFormat];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Use the communicator prepared by the AppDelegate.
  _communicator = _appDelegate.communicator;
  // This class shows UI to the user when actions take place.
  _floatingUI = _appDelegate.floatingUI;
  _signInButton.style = kGPPSignInButtonStyleWide;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Assign self to communicator delegate. Receive app sign-in updates.
  _communicator.delegate = self;

  // Sign-in state can be different every time a view appears.
  [self updateSignInStatus];

  // Make network call requesting haikus.
  [self reloadHaikus];
}

#pragma mark - HPCommunicatorDelegate methods

// HPCommunicatorDelegate. This method receives updates about a user's Haiku+ sign-in state.
// This could be called after the Google+ Sign-In library determines that a user has signed in,
// or this could be called after an API call fails with the server, indicating that the user's
// session is no longer valid.
- (void)didUpdateSignInWithError:(NSError *)error {
  if (![_communicator isSignedInWithServer]) {
    NSLog(@"Not signed in with error: %@", error);

    // Make sure we are not filtering haikus by friends.
    [self setFilteringByFriends:NO];

    if (_isSignedIn) {
      // We were previously signed in with the server, so we need to reload haikus.
      [_floatingUI showToast:@"User is no longer signed in"];

      // Reload unfiltered haikus.
      [self reloadHaikus];
    } else {
      [_floatingUI showToast:@"Could not sign in user with Haiku+ server"];
    }
  }
  // The sign-in status must be updated after |isSignedIn| is checked. This makes it possible
  // for the app to show a different message to users that were previously signed in.
  [self updateSignInStatus];
}

// HPCommunicatorDelegate. Requesting the user's profile image requires a separate network
// call from sign-in. The HPCommunicator class will fetch the profile image automatically, and
// call this method when the image is ready to be retrieved.
- (void)didFinishFetchingDisplayImage {
  [self updateSignInStatus];
}

#pragma mark - Sign-in methods

// Sign out the user, manually refresh view.
- (IBAction)signOutButtonPressed:(id)sender {
  [_floatingUI addLoadingSpinner];
  // Tell server that the user is signed out.
  [_communicator signOutWithCompletion:^(NSError *error) {
      [_floatingUI removeLoadingSpinner];
      [self updateSignInStatus];
      if (!error) {
        [_floatingUI showToast:@"User signed out"];
        // Reload unfiltered haikus.
        [self reloadHaikus];
      } else {
        NSLog(@"Could not sign out: %@", error);
      }
  }];
}

// Disconnect the user, manually refresh view.
- (IBAction)disconnectButtonPressed:(id)sender {
  [_floatingUI addLoadingSpinner];
  // Tell server that the user is disconnecting.
  [_communicator disconnectWithCompletion:^(NSError *error) {
      [_floatingUI removeLoadingSpinner];
      [self updateSignInStatus];
      if (!error) {
        [_floatingUI showToast:@"User disconnected Google account"];
        // Reload unfiltered haikus.
        [self reloadHaikus];
      } else {
        NSLog(@"Could not disconnect: %@", error);
      }
  }];
}

// Updates view to reflect the signed in or signed out state.
- (void)updateSignInStatus {
  // Record whether the user is signed in or not.
  _isSignedIn = [_communicator isSignedInWithServer];
  // Update view UI.
  HPUser *currentUser = _isSignedIn ? _communicator.currentUser : nil;
  _nameLabel.text = _isSignedIn ? currentUser.google_display_name : @"";
  UIImage *displayImage = _isSignedIn ? _communicator.displayImage : nil;
  [_displayImageView setImage: displayImage];
  _displayImageView.alpha = _isSignedIn ? 1 : 0;
  _nameLabel.alpha = _isSignedIn ? 1 : 0;
  _introductionLabel.alpha = _isSignedIn ? 0 : 1;
  _signInButton.alpha = _isSignedIn ? 0 : 1;
  _signOutButton.alpha = _isSignedIn ? 1 : 0;
  _disconnectButton.alpha = _isSignedIn ? 1 : 0;
  _createButton.enabled = _isSignedIn;
  if (!_isSignedIn) {
    // Stop filtering haikus if the user is not signed in.
    [self setFilteringByFriends:NO];
  }
  // Tell tableView to reload view.
  [_tableView reloadData];
}

#pragma mark - Haikus

// Button pressed to toggle viewing haikus filtered by friends.
- (IBAction)filterButtonPressed:(id)sender {
  // The filter state has probably changed.
  UISegmentedControl *button = (UISegmentedControl *)sender;
  BOOL filteringPressed = button.selectedSegmentIndex == kHPConstantsFilterFriendsIndex;
  BOOL currentlyFiltering = [self isFilteringByFriends];
  if (filteringPressed != currentlyFiltering) {
    [self setFilteringByFriends:filteringPressed];
    // Make network call requesting haikus.
    [self reloadHaikus];
    [_tableView reloadData];
  }
}

// Make network call requesting haikus.
- (void)reloadHaikus {
  [_floatingUI addLoadingSpinner];
  [_communicator fetchHaikusFiltered:[self isFilteringByFriends]
                          completion:^(NSArray *haikus, NSError *error) {
                              [_floatingUI removeLoadingSpinner];
                              [self didReceiveHaikus:haikus error:error];
                          }];
}

/**
 * Receive haiku from communicator. Called by this class.
 *
 * @param user The haiku object retrieved from the Haiku+ server.
 * @param error Error from the server request which is nil on success.
 */
- (void)didReceiveHaikus:(NSArray *)haikus error:(NSError *)error {
  if (!error) {
    NSLog(@"Haikus received: %u", (unsigned int)[haikus count]);
    // Store haikus.
    _haikus = haikus;
    // Tell tableView to reload haiku data.
    [_tableView reloadData];
  } else {
    // Failed because of a bad network connection or because the user is not signed in and the app
    // is trying to filter haikus by friends.
    NSLog(@"Could not retrieve haikus: %@", error);
    [_floatingUI showToast:@"Could not retrieve haikus"];
  }
}

#pragma mark - Table View

/**
 * Haiku for index path. When the user is signed in, the 0 index contains options.
 * Each haiku is shown at the following index.
 *
 * @param indexPath the index path that might contain a haiku.
 * @return HPHaiku or nil if the row contains a different UI element.
 */
- (HPHaiku *)haikuForIndexPath:(NSIndexPath *)indexPath {
  NSUInteger haikuIndex = indexPath.row;
  if (_isSignedIn) {
    if (haikuIndex == 0) {
      // This row contains options for creating and filtering haikus.
      return nil;
    } else {
      haikuIndex--;
    }
  }
  return [_haikus objectAtIndex:haikuIndex];;
}

/**
 * Return number of haikus for UITableView data source.
 *
 * @param tableView Haiku table view.
 * @param section Only handles section 0.
 * @return Number of haikus.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (_isSignedIn) {
    // Includes row for creating and filtering haikus.
    return [_haikus count] + 1;
  } else {
    return [_haikus count];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (_isSignedIn && indexPath.row == 0) {
    return 140;
  } else {
    return 220;
  }
}

/**
 * Return cell for UITableView data source.
 * Return haiku options for row 0 when user is signed in.
 * Return haiku at index for all other rows.
 *
 * @param tableView Table view containing a list of haikus.
 * @param indexPath Index path for a haiku in the list of haikus.
 * @return Table view cell for haiku with prepared labels.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (_isSignedIn && indexPath.row == 0) {
    return [self haikuOptionsCellForTableView:tableView];
  } else {
    HPHaiku *haiku = [self haikuForIndexPath:indexPath];
    return [self tableView:tableView cellForHaiku:haiku];
  }
}

/**
 * Return options cell for UITableView data source.
 * Show option to add a haiku or filter haikus by friends.
 *
 * @param tableView Table view containing a list of haikus.
 * @return Table view cell for haiku with prepared labels.
 */
- (UITableViewCell *)haikuOptionsCellForTableView:(UITableView *)tableView {
  NSString *const kSimpleTableIdentifier = @"HaikuOptions";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleTableIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:kSimpleTableIdentifier];
  }
  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  [cell setAccessoryType:UITableViewCellAccessoryNone];

  UISegmentedControl *filteringControl =
      (UISegmentedControl *)[cell viewWithTag:kHaikuOptionsViewFilterControl];
  BOOL filtering = [self isFilteringByFriends];
  filteringControl.selectedSegmentIndex = filtering ?
      kHPConstantsFilterFriendsIndex : kHPConstantsFilterEveryoneIndex;
  return cell;
}

/**
 * Return haiku cell for UITableView data source.
 * Prepare all haiku data that needs to be displayed in list.
 containing a list of haikus.
 * @param haiku Haiku with data to be put in cell.
 * @return Table view cell for haiku with prepared labels.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForHaiku:(HPHaiku *)haiku {
  NSString *const kSimpleTableIdentifier = @"HaikuCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleTableIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:kSimpleTableIdentifier];
  }

  // Get all UILabel objects that need to be assigned.
  UILabel *haikuTitleView = (UILabel *)[cell viewWithTag:kHaikuViewTitleLabel];
  UILabel *haikuLineOne = (UILabel *)[cell viewWithTag:kHaikuViewLineOneLabel];
  UILabel *haikuLineTwo = (UILabel *)[cell viewWithTag:kHaikuViewLineTwoLabel];
  UILabel *haikuLineThree = (UILabel *)[cell viewWithTag:kHaikuViewLineThreeLabel];
  UILabel *haikuVotes = (UILabel *)[cell viewWithTag:kHaikuViewVotesLabel];
  UILabel *authorName = (UILabel *)[cell viewWithTag:kHaikuViewAuthorLabel];
  UILabel *haikuCreationDate = (UILabel *)[cell viewWithTag:kHaikuViewDateLabel];
  UIImageView *authorImageView = (UIImageView *)[cell viewWithTag:kHaikuViewImageLabel];

  // Get haiku data.
  // Assign haiku data to each UILabel.
  haikuTitleView.text = haiku.title;
  haikuLineOne.text = haiku.line_one;
  haikuLineTwo.text = haiku.line_two;
  haikuLineThree.text = haiku.line_three;
  haikuVotes.text = [NSString stringWithFormat:@"Votes: %d", haiku.votes];
  authorName.text = [NSString stringWithFormat:@"By %@", haiku.author.google_display_name];

  NSString *dateString = [_dateFormatter stringFromDate:haiku.creation_time];
  haikuCreationDate.text = dateString;

  // Asynchronously fetch author image for each haiku.
  NSURL *url = [NSURL URLWithString:haiku.author.google_photo_url];
  [authorImageView setImage:nil];
  [_communicator fetchImageWithURL:url
                        completion:^(UIImage *image, NSError *error) {
                            if (!error) {
                              [authorImageView setImage:image];
                            } else {
                              NSLog(@"Could not retrieve author profile image: %@", error);
                            }
                        }];

  return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqual:@"showHaikuSegue"]) {
    // Segue to haiku view, pass HaikuViewController information about Haiku.
    // This gets called when a user taps a haiku from the list to navigate to a full view.
    // It must pass the haiku ID so the destination view controller can request the rest of the
    // data.
    NSString *haikuID = [self selectedHaikuID];
    HaikuViewController *destViewController = segue.destinationViewController;
    destViewController.haikuID = haikuID;
    destViewController.votePending = [self shouldVoteAfterSegue];
    destViewController.communicator = _communicator;
    destViewController.floatingUI = _floatingUI;
  } else if ([segue.identifier isEqual:@"createHaikuSegue"]) {
    // Pass communicator to CreateHaikuViewController.
    // This gets called when a signed in user tries to create a haiku.
    CreateHaikuViewController *destViewController = segue.destinationViewController;
    destViewController.communicator = _communicator;
    destViewController.floatingUI = _floatingUI;
    destViewController.parent = self;
  }
}

- (NSString *)selectedHaikuID {
  NSString *haikuID;
  if (_overriddenHaikuID != nil) {
    haikuID = _overriddenHaikuID;
    _overriddenHaikuID = nil;
  } else {
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    HPHaiku *haiku = [self haikuForIndexPath:indexPath];
    haikuID = haiku.identifier;
  }
  return haikuID;
}

- (void)overrideSelectedHaikuIDOnce:(NSString *)haikuID {
  _overriddenHaikuID = haikuID;
}

/**
 * Returns YES if the haiku should be voted on after the next segue.
 *
 * @return YES after -(void)voteAfterHaikuSegueOnce is called, and subsequent calls
 * will return NO.
 */
- (BOOL)shouldVoteAfterSegue {
  if (_voteAfterNextSegue) {
    _voteAfterNextSegue = NO;
    return YES;
  }
  return NO;
}

/**
 * Causes -(BOOL)shouldVoteAfterSegue to return YES for one call.
 */
- (void)voteAfterHaikuSegueOnce {
  _voteAfterNextSegue = YES;
}

@end
