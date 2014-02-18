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

#import <GooglePlus/GooglePlus.h>

@class HPHaiku;
@class HPNetworkClient;
@class HPUser;

/**
 * Completion block for fetching an array of haikus from the Haiku+ server.
 *
 * @param haikus Array of haiku objects which is nil when an error occurs.
 * @param error Error from the server which is nil on success.
 */
typedef void (^HPArrayCompletion)(NSArray *haikus, NSError *error);

/**
 * Completion block for fetching a haiku from the Haiku+ server.
 *
 * @param haiku Haiku object which is nil when an error occurs.
 * @param error Error from the server which is nil on success.
 */
typedef void (^HPHaikuCompletion)(HPHaiku *haiku, NSError *error);

/**
 * Completion block for fetching an image.
 *
 * @param image Image object which is nil when an error occurs.
 * @param error Error from the server which is nil on success.
 */
typedef void (^HPImageCompletion)(UIImage *image, NSError *error);

/**
 * Completion block for fetching user data from the Haiku+ server.
 *
 * @param user User object which is nil when an error occurs.
 * @param error Error from the server which is nil on success.
 */
typedef void (^HPUserCompletion)(HPUser *user, NSError *error);

/**
 * Completion block a request to the Haiku+ server.
 * This is used for requests that do not return data, such as sign-out and disconnect.
 *
 * @param error Error from the server which is nil on success.
 */
typedef void (^HPErrorCompletion)(NSError *error);

@protocol HPCommunicatorDelegate <NSObject>

/**
 * Informs the delegate about changes to a user's Haiku+ sign-in state.
 * This could be called after the Google+ Sign-In library determines that a user has signed in,
 * or this could be called after an API call fails with the server, indicating that the user's
 * session is no longer valid.
 *
 * @param error Error that occurred during update, or nil.
 */
- (void)didUpdateSignInWithError:(NSError *)error;

/**
 * The user's profile image requires a separate network call from sign-in. The HPCommunicator
 * class will fetch the profile image automatically, and inform the delegate through this method
 * when the image is ready to be retrieved.
 */
- (void)didFinishFetchingDisplayImage;

@end

/**
 * The communicator implements the Haiku+ API for the iOS client.
 * Authentication is managed by this class. Other classes use the methods in this class to
 * authenticate users and make all Haiku+ API calls.
 */
@interface HPCommunicator : NSObject<GPPSignInDelegate>

/**
 * The HPNetworkClient makes network calls to the Haiku+ server.
 */
@property(strong, nonatomic) HPNetworkClient *networkClient;

/**
 * Google+ Sign-In object.
 */
@property(strong, nonatomic) GPPSignIn *gppSignIn;

/**
 * Standard object provided by Google for holding OAuth 2.0 information.
 */
@property(strong, nonatomic) GTMOAuth2Authentication *auth;

/**
 * Delegate that can receive updates about the sign-in state of the user.
 */
@property(weak, nonatomic) id<HPCommunicatorDelegate> delegate;

/**
 * Sign-in properties.
 */
@property(nonatomic, getter=isSignedInWithServer) BOOL signedInWithServer;
@property(strong, nonatomic) HPUser *currentUser;
@property(strong, nonatomic) UIImage *displayImage;

#pragma mark - Sign-in

/**
 * Pops a sign-in dialog, if necessary, to authenticate the user.
 */
- (void)signIn;

#pragma mark - Haiku+ API

/**
 * Fetches a list of haikus from the server. Filtering by friends requires authentication.
 *
 * @param isFilteringByFriends Specify which haikus to return.
 * @param completion Block that takes an array of haikus and an error which is nil on success.
 */
- (void)fetchHaikusFiltered:(BOOL)isFilteringByFriends completion:(HPArrayCompletion)completion;

/**
 * Tell the server that the user should be signed out.
 *
 * @param completion Block that takes an error which is nil on success.
 */
- (void)signOutWithCompletion:(HPErrorCompletion)completion;

/**
 * Tell the server to disconnect the user. Requires authentication.
 *
 * @param completion Block that takes an error which is nil on success.
 */
- (void)disconnectWithCompletion:(HPErrorCompletion)completion;

/**
 * Fetch a single haiku based on the ID.
 *
 * @param haikuID The ID of the haiku to fetch.
 * @param completion Block that takes a haiku and an error which is nil on success.
 */
- (void)fetchHaikuWithID:(NSString *)haikuID completion:(HPHaikuCompletion)completion;

/**
 * Vote for a single haiku based on ID. Requires authentication.
 *
 * @param haikuID The ID of the haiku to fetch.
 * @param completion Block that takes an error which is nil on success.
 */
- (void)voteForHaikuWithID:(NSString *)haikuID completion:(HPErrorCompletion)completion;

/**
 * Tell the server to create a new haiku. Requires authentication.
 *
 * @param haiku The haiku object that should be uploaded to the server.
 * @param completion Block that takes a haiku and an error which is nil on success.
 */
- (void)createHaiku:(HPHaiku *)haiku completion:(HPHaikuCompletion)completion;

/**
 * Fetch an image from a URL. This utility method asynchronously fetches an image and returns
 * it in the main execution queue.
 *
 * @param url The URL of an image.
 * @param completion Block that takes an image and an error which is nil on success.
 */
- (void)fetchImageWithURL:(NSURL *)url completion:(HPImageCompletion)completion;

@end
