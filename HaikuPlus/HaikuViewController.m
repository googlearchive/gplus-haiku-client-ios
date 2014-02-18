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

#import "HaikuViewController.h"

#import "HPConstants.h"
#import "HPFloatingUI.h"
#import "HPHaiku.h"
#import "HPUser.h"

@implementation HaikuViewController {
  BOOL _sharePending;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Prepare haiku view when the view first loads.
  [self refreshHaikuView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Assign self to communicator delegate. Receive app sign-in updates.
  _communicator.delegate = self;

  // Make network call requesting haiku.
  [self reloadHaiku];

  // Try to vote if this view is loaded because of a deep link.
  if (_votePending) {
    [self vote];
  }
}

/**
 * User pressed button to share a haiku.
 *
 * @param sender Object that sent the action message.
 * @return IBAction void.
 */
- (IBAction)promoteButtonPressed:(id)sender {
  if ([_communicator isSignedInWithServer]) {
    [self share];
  } else {
    // If the user is not signed in, initiate the sign-in flow.
    // When the user completes the sign-in flow, the HPCommunicator will call
    // - (void)didUpdateSignInWithError: as part of the HPCommunicatorDelegate protocol.
    // That method will check |sharePending| and call - (void)share.
    _sharePending = YES;
    [_communicator signIn];
  }
}

/**
 * User pressed button to vote on a haiku.
 *
 * @param sender Object that sent the action message.
 * @return IBAction void.
 */
- (IBAction)voteButtonPressed:(id)sender {
  if ([_communicator isSignedInWithServer]) {
    [self vote];
  } else {
    // If the user is not signed in, initiate the sign-in flow.
    // When the user completes the sign-in flow, the HPCommunicator will call
    // - (void)didUpdateSignInWithError: as part of the HPCommunicatorDelegate protocol.
    // That method will check |votePending| and call - (void)vote.
    _votePending = YES;
    [_communicator signIn];
    return;
  }
}

/**
 * User pressed back button.
 *
 * @param sender Object that sent the action message.
 * @return IBAction void.
 */
- (IBAction)backButtonPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Execute an Interactive Post to allow the user to share this haiku on Google+.
 * The call-to-action button "Vote" is automatically translated to the user's language.
 * The share contains two URLs. The |contentURLString| is the location of the haiku, which is where
 * desktop users will be sent when they click on the post. The |CTAURLString| is the where
 * desktop users will be sent when they click on the call-to-action button.
 * Both URLs contain corresponding deep links. These will be passed to the mobile Haiku+ app
 * (Android or iOS) so that the app can complete the correct action.
 * See https://developers.google.com/+/mobile/ios/share/interactive-post for more details.
 */
- (void)share {
  _sharePending = NO;

  // Content URL: destination for web users that click the post.
  // Example: "https://www.example.com/haikus/1234haikuID"
  NSString *contentURLString = _haiku.content_url;
  // Deep Link ID: passed to the mobile Haiku+ app when the user clicks the the post.
  // Example: "/haikus/1234haikuID"
  NSString *contentDeepLinkID = _haiku.content_deep_link_id;
  // Call-to-action URL: destination for web users that click the call-to-action button.
  // Example: "https://www.example.com/haikus/1234haikuID?action=vote"
  NSString *CTAURLString = _haiku.call_to_action_url;
  // Deep Link ID: passed to the mobile Haiku+ app when the user clicks the call-to-action button.
  // Example: "/haikus/1234haikuID?action=vote"
  NSString *CTADeepLinkID = _haiku.call_to_action_deep_link_id;

  // Use the native share dialog in your app:
  id<GPPNativeShareBuilder> shareBuilder;
  shareBuilder = (id<GPPNativeShareBuilder>)[[GPPShare sharedInstance] nativeShareDialog];

  // The share preview, which includes the title, description, and a thumbnail, is generated from
  // the page at the |contentURLString| location.
  NSURL *shareURL = [NSURL URLWithString:contentURLString];
  [shareBuilder setURLToShare:shareURL];

  NSString *prefillText = @"Please vote for this haiku.\n\n#Haiku+";
  [shareBuilder setPrefillText:prefillText];

  // This line passes the string |contentDeepLinkID| to your native application
  // if somebody opens the link on a supported mobile device.
  [shareBuilder setContentDeepLinkID:contentDeepLinkID];

  // This method creates a call-to-action button with the label "VOTE".
  // - URL specifies where people will go if they click the button on a platform
  // that doesn't support deep linking.
  // - deepLinkID specifies the deep-link identifier that is passed to your native
  // application on platforms that do support deep linking.
  [shareBuilder setCallToActionButtonWithLabel:@"VOTE"
                                           URL:[NSURL URLWithString:CTAURLString]
                                    deepLinkID:CTADeepLinkID];

  [shareBuilder open];
}

/**
 * Vote using the Haiku+ API.
 */
- (void)vote {
  _votePending = NO;

  [_floatingUI addLoadingSpinner];
  [_communicator voteForHaikuWithID:_haikuID completion:^(NSError *error) {
      [_floatingUI removeLoadingSpinner];
      [self didCompleteVote:error];
  }];
}

/**
 * Show result of vote to user and reload haiku if vote was successful.
 *
 * @param error Error from the server which is nil on success.
 */
- (void)didCompleteVote:(NSError *)error {
  if (!error) {
    [self reloadHaiku];
    [_floatingUI showToast:@"Voted!"];
  } else {
    NSString *message = [NSString stringWithFormat:@"Could not vote: %@", error];
    [_floatingUI showToast:message];
  }
}

/**
 * Make network call requesting haiku.
 */
- (void)reloadHaiku {
  [_floatingUI addLoadingSpinner];
  [_communicator fetchHaikuWithID:_haikuID
                       completion:^(HPHaiku *haiku, NSError *error) {
                           [_floatingUI removeLoadingSpinner];
                           [self didReceiveHaiku:haiku error:error];
                           [self refreshHaikuView];
                       }];
}

/**
 * Receive haiku from communicator. Called by this class.
 *
 * @param user The haiku object retrieved from the Haiku+ server.
 * @param error Error from the server request which is nil on success.
 */
- (void)didReceiveHaiku:(HPHaiku *)haiku error:(NSError *)error {
  if (!error) {
    _haiku = haiku;
  } else {
    NSLog(@"Could not retrieve haiku: %@", error);
    [_floatingUI showToast:@"Could not retrieve haiku"];
  }
}

/**
 * Refresh the haiku information based on the locally stored haiku data.
 */
- (void)refreshHaikuView {
  _haikuTitleLabel.text = _haiku.title;
  _lineOneLabel.text = _haiku.line_one;
  _lineTwoLabel.text = _haiku.line_two;
  _lineThreeLabel.text = _haiku.line_three;
  _votesLabel.text = [NSString stringWithFormat:@"Votes: %d", _haiku.votes];
  _authorDisplayNameLabel.text = _haiku.author.google_display_name;
  if (_haiku) {
    [_authorDisplayImageView setImage:nil];
    [_communicator fetchImageWithURL:[NSURL URLWithString:_haiku.author.google_photo_url]
                          completion:^(UIImage *image, NSError *error) {
                              if (!error) {
                                [_authorDisplayImageView setImage:image];
                              } else {
                                NSLog(@"Could not retrieve author profile image: %@", error);
                                NSLog(@"Author profile image: %@", _haiku.author.google_photo_url);
                              }
                          }];
  } else {
    // If we're initializing a blank page (the haiku has not been loaded yet), do not fetch
    // an image and just set the image to nil.
    [_authorDisplayImageView setImage:nil];
  }
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:kHPConstantsVisibleDateFormat];
  _dateCreatedLabel.text  = [dateFormatter stringFromDate:_haiku.creation_time];
}

#pragma mark - HPCommunicatorDelegate methods

/**
 * This method receives updates about a user's Haiku+ sign-in state.
 * This could be called after the Google+ Sign-In library determines that a user has signed in,
 * or this could be called after an API call fails with the server, indicating that the user's
 * session is no longer valid.
 *
 * @param error Error from the server which is nil on success.
 */
- (void)didUpdateSignInWithError:(NSError *)error {
  if ([_communicator isSignedInWithServer]) {
    if (_sharePending) {
      [self share];
    }
    if (_votePending) {
      [self vote];
    }
  }
}

/**
 * Requesting the user's profile image requires a separate network
 * call from sign-in. The HPCommunicator class will fetch the profile image automatically, and
 * call this method when the image is ready to be retrieved.
 */
- (void)didFinishFetchingDisplayImage {
  // Do nothing because we don't display the user profile information in this view.
}

@end
