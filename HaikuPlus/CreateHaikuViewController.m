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

#import "CreateHaikuViewController.h"

#import "HomeViewController.h"
#import "HPCommunicator.h"
#import "HPConstants.h"
#import "HPFloatingUI.h"
#import "HPHaiku.h"

@implementation CreateHaikuViewController {
  BOOL _createPending;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Assign self to communicator delegate. Receive app sign-in updates.
  _communicator.delegate = self;
}

/**
 * User pressed button to submit a haiku.
 *
 * @param sender Object that sent the action message.
 * @return IBAction void.
 */
- (IBAction)createButtonPressed:(id)sender {
  if ([_communicator isSignedInWithServer]) {
    [self createHaiku];
  } else {
    // If the user is not signed in, initiate the sign-in flow.
    // When the user completes the sign-in flow, the HPCommunicator will call
    // - (void)didUpdateSignInWithError: as part of the HPCommunicatorDelegate protocol.
    // That method will check |createPending| and call - (void)createHaiku.
    _createPending = YES;
    [_communicator signIn];
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
 * Make network call to Haiku+ API to create a haiku using the fields in this form.
 */
- (void)createHaiku {
  HPHaiku *haikuToUpload = [[HPHaiku alloc] init];
  haikuToUpload.title = _haikuTitle.text;
  haikuToUpload.line_one = _lineOne.text;
  haikuToUpload.line_two = _lineTwo.text;
  haikuToUpload.line_three = _lineThree.text;
  [_floatingUI addLoadingSpinner];
  [_communicator createHaiku:haikuToUpload
                  completion:^(HPHaiku *haiku, NSError *error) {
                      [_floatingUI removeLoadingSpinner];
                      [self didCreateHaiku:haiku error:error];
                  }];
}

/**
 * Navigate user to haiku if successful, otherwise show error to user. Called by this class.
 *
 * @param user The haiku object retrieved from the Haiku+ server.
 * @param error Error from the server request which is nil on success.
 */
- (void)didCreateHaiku:(HPHaiku *)haiku error:(NSError *)error {
  if (!error) {
    [self clearForm];
    [_floatingUI showToast:@"Created haiku!"];
    NSString *haikuID = haiku.identifier;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.parent overrideSelectedHaikuIDOnce:haikuID];
    [self.parent performSegueWithIdentifier:@"showHaikuSegue" sender:self];
  } else {
    NSString *message = [NSString stringWithFormat:@"Could not create haiku: %@", error];
    [_floatingUI showToast:message];
  }
}

// Clear fields in haiku creation form.
- (void)clearForm {
  _haikuTitle.text = @"";
  _lineOne.text = @"";
  _lineTwo.text = @"";
  _lineThree.text = @"";
}

/**
 * Prevent keyboard from blocking text fields.
 *
 * @param textField Active text field.
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  CGFloat x = self.scrollView.bounds.origin.x;
  CGFloat y = self.scrollView.bounds.origin.y;
  CGFloat w = self.scrollView.bounds.size.width;
  CGFloat h = self.scrollView.bounds.size.height;

  switch (textField.tag) {
    case 0:
      y = kHPConstantsKeyboardOffset;
      break;
    case 1:
      y = kHPConstantsKeyboardOffset + kHPConstantsTextFieldSpacing * 1;
      break;
    case 2:
      y = kHPConstantsKeyboardOffset + kHPConstantsTextFieldSpacing * 2;
      break;
    case 3:
      y = kHPConstantsKeyboardOffset + kHPConstantsTextFieldSpacing * 3;
      break;

    default:
      break;
  }
  CGRect bounds = CGRectMake(x, y, w, h);
  self.scrollView.bounds = bounds;
}

/**
 * Restore view when keyboard is dismissed.
 *
 * @param textField Dismissed text field.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
  CGFloat x = self.scrollView.bounds.origin.x;
  CGFloat y = self.scrollView.bounds.origin.y;
  CGFloat w = self.scrollView.bounds.size.width;
  CGFloat h = self.scrollView.bounds.size.height;

  y = 0;
  CGRect bounds = CGRectMake(x, y, w, h);
  self.scrollView.bounds = bounds;
}

/**
 * Handles "return" key on the keyboard.
 * Clicking "Next" moves the cursor to the next line until all the haiku fields have been filled.
 * If all the fields have been filled, the user clicks "Done" and the keyboard is closed with
 * [textField resignFirstResponder].
 *
 * @param textField Active text field where the user pressed the Return key.
 * @return NO to indicate that we do not want to enter line-breaks.
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
  NSInteger nextTag = textField.tag + 1;
  // Try to find next responder.
  UIResponder *nextResponder;
  switch (nextTag) {
    case 1:
      nextResponder = _lineOne;
      break;
    case 2:
      nextResponder = _lineTwo;
      break;
    case 3:
      nextResponder = _lineThree;
      break;
  }
  if (nextResponder) {
    // Found next responder, so set it.
    [nextResponder becomeFirstResponder];
  } else {
    // Not found, so remove keyboard.
    [textField resignFirstResponder];
  }
  return NO; // We do not want UITextField to insert line-breaks.
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
    if (_createPending) {
      [self createHaiku];
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
