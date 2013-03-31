//
//  TPNewspaper.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPNewspaper : NSObject

@property (nonatomic, strong) NSString *lccn;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *states;
@property (nonatomic) int numberOfIssues;
@property (nonatomic) int firstIssueYear;
@property (nonatomic) int lastIssueYear;


- (id)initWithLccn:(NSString *)aLccn title:(NSString *)aTitle state:(NSString *)aState;

- (id)initWithLccn:(NSString *)aLccn title:(NSString *)aTitle state:(NSString *)aState numberOfIssues:(int)noIssues firstIssueYear:(int)firstYear lastIssueYear:(int)lastYear;

- (void)addState:(NSString *)state;

- (NSString *)detailText;

- (NSString *)description;

@end
