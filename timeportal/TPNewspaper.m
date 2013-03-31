//
//  TPNewspaper.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPNewspaper.h"

@implementation TPNewspaper

@synthesize lccn, title, states, numberOfIssues, firstIssueYear, lastIssueYear;


-(id)initWithLccn:(NSString *)aLccn title:(NSString *)aTitle state:(NSString *)aState
{
    self = [super init];
    if (self) {
        lccn = aLccn;
        title = aTitle;
        states = [[NSMutableArray alloc] init];
        [states addObject:aState];
    }
    return self;
}

-(id)initWithLccn:(NSString *)aLccn title:(NSString *)aTitle state:(NSString *)aState numberOfIssues:(int)noIssues firstIssueYear:(int)firstYear lastIssueYear:(int)lastYear
{
    self = [self initWithLccn:aLccn title:aTitle state:aState];
    if (self) {
        numberOfIssues = noIssues;
        firstIssueYear = firstYear;
        lastIssueYear = lastYear;
    }
    return self;
}

- (void)addState:(NSString *)state
{
    [states addObject:state];
}

- (NSString *)detailText
{
    NSString *firstYearString = @"?";
    if (firstIssueYear != 0) {
        firstYearString = [[NSString alloc] initWithFormat:@"%d", firstIssueYear];
    }
    
    NSString *lastYearString = @"?";
    if (lastIssueYear != 0) {
        lastYearString = [[NSString alloc] initWithFormat:@"%d", lastIssueYear];
    }
    
    if (firstIssueYear != 0 || lastIssueYear != 0) {
        return [[NSString alloc] initWithFormat:@"%@ (%@ - %@)", [states componentsJoinedByString:@", "], firstYearString, lastYearString];
    } else {
        return [[NSString alloc] initWithFormat:@"%@", [states componentsJoinedByString:@", "]];
    }
}

//
// equality is based on lccn
//
- (BOOL)isEqual:(id)anObject
{
    if (anObject == self)
        return YES;
    if (!anObject || ![anObject isKindOfClass:[self class]])
        return NO;
    return [[self lccn] isEqual:[(TPNewspaper *)anObject lccn]];
}

- (NSString *)description
{
    return title;
}


@end
