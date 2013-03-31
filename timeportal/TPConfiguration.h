//
//  TPConfiguration.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPConfiguration : NSObject <NSCoding>
{
    NSMutableArray *lccns;
    
    // this is the number of days since now, for example: -33278
    int dayInterval;
}


@property (nonatomic, strong) NSString *preferredState;

// Singleton factory method
+ (TPConfiguration *)instance;

//
// NSCoder methods
//
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

//
// accessors and mutators
//
- (NSArray *)lccns;

- (void)addNewspaper:(NSString *)lccn;

- (void)deleteNewspaperAtIndex:(int)index;

- (void)moveNewspaperAtIndex:(int)from
                     toIndex:(int)to;


// return the date in the time portal, based on the current date and dayInterval
- (NSDate *)portalDate;

- (NSDateComponents *)portalDateComponent;

- (void)setPortalDate:(NSDate *)portalDate;

- (void)setPreferredState:(NSString *)preferredState;

- (BOOL)save;

@end
