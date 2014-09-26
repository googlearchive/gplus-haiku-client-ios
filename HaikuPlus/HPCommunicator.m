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

#import <GoogleOpenSource/GoogleOpenSource.h>

#import "AFImageRequestOperation.h"
#import "HPConstants.h"
#import "HPHaiku.h"
#import "HPNetworkClient.h"
#import "HPUser.h"

@implementation HPCommunicator

/**
 * Set the User-Agent field in the header for the server to recognize the iOS client.
 */
- (void)setNetworkClient:(HPNetworkClient *)network {
  if (_networkClient != network) {
    _networkClient = network;
    [_networkClient setDefaultHeader:@"User-Agent" value:kHPConstantsUserAgent];
  }
}

- (void)setAuth:(GTMOAuth2Authentication *)theAuth {
  _auth = theAuth;
}

- (NSError *)authorizationError {
  return [NSError errorWithDomain:kHPErrorDomain
                             code:kHPErrorDomainUnauthorized
                         userInfo:nil];
}

#pragma mark - GPPSignInDelegate protocol methods

/**
 * Determines whether a user successfully signed in to your app and informs the delegate.
 *
 * @param auth Authentication credentials.
 * @param error Error from the GPPSignIn class which is nil on success.
 */
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
  if (!error) {
    // DO NOT DO THIS. Setting this property tells the library to authorize requests even if they
    // are not sent over HTTPS. Some development servers do not support SSL,
    // so we have chosen to take this shortcut for teaching purposes. Be sure to use best
    // practices, including HTTPS, when securing Google authorization information.
    auth.shouldAuthorizeAllRequests = YES;

    // User is signed in with Google on the device. Prepare auth information for our communicator
    // so that the communicator can include auth information in requests to the Haiku+ server.
    [self setAuth:auth];

    // The communicator will ensure that the GTMOAuth2Authentication information is included in
    // the request to fetch a user from the Haiku+ server. If the Haiku+ server is able to use the
    // auth information to authenticate this request, then the Haiku+ server will fetch
    // information about the user from Google to populate the database. The server will then
    // return data for an HPUser object.
    // This call works for new users as well as existing Haiku+ users. We do not need to separate
    // sign-in and sign-up steps because the entire user account is created just by knowing
    // who the user is. If your app needs to know information about a new user that cannot be found
    // in the user's Google+ profile, such as the user's favorite color, we suggest automatically
    // asking a user to "complete" their profile after they sign in. This is better than telling
    // the user that their "account does not exist" and forcing the user to click another button
    // to "sign up".
    [self fetchCurrentUserWithCompletion:^(HPUser *user, NSError *error) {
        [self didReceiveUser:user error:error];
    }];
  } else {
    NSLog(@"Google+ Sign-In failed: %@", error);
    // Sign out of the app on the device.
    [self signOutDevice];

    // Inform the delegate that sign-in failed.
    [_delegate didUpdateSignInWithError:error];
  }
}

#pragma mark - Sign-in methods

/**
 * Signs in the user with Google+ Sign-In. If the user is already signed in, the callback
 * - (void)finishedWithAuth:error: is called and the sign-in process will complete without
 * a consent dialog.
 */
- (void)signIn {
  [_gppSignIn authenticate];
}

/**
 * Determine if the Haiku+ server successfully signed in the user and inform the delegate.
 *
 * @param user The user object retrieved from the Haiku+ server.
 * @param error Error from the server request which is nil on success.
 */
- (void)didReceiveUser:(HPUser *)user error:(NSError *)error {
  if (!error) {
    // The user is successfully signed in to Haiku+ and their information is in the |user| object.
    _signedInWithServer = YES;

    // Store the user object so this app can access it later.
    self.currentUser = user;

    // Make an asynchronous network request to fetch the profile image.
    NSURL *photoURL = [NSURL URLWithString:user.google_photo_url];
    [self fetchImageWithURL:photoURL
                 completion:^(UIImage *image, NSError *error) {
                     // Image will be nil if an error occurs.
                     self.displayImage = image;
                     // Inform the delegate that the profile image has been updated.
                     [_delegate didFinishFetchingDisplayImage];
                 }];
  } else {
    // User could not be signed in on the server due to a bad network connection or invalid access
    // token. For simplicity, we will sign the user out on the device, although a production app
    // could handle the bad network connection with retry logic.

    // Sign out of the app on the device.
    [self signOutDevice];
  }
  // Inform the delegate that the sign-in state has been updated.
  [_delegate didUpdateSignInWithError:error];
}

/**
 * Perform all device sign-out actions.
 * Called by this class to maintain internal consistency.
 */
- (void)signOutDevice {
  [_gppSignIn signOut];
  [self deleteSessionCookie];
  _signedInWithServer = NO;
  self.auth = nil;
  self.currentUser = nil;
  self.displayImage = nil;
}

/**
 * Delete session cookie so subsequent requests will require authentication.
 */
- (void)deleteSessionCookie {
  NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSURL *url = [NSURL URLWithString:kHPConstantsAppBaseURLString];
  NSArray *cookies = [cookieStorage cookiesForURL:url];
  for (NSHTTPCookie *cookie in cookies) {
    if ([[cookie name] isEqual:kHPConstantsSessionCookieName]) {
      [cookieStorage deleteCookie:cookie];
    }
  }
}

#pragma mark - Haiku+ API

/**
 * Fetch current user from Haiku+ API. Requires authenticated session.
 *
 * @param completion Block that takes a user object and an error which is nil on success.
 */
