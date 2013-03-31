//
//  TPNewspaperPageViewController.h
//  timeportal
//
//  Created by Tong Wang on 2/10/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPNewspaperEdition.h"
#import "TPNewspaperPdfViewController.h"

@interface TPNewspaperPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, weak) TPNewspaperEdition *edition;

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options newspaperEdition:(TPNewspaperEdition *)edition;

- (TPNewspaperPdfViewController *)viewControllerAtPage:(int) pageNumber;
@end
