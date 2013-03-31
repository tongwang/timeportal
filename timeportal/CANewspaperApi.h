//
//  CANewspaperApi.h
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPNewspaperEdition.h"
#import "TPNewspaper.h"

@interface CANewspaperApi : NSObject

+ (NSArray *)newspapers;

+ (NSArray *)newspapersForState:(NSString *)state year:(int)year;

+ (TPNewspaperEdition *)newspaperEdition:(NSString *)lccn year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;

+ (NSData *)pdfForNewspaperEdition:(TPNewspaperEdition *)edition page:(NSUInteger)pageNumber;

+ (UIImage *)thumbnailForNewspaperEdition:(TPNewspaperEdition *)edition page:(NSUInteger)pageNumber;

+ (TPNewspaper *)newspaperOfLccn:(NSString *)lccn;

+ (BOOL)newspapersLoaded;

@end