- (void)fetchCurrentUserWithCompletion:(HPUserCompletion)completion {
  NSMutableURLRequest *request = [_networkClient requestWithMethod:@"GET"
                                                              path:kHPConstantsUserPath
                                                        parameters:nil];
  if (!_auth) {
    completion(nil, [self authorizationError]);
    return;
  }
  [_auth authorizeRequest:request completionHandler:^(NSError *error) {
    if (error != nil) {
      completion(nil, error);
    } else {
      AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              HPUser *user = [[HPUser alloc] initWithAttributes:responseObject];
              completion(user, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(nil, error);
          }];
      [_networkClient enqueueHTTPRequestOperation:op];
    }
  }];
}

- (void)fetchHaikusFiltered:(BOOL)isFilteringByFriends
                 completion:(HPArrayCompletion)completion {
  NSString *path;
  if (isFilteringByFriends) {
    path = [NSString stringWithFormat:@"%@?filter=circles", kHPConstantsHaikusPath];
    NSMutableURLRequest *request = [_networkClient requestWithMethod:@"GET"
                                                                path:path
                                                          parameters:nil];
    if (!_auth) {
      completion(nil, [self authorizationError]);
      return;
    }
    [_auth authorizeRequest:request completionHandler:^(NSError *error) {
      if (error != nil) {
        completion(nil, error);
      } else {
        AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSArray *haikus = [HPHaiku haikuObjectsWithAttributes:responseObject];
                completion(haikus, nil);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                completion(nil, error);
            }];
        [_networkClient enqueueHTTPRequestOperation:op];
      }
    }];
  } else {
    path = kHPConstantsHaikusPath;
    NSMutableURLRequest *request = [_networkClient requestWithMethod:@"GET"
                                                                path:path
                                                          parameters:nil];
    AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *haikus = [HPHaiku haikuObjectsWithAttributes:responseObject];
            completion(haikus, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
    [_networkClient enqueueHTTPRequestOperation:op];
  }
}

- (void)signOutWithCompletion:(HPErrorCompletion)completion {
  NSMutableURLRequest *request = [_networkClient requestWithMethod:@"POST"
                                                              path:kHPConstantsSignoutPath
                                                        parameters:nil];
  AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          [self signOutDevice];
          if (completion) {
            completion(nil);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (completion) {
            completion(error);
          }
      }];
  [_networkClient enqueueHTTPRequestOperation:op];
}

- (void)disconnectWithCompletion:(HPErrorCompletion)completion {
  NSMutableURLRequest *request = [_networkClient requestWithMethod:@"POST"
                                                              path:kHPConstantsDisconnectPath
                                                        parameters:nil];
  if (!_auth) {
    completion([self authorizationError]);
    return;
  }
  [_auth authorizeRequest:request completionHandler:^(NSError *error) {
    if (error != nil) {
      completion(error);
    } else {
      AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self signOutDevice];
              completion(nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(error);
          }];
      [_networkClient enqueueHTTPRequestOperation:op];
    }
  }];
}

- (void)fetchHaikuWithID:(NSString *)haikuID
              completion:(HPHaikuCompletion)completion {
  NSString *path = [NSString stringWithFormat:kHPConstantsHaikuFormatPath, haikuID];
  NSMutableURLRequest *request = [_networkClient requestWithMethod:@"GET"
                                                              path:path
                                                        parameters:nil];
  AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          HPHaiku *haiku = [[HPHaiku alloc] initWithAttributes:responseObject];
          completion(haiku, nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          completion(nil, error);
      }];
  [_networkClient enqueueHTTPRequestOperation:op];
}

- (void)voteForHaikuWithID:(NSString *)haikuID
                completion:(HPErrorCompletion)completion {
  NSString *path = [NSString stringWithFormat:kHPConstantsHaikuVoteFormatPath, haikuID];
  NSMutableURLRequest *request = [_networkClient requestWithMethod:@"POST"
                                                              path:path
                                                        parameters:nil];
  if (!_auth) {
    completion([self authorizationError]);
    return;
  }
  [_auth authorizeRequest:request completionHandler:^(NSError *error) {
    if (error != nil) {
      completion(error);
    } else {
      AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              completion(nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(error);
          }];
      [_networkClient enqueueHTTPRequestOperation:op];
    }
  }];
}

- (void)createHaiku:(HPHaiku *)haiku
         completion:(HPHaikuCompletion)completion {
  NSDictionary *haikuAttributes = [haiku attributesDictionary];

  NSMutableURLRequest *request = [_networkClient requestWithMethod:@"POST"
                                                              path:kHPConstantsHaikusPath
                                                        parameters:haikuAttributes];
  if (!_auth) {
    completion(nil, [self authorizationError]);
    return;
  }
  [_auth authorizeRequest:request completionHandler:^(NSError *error) {
    if (error != nil) {
      completion(nil, error);
    } else {
      AFHTTPRequestOperation *op = [_networkClient HTTPRequestOperationWithRequest:request
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              HPHaiku *createdHaiku = [[HPHaiku alloc] initWithAttributes:responseObject];
              completion(createdHaiku, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(nil, error);
          }];
      [_networkClient enqueueHTTPRequestOperation:op];
    }
  }];
}

- (void)fetchImageWithURL:(NSURL *)url completion:(HPImageCompletion)completion {
  void (^success)(NSURLRequest *, NSHTTPURLResponse *, UIImage *);
  success = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
      completion(image, nil);
  };
  void (^failure)(NSURLRequest *, NSHTTPURLResponse *, NSError *);
  failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
      completion(nil, error);
  };

  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFImageRequestOperation *operation;
  operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                   imageProcessingBlock:nil
                                                                success:success
                                                                failure:failure];
  [operation start];
}

@end
