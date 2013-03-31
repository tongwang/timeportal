//
//  TPNewspaperEdition.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPNewspaperEdition.h"
#import "TPConfiguration.h"

@implementation TPNewspaperEdition

@synthesize newspaper, dateIssued;

- (id)init
{
    self = [super init];
    if (self) {
        pageUrls = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (NSString *)urlForPage: (NSUInteger)pageNum
{
    return [pageUrls objectAtIndex:pageNum];
}

- (NSString *)htmlUrlForPage: (NSUInteger)pageNum
{
    NSMutableString *url = [[NSMutableString alloc] initWithString:[self urlForPage:pageNum]];
    // replace json with html
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @".json$" options:0 error:nil];
    [regex replaceMatchesInString:url options:0 range:NSMakeRange(0, [url length]) withTemplate:@"/"];
    return url;
}

- (NSUInteger)pageCount
{
    return [pageUrls count];
}

- (void)addPageUrl:(NSString *)url
{
    [pageUrls addObject:url];
}

- (void)setThumbnail:(UIImage *)image
{
    // crop image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // Get size of current image
    CGSize size = [image size];
    
    // Frame location in view to show original image
    [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // Create rectangle that represents a cropped image
    // from the middle of the existing image
    CGRect rect;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // iphone 120 x 120
        rect = CGRectMake(size.width / 2 - 60, 0 ,
                                 120, 120);
    } else {
        // iphone 100 x 100
        rect = CGRectMake(size.width / 2 - 50, 0 ,
                                 100, 100);
    }
    
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    _thumbnail = img;
}


//
// compare order of two newspaper edition based the order in the configuration
//
- (NSComparisonResult)compare:(TPNewspaperEdition *)otherEdition
{
    TPNewspaper *thisNewspaper = [self newspaper];
    TPNewspaper *otherNewspaper = [otherEdition newspaper];
    
    NSUInteger thisIndex = [[[TPConfiguration instance] lccns] indexOfObject:[thisNewspaper lccn]];
    NSUInteger otherIndex = [[[TPConfiguration instance] lccns] indexOfObject:[otherNewspaper lccn]];
    
    if (thisIndex == otherIndex) {
        return NSOrderedSame;
    } else if (thisIndex < otherIndex) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@ issue of %@", dateIssued, [newspaper description]];
}

@end
