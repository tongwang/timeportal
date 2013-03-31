//
//  TPNewspaperPdfViewController.h
//  timeportal
//
//  Created by Tong Wang on 2/10/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPNewspaperEdition.h"

@interface TPNewspaperPdfViewController : UIViewController
{
    NSData *pdfData;
}

- (id)initWithEdition:(TPNewspaperEdition *)edition pageNumber:(int)pageNumber;

@property (nonatomic, weak) TPNewspaperEdition *edition;
@property (nonatomic) int pageNumber;
@property (nonatomic) BOOL pdfLoaded;

@end
