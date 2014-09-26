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

#import "HPFloatingUI.h"

@implementation HPFloatingUI {
  UILabel *_toastLabel;
  UIActivityIndicatorView *_loadingSpinner;
  UIColor *_color;
  NSInteger _loadingCount;
}

#pragma mark - Toast Animation Constants

/**
 * Toast constants.
 */
CGFloat const kToastAnimationDuration = .5;
CGFloat const kToastAnimationDelay = 1.75;
CGFloat const kToastX = 0;
CGFloat const kToastHiddenY = -50.0;
CGFloat const kToastVisibleY = 85;
CGFloat const kToastWidth = 320;
CGFloat const kToastHeight = 50;

/**
 * Spinning activity indicator constants.
 */
CGFloat const kFloatingUIColorR = 0;
CGFloat const kFloatingUIColorG = .5;
CGFloat const kFloatingUIColorB = 1;
CGFloat const kFloatingUIColorA = 1;

#pragma mark - Loading Spinner Animation Constants

CGFloat const kLoadingSpinnerX = 150;
CGFloat const kLoadingSpinnerY = 160;
CGFloat const kLoadingSpinnerWidth = 20;
CGFloat const kLoadingSpinnerHeight = 20;

- (id)init {
  self = [super init];
  if (self) {
    _color = [[UIColor alloc] initWithRed:kFloatingUIColorR
                                    green:kFloatingUIColorG
                                     blue:kFloatingUIColorB
                                    alpha:kFloatingUIColorA];
    // Prepare loading spinner.
    _loadingSpinner = [[UIActivityIndicatorView alloc] init];
    _loadingSpinner.hidesWhenStopped = YES;
    _loadingSpinner.color = _color;
    CGFloat spinX = kLoadingSpinnerX;
    CGFloat spinY = kLoadingSpinnerY;
    CGFloat spinWidth = kLoadingSpinnerWidth;
    CGFloat spinHeight = kLoadingSpinnerHeight;
    CGRect spinRect = CGRectMake(spinX, spinY, spinWidth, spinHeight);
    [_loadingSpinner setFrame:spinRect];

    // Prepare toast.
    _toastLabel = [[UILabel alloc] init];
    [_toastLabel setBackgroundColor:_color];
    _toastLabel.textAlignment = NSTextAlignmentCenter;
    _toastLabel.font = [UIFont systemFontOfSize:12];
    _toastLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    CGRect toastRect = CGRectMake(kToastX, kToastHiddenY, kToastWidth, kToastHeight);
    [_toastLabel setFrame:toastRect];
  }

  return self;
}

#pragma mark - Loading Spinner

- (void)addLoadingSpinner {
  [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingSpinner];
  _loadingCount++;
  [_loadingSpinner startAnimating];
}

- (void)removeLoadingSpinner {
  if (_loadingCount > 0) {
    _loadingCount--;
  }
  if (_loadingCount == 0) {
    [_loadingSpinner stopAnimating];
  }
}

#pragma mark - Toast Notification

- (void)showToast:(NSString *)message {
  NSLog(@"%@", message);
  [[[UIApplication sharedApplication] keyWindow] addSubview:_toastLabel];
  _toastLabel.text = message;
  CGRect visibleRect = CGRectMake(kToastX, kToastVisibleY, kToastWidth, kToastHeight);
  [UIView animateWithDuration:kToastAnimationDuration
                        delay:0
                      options:(UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                   animations:^{
                       [_toastLabel setFrame:visibleRect];
                   }
                   completion:^(BOOL finished) {
                       [self _hideToast];
                   }];
}

- (void)_hideToast {
  CGRect hiddenRect = CGRectMake(kToastX, kToastHiddenY, kToastWidth, kToastHeight);
  [UIView animateWithDuration:kToastAnimationDuration
                        delay:kToastAnimationDelay
                      options:(UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                   animations:^{
                     [_toastLabel setFrame:hiddenRect];
                   }
                   completion:nil];
}

@end
