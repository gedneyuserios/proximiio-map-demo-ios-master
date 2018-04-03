//
//  HTTPClient.h
//  ProximiioMap
//
//  Created by Matej Drzik on 08/02/2018.
//  Copyright © 2018 Proximi.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPClient : NSObject

+(void)GET:(NSString *)url withToken:(NSString *)token onComplete:(void(^)(NSDictionary *jsonData))onComplete;

@end
