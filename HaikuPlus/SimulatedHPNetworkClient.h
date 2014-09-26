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

#import "HPNetworkClient.h"

/*
 * This fake network simulates a simple Haiku+ API server. This class can replace HPNetworkClient
 * if you have not implemented a Haiku+ API server and want to try the app locally.
 */
@interface SimulatedHPNetworkClient : HPNetworkClient

/**
 * Shortening the method signatures of AFNetworking.
 */
typedef void (^AFSuccessBlock)(AFHTTPRequestOperation *, id);
typedef void (^AFFailureBlock)(AFHTTPRequestOperation *, NSError *);

@end

/**
 * Simulated error information.
 */
extern NSString *SimulatedHPNetworkClientErrorDomain;

enum {
  SimulatedHPNetworkClientErrorCode,
  SimulatedHPNetworkClientUserAgentErrorCode,
  SimulatedHPNetworkClientAuthorizationHeaderErrorCode
};
