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

// If you cannot run a Haiku+ server, you can use the simulated network class in order
// to explore this application.
#define HP_USE_SIMULATED_SERVER 0

#import "AppDelegate.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

#import "HomeViewController.h"
#import "HPCommunicator.h"
#import "HPConstants.h"
#import "HPFloatingUI.h"
#import "SimulatedHPNetworkClient.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // kHPConstantsAppBaseURLString is defined in HPConstants.h and must reference the URL
  // of a Haiku+ server.
  NSURL *baseURL = [NSURL URLWithString:kHPConstantsAppBaseURLString];
  // If you cannot run a Haiku+ server, you can use the simulated network class in order to
  // explore this application.
#if HP_USE_SIMULATED_SERVER
  HPNetworkClient *network = [[SimulatedHPNetworkClient alloc] initWithBaseURL:baseURL];
#else
  HPNetworkClient *network = [[HPNetworkClient alloc] initWithBaseURL:baseURL];
#endif

  // Register delegate for handling deep links into app.
  [GPPDeepLink setDelegate:self];
  [GPPDeepLink readDeepLinkAfterInstall];

  // The sign-in object handles authentication and authorization.
  GPPSignIn *gppSignIn = [GPPSignIn sharedInstance];
  gppSignIn.clientID = kHPConstantsClientID;
  gppSignIn.scopes = @[ kGTLAuthScopePlusLogin ];
  gppSignIn.actions = @[
    @"http://schemas.google.com/AddActivity",
    @"http://schemas.google.com/ReviewActivity"
  ];

  // The communicator handles all communication with the Haiku+ API, including sign-in.
  _communicator = [[HPCommunicator alloc] init];
  _communicator.networkClient = network;
  _communicator.gppSignIn = gppSignIn;
  gppSignIn.delegate = _communicator;
  [gppSignIn trySilentAuthentication];

  // This class shows UI to the user when actions take place.
  _floatingUI = [[HPFloatingUI alloc] init];

  // Storyboard prepares view controllers, so we don't have to do anything else.
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  return [GPPURLHandler handleURL:url
                sourceApplication:sourceApplication
                       annotation:annotation];
}

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
  // Handle incoming deep link.
  // Example: @"/haikus/HAIKUID?action=vote"
  NSString *deepLinkString = [deepLink deepLinkID];
  NSDictionary *haikuDeepLinkDictionary = [self haikuDeepLinkDictionaryFromString:deepLinkString];
  NSString *haikuID = [haikuDeepLinkDictionary objectForKey:@"haikuID"];
  NSString *action = [haikuDeepLinkDictionary objectForKey:@"action"];
  BOOL voting = [action isEqual:@"vote"];

  NSLog(@"Deep Link ID: %@", deepLinkString);
  NSLog(@"Haiku ID: %@", haikuID);
  NSLog(@"Voting %@", voting ? @"YES" : @"NO");

  // Navigate to haiku view with |haikuID| and vote if |voting|.
  UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
  HomeViewController *hvc = [navController.viewControllers objectAtIndex:0];

  [navController popToRootViewControllerAnimated:NO];

  [hvc overrideSelectedHaikuIDOnce:haikuID];
  if (voting) {
    [hvc voteAfterHaikuSegueOnce];
  }
  [hvc performSegueWithIdentifier:@"showHaikuSegue" sender:self];
}

/**
 * Custom parser for Haiku+ deep link.
 *
 * @"/haikus/{haikuID}?action=vote"
 *
 * @param deepLinkString Deep link from a Google+ share
 */
- (NSDictionary *)haikuDeepLinkDictionaryFromString:(NSString *)deepLinkString {
  NSArray *deepLinkComponents = [deepLinkString componentsSeparatedByString:@"?"];
  if ([deepLinkComponents count] == 0) {
    return nil;
  }
  NSMutableDictionary *pieces = [[NSMutableDictionary alloc] init];
  NSString *path = [deepLinkComponents firstObject];
  NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
  NSString *resource = [pathComponents objectAtIndex:1];
  if ([resource isEqual:@"haikus"]) {
    // @"/haikus" matches.
    NSString *haikuID = [pathComponents objectAtIndex:2];
    [pieces setObject:haikuID forKey:@"haikuID"];
    if ([deepLinkComponents count] > 1) {
      // Test for query parameters.
      NSString *parameters = [deepLinkComponents objectAtIndex:1];
      NSArray *queryComponents = [parameters componentsSeparatedByString:@"&"];
      for (NSString *query in queryComponents) {
        NSArray *keyValue = [query componentsSeparatedByString:@"="];
        [pieces setObject:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
      }
    }
  } else {
    return nil;
  }
  return pieces;
}

@end
