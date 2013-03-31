//
//  TPNewspaperWrapperViewController.m
//  timeportal
//
//  Created by Tong Wang on 2/15/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "TPNewspaperWrapperViewController.h"
#import "TPNewspaperPdfViewController.h"
#import "CANewspaperApi.h"
#import <QuartzCore/QuartzCore.h>

@interface TPNewspaperWrapperViewController ()

@end

@implementation TPNewspaperWrapperViewController

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options newspaperEdition:(TPNewspaperEdition *)edition
{
    self = [super init];
    if (self) {
        // Custom initialization
        pageViewController = [[TPNewspaperPageViewController alloc] initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options newspaperEdition:edition];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    TPNewspaperEdition *edition = [pageViewController edition];
    
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    [pageViewController didMoveToParentViewController:self];
    self.view.gestureRecognizers = pageViewController.gestureRecognizers;
    
    //[pageControl setBackgroundColor:[UIColor darkGrayColor]];
    [pageControl setNumberOfPages:[edition pageCount]];
    [pageControl setCurrentPage:0];
    
    [newspaperTitle setText:[[edition newspaper] title]];
    
    // start first page
    UIViewController *firstPageVC = [pageViewController viewControllerAtPage:0];
    if (firstPageVC != nil) {
        NSArray *viewControllers = [NSArray arrayWithObject:firstPageVC];
    
        [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [self.view bringSubviewToFront:titleBar];
    [self.view bringSubviewToFront:footerBar];
    
    headerFooterHidden = YES;
    
    if (firstPageVC == nil) {
        // first page can't be loaded
        [self viewTapped:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    docController = nil;
}


- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];
    int footerBarHeight = 30;
    int titleBarHeight = 36;
    
    
    
    CGRect bounds = self.view.bounds;
    
    titleBar.frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, titleBarHeight);
    
    pageViewController.view.frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    
    footerBar.frame = CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - footerBarHeight, bounds.size.width, footerBarHeight);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)share:(id)sender
{
    // show action sheet to get users input
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open Cropped Image ...", @"Open Page PDF ...", @"Email Cropped Image", @"Email Page PDF", nil];
    
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self openScreenshot];
    } else if (buttonIndex == 1) {
        [self openPdf];
    } else if (buttonIndex == 2) {
        [self emailScreenshot];
    } else if (buttonIndex == 3) {
        [self emailPagePdf];
    }
}

//
// taking a screenshot
//
- (UIImage *)screenshot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(pageViewController.view.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(pageViewController.view.bounds.size);
    }
    [pageViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}



- (void) saveScreenshotToPhotos
{
    UIImageWriteToSavedPhotosAlbum([self screenshot], nil, nil, nil);
}

- (NSData *) pdfData
{
    UIViewController *currentVC = [[pageViewController viewControllers] objectAtIndex:0];
    if ([currentVC class] != [TPNewspaperPdfViewController class]) {
        return nil;
    }
    
    TPNewspaperPdfViewController *pdfVC = (TPNewspaperPdfViewController *)currentVC;
    TPNewspaperEdition *edition = [pdfVC edition];
    int pageNumber = [pdfVC pageNumber];
    
    return [CANewspaperApi pdfForNewspaperEdition:edition page:pageNumber];
}


