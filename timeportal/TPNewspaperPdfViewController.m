//
//  TPNewspaperPdfViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/10/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPNewspaperPdfViewController.h"

#import "PDFScrollView.h"
#import "CANewspaperApi.h"

@interface TPNewspaperPdfViewController ()

@end

@implementation TPNewspaperPdfViewController

@synthesize edition, pageNumber;

- (id)initWithEdition:(TPNewspaperEdition *)theEdition pageNumber:(int)thePageNumber
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.edition = theEdition;
        self.pageNumber = thePageNumber;
        
        pdfData = [CANewspaperApi pdfForNewspaperEdition:edition page:pageNumber];
        
        self.pdfLoaded = !(pdfData == nil || [pdfData length] == 0);
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /*
     Open the PDF document, extract the first page, and pass the page to the PDF scroll view.
     */
    CFDataRef pdfDataRef = (__bridge CFDataRef)pdfData;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(pdfDataRef);
    CGPDFDocumentRef PDFDocument = CGPDFDocumentCreateWithProvider(provider);
    
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, 1);
    
    // make pdf to fill the frame
    [self.view setFrame:[[[self parentViewController] view ] frame]];
    
    [(PDFScrollView *)self.view setPDFPage:PDFPage];
    
    CGPDFDocumentRelease(PDFDocument);
    pdfData = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
