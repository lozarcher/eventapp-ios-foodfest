//
//  Event.h
//  Surbiton Food Festival
//
//  Created by Loz on 12/02/2015.
//  Copyright (c) 2015 Spirit of Seething. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"

@interface Event : NSObject
@property (strong, nonatomic) NSString *id;
@property int *ordinal;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *coverUrl;
@property (strong, nonatomic) NSString *coverOffsetX;
@property (strong, nonatomic) NSString *coverOffsetY;
@property (strong, nonatomic) NSString *profileUrl;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *ticketUrl;
@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) Venue *venue;
@property BOOL isFavourite;
@end
