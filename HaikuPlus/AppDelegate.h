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

#import <GooglePlus/GooglePlus.h>

@class HPCommunicator;
@class HPFloatingUI;

/**
 * This class to prepare the application to communicate with the Haiku+ API as well as prepare the
 * GPPSignIn object to handle authentication.
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate, GPPDeepLinkDelegate>

@property(strong, nonatomic) UIWindow *window;

/**
 * The communicator implements the Haiku+ API for the iOS client.
 * HPCommunicator uses an HPNetworkClient to make network calls to the Haiku+ server.
 */
@property(strong, nonatomic) HPCommunicator *communicator;

/**
 * This class shows UI to the user when actions take place.
 */
@property(strong, nonatomic) HPFloatingUI *floatingUI;

@end
