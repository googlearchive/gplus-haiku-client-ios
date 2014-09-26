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

#import "MockHPCommunicator.h"

@implementation MockHPCommunicator {
  NSInteger _fetchHaikuFilteredCount;
  NSInteger _fetchHaikuNotFilteredCount;
  NSInteger _fetchUserCount;
  NSInteger _fetchImageCount;
  NSInteger _requestSignOutCount;
  NSInteger _requestDisconnectCount;
  NSInteger _requestSilentAuthCount;
  HPUser *_currentUserToReturn;
}

- (void)fetchHaikusFiltered:(BOOL)filterByFriends
                 completion:(void (^)(NSArray *, NSError *))completion {
  if (filterByFriends) {
    _fetchHaikuFilteredCount++;
  } else {
    _fetchHaikuNotFilteredCount++;
  }
  completion(nil, nil);
}

- (void)fetchCurrentUserWithCompletion:(void (^)(HPUser *, NSError *))completion {
  _fetchUserCount++;
  completion(nil, nil);
}

- (void)fetchImageWithURL:(NSURL *)url completion:(void (^)(UIImage *, NSError *))completion {
  _fetchImageCount++;
  completion(nil, nil);
}

- (void)signOutWithCompletion:(void (^)(NSError *))completion {
  _requestSignOutCount++;
  completion(nil);
}

- (void)disconnectWithCompletion:(void (^)(NSError *))completion {
  _requestDisconnectCount++;
  completion(nil);
}

- (void)trySilentSignIn {
  _requestSilentAuthCount++;
}

- (NSInteger)haikuFetchNotFilteredCount {
  return _fetchHaikuNotFilteredCount;
}

- (NSInteger)haikuFetchFilteredCount {
  return _fetchHaikuFilteredCount;
}

- (NSInteger)userFetchCount {
  return _fetchUserCount;
}

- (NSInteger)imageFetchCount {
  return _fetchImageCount;
}

- (NSInteger)signOutCount {
  return _requestSignOutCount;
}

- (NSInteger)disconnectCount {
  return _requestDisconnectCount;
}

- (NSInteger)silentAuthCount {
  return _requestSilentAuthCount;
}

- (void)setFakeCurrentUser:(HPUser *)user {
  _currentUserToReturn = user;
}

- (HPUser *)currentUser {
  return _currentUserToReturn;
}

@end
