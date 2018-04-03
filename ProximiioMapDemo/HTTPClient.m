//
//  HTTPClient.m
//  ProximiioMap
//
//  Created by Matej Drzik on 08/02/2018.
//  Copyright © 2018 Proximi.io. All rights reserved.
//

#import "HTTPClient.h"

@implementation HTTPClient

+(void)GET:(NSString *)url withToken:(NSString *)token onComplete:(void(^)(NSDictionary *jsonData))onComplete {
    @autoreleasepool {
        NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
        
        NSString *bearerToken = [NSString stringWithFormat:@"Bearer %@", token];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setValue:bearerToken forHTTPHeaderField:@"Authorization"];
        
        __block BOOL done = NO;
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"dataTask error: %@", error);
            }
            NSError *e;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
            dispatch_async(dispatch_get_main_queue(), ^{
                onComplete(json);
            });
            done = YES;
        }];
        
        [dataTask resume];
        
        while (!done) {
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runUntilDate:date];
        }
    }
}

@end
