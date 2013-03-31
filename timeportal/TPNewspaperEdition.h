//
//  TPNewspaperEdition.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPNewspaper.h"

@interface TPNewspaperEdition : NSObject
{
    NSMutableArray *pageUrls;
}

@property (nonatomic, weak) TPNewspaper *newspaper;
@property (nonatomic) NSString *dateIssued;
@property (nonatomic) UIImage *thumbnail;

- (NSString *)urlForPage: (NSUInteger)pageNum;
- (NSString *)htmlUrlForPage: (NSUInteger)pageNum;

- (NSUInteger)pageCount;

- (void)addPageUrl:(NSString *)url;

- (NSComparisonResult)compare:(TPNewspaperEdition *)otherEdition;

- (NSString *)description;
@end
