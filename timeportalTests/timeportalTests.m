//
//  timeportalTests.m
//  timeportalTests
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "timeportalTests.h"
#import "CANewspaperApi.h"
#import "TPNewspaper.h"
#import "TPNewspaperEdition.h"

@implementation timeportalTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testGetNewspaperForState
{
    NSArray *texasNewspapers = [CANewspaperApi newspapersForState:@"Texas" year:1902];
    STAssertTrue([texasNewspapers count] > 10, @"wrong number of newspapers for Texas");
    for (TPNewspaper *newspaper in texasNewspapers) {
        STAssertNotNil([newspaper lccn], @"lccn is nil");
        STAssertNotNil([newspaper title], @"title is nil");
    }
}

- (void)testGetNewspaperEdition
{
    TPNewspaperEdition *edition = [CANewspaperApi newspaperEdition:@"sn86069873" year:1900 month:1 day:5];
    STAssertEqualObjects(@"1900-01-05", [edition dateIssued], @"date issued incorrect");
    STAssertTrue([edition pageCount] == 8, @"wrong number of pages");
    STAssertEqualObjects([edition urlForPage:0], @"http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1.json", @"wrong url for age");

}

- (void)testGetNewspaperEditionNotFound
{
    TPNewspaperEdition *edition = [CANewspaperApi newspaperEdition:@"sn86069873" year:1999 month:1 day:5];
    STAssertNil(edition, @"should return nil for not found edition");
}

- (void)testGetPage
{
    TPNewspaperEdition *edition = [CANewspaperApi newspaperEdition:@"sn86069873" year:1900 month:1 day:5];
    NSData *pdf = [CANewspaperApi pdfForNewspaperEdition:edition page:2];
    STAssertNotNil(pdf, @"PDF is empty");
}

@end
