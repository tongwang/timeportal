//
//  TPConfiguration.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPConfiguration.h"
#import "CANewspaperApi.h"

@implementation TPConfiguration

@synthesize preferredState;


//
// Singleton implementation
//

+ (TPConfiguration *)instance
{
    static TPConfiguration *instance = nil;
    
    if (!instance) {
        instance = [NSKeyedUnarchiver unarchiveObjectWithFile:[TPConfiguration archivePath]];
        if (!instance) {
            instance = [[TPConfiguration alloc] init];
        }
    }
    return instance;
}

//
// init a default config
//
- (id)init
{
    self = [super init];
    if (self) {
        lccns = [[NSMutableArray alloc] init];
        // default: some popular newspapers
        // sn83030214 New-York tribune. 1866 - 1922
        // sn83030193 The evening world. 1887 - 1922
        // sn83030272 The sun. 1859 - 1916
        // sn85058130 The Salt Lake herald. 1880 - 1909
        // sn98060050 Vermont phoenix. 1836 - 1922
        // sn83030213 New-York daily tribune. 1842 - 1866
        // sn84026749 The Washington times. 1902 - 1922
        [lccns addObject:@"sn83030214"];
        [lccns addObject:@"sn83030193"];
        [lccns addObject:@"sn83030272"];
        [lccns addObject:@"sn85058130"];
        [lccns addObject:@"sn98060050"];
        [lccns addObject:@"sn83030213"];
        [lccns addObject:@"sn84026749"];
        
        // hundred years from now
        NSCalendar *calendar = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
        [comps setYear:[comps year] - 100];
        NSDate *hundredYearsFromNow = [calendar dateFromComponents:comps];
        
        dayInterval = [self dayIntervalSinceNow:hundredYearsFromNow];
        preferredState = @"All";
    }
    
    return self;
}


//
// Persistence
//

// construct archive path of the store, which is Document/units.archive
+ (NSString *)archivePath
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"config.archive"];
}

//
// Save the store into file archive
//
- (BOOL)save
{
    NSLog(@"Saving configuration");
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:[TPConfiguration archivePath]];
}



//
// NSCoder methods
//
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:lccns forKey:@"lccns"];
    [aCoder encodeInt:dayInterval forKey:@"dayInterval"];
    [aCoder encodeObject:preferredState forKey:@"preferredState"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        lccns = [aDecoder decodeObjectForKey:@"lccns"];
        dayInterval = [aDecoder decodeIntForKey:@"dayInterval"];
        preferredState = [aDecoder decodeObjectForKey:@"preferredState"];
    }
    return self;
}

//
// accessors and mutators
//
- (NSArray *)lccns
{
    return lccns;
}

- (void)addNewspaper:(NSString *)lccn
{
    // do not add the same newspaper twice
    if ([lccns indexOfObject:lccn] == NSNotFound) {
        [lccns addObject:lccn];
    }
    [self save];
}

- (void)deleteNewspaperAtIndex:(int)index
{
    [lccns removeObjectAtIndex:index];
    [self save];
}

- (void)moveNewspaperAtIndex:(int)from
                     toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved so we can re-insert it
    NSString *p = [lccns objectAtIndex:from];
    
    // Remove p from array
    [lccns removeObjectAtIndex:from];
    
    // Insert p in array at new location
    [lccns insertObject:p atIndex:to];
    
    [self save];
}


// return the date in the time portal, based on the current date and dayInterval
- (NSDate *)portalDate
{
    double interval = (double)dayInterval * 60 * 60 * 24;
    return [NSDate dateWithTimeIntervalSinceNow:interval];
}

- (NSDateComponents *)portalDateComponent
{
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[self portalDate]];
}

- (void)setPortalDate:(NSDate *)portalDate
{
    dayInterval = [self dayIntervalSinceNow:portalDate];
    [self save];
}

- (int)dayIntervalSinceNow:(NSDate *)aDate
{
    //GET # OF DAYS
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd MM yyyy"];       //Remove the time part
    NSString *todayString = [df stringFromDate:[NSDate date]];
    NSString *aDateString = [df stringFromDate:aDate];
    NSTimeInterval time = [[df dateFromString:aDateString] timeIntervalSinceDate:[df dateFromString:todayString]];
    return time / 60 / 60/ 24;
}

- (void)setPreferredState:(NSString *)state
{
    preferredState = state;
    [self save];
}

@end
