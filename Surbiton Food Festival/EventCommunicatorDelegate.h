//
//  EventCommunicatorDelegate.h
//  Surbiton Food Festival
//
//  Created by Loz on 12/02/2015.
//  Copyright (c) 2015 Spirit of Seething. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventCommunicatorDelegate <NSObject>
-(void)receivedEventsJSON:(NSData *)objectNotation;
-(void)fetchingEventsFailedWithError:(NSError *)error;
@end