- (void) openScreenshot
{
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *imageFileUrl = [[tmpDirURL URLByAppendingPathComponent:@"page"] URLByAppendingPathExtension:@"jpg"];
    
    NSData *imageData = UIImageJPEGRepresentation([self screenshot], 0.5);
    
    [imageData writeToFile:[imageFileUrl path] atomically:YES];
    
    docController = [UIDocumentInteractionController interactionControllerWithURL:imageFileUrl];
    docController.delegate = self;
    
    [docController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
}



- (void) openPdf
{
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *pdfFileUrl = [[tmpDirURL URLByAppendingPathComponent:@"page"] URLByAppendingPathExtension:@"pdf"];
    
    NSData *pdfData = [self pdfData];
    if (pdfData == nil) {
        return;
    }

    [pdfData writeToFile:[pdfFileUrl path] atomically:YES];
    
    docController = [UIDocumentInteractionController interactionControllerWithURL:pdfFileUrl];
    docController.delegate = self;
    
    [docController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (void) emailScreenshot
{
    UIViewController *currentVC = [[pageViewController viewControllers] objectAtIndex:0];
    if ([currentVC class] != [TPNewspaperPdfViewController class]) {
        return;
    }
    
    TPNewspaperPdfViewController *pdfVC = (TPNewspaperPdfViewController *)currentVC;
    TPNewspaperEdition *edition = [pdfVC edition];
    int pageNumber = [pdfVC pageNumber];
    
    NSData *imageData = UIImageJPEGRepresentation([self screenshot], 0.5);
    
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@-%@-%d.jpg",
                          [[edition newspaper] lccn], [edition dateIssued], pageNumber];
    
    NSString *pageUrl = [edition htmlUrlForPage:[pdfVC pageNumber]];
    
    [self emailEdition:edition page:pageNumber attachment:imageData mimeType:@"image/jpeg" fileName:fileName pagePdfUrl:pageUrl];
}

- (void) emailPagePdf
{
    UIViewController *currentVC = [[pageViewController viewControllers] objectAtIndex:0];
    if ([currentVC class] != [TPNewspaperPdfViewController class]) {
        return;
    }

    TPNewspaperPdfViewController *pdfVC = (TPNewspaperPdfViewController *)currentVC;
    TPNewspaperEdition *edition = [pdfVC edition];
    int pageNumber = [pdfVC pageNumber];
    
    NSData *pdfData = [self pdfData];
    if (pdfData == nil) {
        return;
    }
    
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@-%@-%d.pdf",
                          [[edition newspaper] lccn], [edition dateIssued], pageNumber];
    
    NSString *pageUrl = [edition htmlUrlForPage:[pdfVC pageNumber]];
    
    [self emailEdition:edition page:pageNumber attachment:pdfData mimeType:@"application/pdf" fileName:fileName pagePdfUrl:pageUrl];
}

- (void) emailEdition:(TPNewspaperEdition *)edition page:(int)pageNumber attachment:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)fileName pagePdfUrl:(NSString *)pageUrl
{
    // canSendMail could timed out, try up to 10 times
    BOOL canSendMail = NO;
    for (int i = 0; i < 8; i++) {
        canSendMail = [MFMailComposeViewController canSendMail];
        if (canSendMail) {
            break;
        }
    }
    if (canSendMail) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"A Message from Time Portal"];
        
        if ([[pageViewController viewControllers] count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"This newspaper page can't be loaded."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            return;
        }

        if (attachment) {
            [mailer addAttachmentData:attachment mimeType:mimeType fileName:fileName];
        }
                
        NSString *emailBody = [[NSString alloc] initWithFormat:@"Check out page %d of the %@ at %@.",
                               pageNumber + 1,
                               [edition description],
                               pageUrl];
        [mailer setMessageBody:emailBody isHTML:NO];
        
        // only for iPad
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }

}


//
// MFMailComposeController delegate
//
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)viewTapped:(id)sender {
    // toggle header/footer display
    if (headerFooterHidden) {
        [UIView animateWithDuration:0.3 animations:^() {
            titleBar.alpha = 0.8;
            footerBar.alpha = 0.8;
        }];
        headerFooterHidden = NO;
    } else {
        [UIView animateWithDuration:0.3 animations:^() {
            titleBar.alpha = 0;
            footerBar.alpha = 0;
        }];
        headerFooterHidden = YES;
        
    }
}

- (void)updatePageControl
{
    UIViewController *currentVC = [[pageViewController viewControllers] objectAtIndex:0];
    
    if ([currentVC class] == [TPNewspaperPdfViewController class]) {
        NSUInteger pageNumber = [(TPNewspaperPdfViewController *)currentVC pageNumber];
        [pageControl setCurrentPage:pageNumber];
    }
}


@end
