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

#undef EXTERN
#undef INITIALIZE_AS

#ifdef APP_DEFINE_CONSTANTS
#define EXTERN
#define INITIALIZE_AS(x) =x
#else
#define EXTERN extern
#define INITIALIZE_AS(x)
#endif

/**
 * Base URL for the Haiku+ API. The server at this URL must support the Haiku+ API interface.
 */
EXTERN NSString * const kHPConstantsAppBaseURLString INITIALIZE_AS(@"https://localhost");

/**
 * iOS Client ID from https://developers.google.com/console.
 */
EXTERN NSString * const kHPConstantsClientID INITIALIZE_AS(@"YOUR_CLIENT_ID");

/**
 * Session constants.
 */
EXTERN NSString * const kHPConstantsUserAgent INITIALIZE_AS(@"Haiku+Client-iOS");
EXTERN NSString * const kHPConstantsSessionCookieName INITIALIZE_AS(@"HaikuSessionId");

/**
 * NSDateFormatter pattern for dates in API fields.
 */
EXTERN NSString * const kHPConstantsAPIDateFormat INITIALIZE_AS(@"yyyy-MM-dd'T'HH:mm:ssZ");

/**
 * NSDateFormatter pattern for dates visible to the user.
 */
EXTERN NSString * const kHPConstantsVisibleDateFormat INITIALIZE_AS(@"YYYY-MM-dd");

/**
 * API path constants.
 */
EXTERN NSString * const kHPConstantsUserPath INITIALIZE_AS(@"/api/users/me");
EXTERN NSString * const kHPConstantsSignoutPath INITIALIZE_AS(@"/api/signout");
EXTERN NSString * const kHPConstantsDisconnectPath INITIALIZE_AS(@"/api/disconnect");
EXTERN NSString * const kHPConstantsHaikusPath INITIALIZE_AS(@"/api/haikus");
EXTERN NSString * const kHPConstantsHaikuFormatPath INITIALIZE_AS(@"/api/haikus/%@");
EXTERN NSString * const kHPConstantsHaikuVoteFormatPath INITIALIZE_AS(@"/api/haikus/%@/vote");
EXTERN NSInteger const kHPConstantsFilterEveryoneIndex INITIALIZE_AS(0);
EXTERN NSInteger const kHPConstantsFilterFriendsIndex INITIALIZE_AS(1);

/**
 * Error constants.
 */
EXTERN NSString * const kHPErrorDomain
    INITIALIZE_AS(@"com.google.plus.samples.HaikuPlus.HPErrorDomain");

enum {
  kHPErrorDomainUnauthorized
};

EXTERN CGFloat kHPConstantsKeyboardOffset INITIALIZE_AS(-50);
EXTERN CGFloat kHPConstantsTextFieldSpacing INITIALIZE_AS(67);
