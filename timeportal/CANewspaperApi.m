//
//  CANewspaperApi.m
//  timeportal
//
//  Created by Tong Wang on 2/9/13.
//  Copyright (c) 2013 Tong Wang. All rights reserved.
//

#import "CANewspaperApi.h"

#import "TPNewspaper.h"

@implementation CANewspaperApi

static NSCache *editionCache = nil;
static NSCache *pdfCache = nil;

static NSMutableArray *newspapers = nil;
static NSMutableDictionary *newspapersDict = nil;

+ (void)setupCaches
{
    if (editionCache == nil) {
        editionCache = [[NSCache alloc] init];
        [editionCache setCountLimit:100];
    }
    
    if (pdfCache == nil) {
        pdfCache = [[NSCache alloc] init];
        // only cache up to 16 pdf pages 
        [pdfCache setCountLimit:16];
    }
    
    // register for memory warning notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

+ (NSData *)responseDataOfUrl:(NSString *)url error:(NSError **)error
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:url]];
    
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    if ([response statusCode] != 200) {
        if ([response statusCode] == 404) {
        }
        return nil;
    } else {
        return responseData;
    }
}

+ (NSString *)responseOfUrl:(NSString *)url error:(NSError **)error
{
    NSData *data = [self responseDataOfUrl:url error:error];
    if (data != nil) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}


+ (TPNewspaper *)newspaperOfLccn:(NSString *)lccn
{
    return [newspapersDict objectForKey:lccn];
}


+ (NSArray *)newspapersForState:(NSString *)state year:(int)year
{
    NSMutableArray *newspapersForState = [[NSMutableArray alloc] init];
    NSArray *newspapers = [self newspapers];
    for (TPNewspaper* newspaper in newspapers) {
        if (([[newspaper states] containsObject:state] || [state isEqualToString:@"All"])
            && ([newspaper firstIssueYear] == 0 || year >= [newspaper firstIssueYear])
            && ([newspaper lastIssueYear] == 0 || year <= [newspaper lastIssueYear])) {
            [newspapersForState addObject:newspaper];
        }
    }
    return newspapersForState;

}

+ (BOOL)newspapersLoaded
{
    @synchronized(newspapers) {
        return !(newspapers == nil || [newspapers count] == 0 );
    }
}


+ (NSArray *)newspapers
{
    @synchronized(newspapers) {
        if (newspapers == nil || [newspapers count] == 0 ) {
            newspapers = [[NSMutableArray alloc] init];
            newspapersDict = [[NSMutableDictionary alloc] init];
            
            NSError *error;
            NSData *newspaperJson = [self responseDataOfUrl:@"http://chroniclingamerica.loc.gov/newspapers.json" error:&error];
            
            // parse json
            if (newspaperJson == nil || error != nil || [newspaperJson length] == 0) {
                // failed
                return newspapers;
            }
            
            NSDictionary *newspaperJsonDict = [NSJSONSerialization JSONObjectWithData:newspaperJson options: NSJSONReadingMutableContainers error: &error];
            
            /*
             response is something like:
             
             {
             "newspapers": [
             {
             "lccn": "sn83045160",
             "url": "http://chroniclingamerica.loc.gov/lccn/sn83045160.json",
             "state": "Alabama",
             "title: ": "Memphis daily appeal."
             },
             ...
             ]
             }
             
             */
            for (NSDictionary* newspaper in [newspaperJsonDict objectForKey:@"newspapers"]) {
                NSString *lccn = [newspaper objectForKey:@"lccn"];
                NSString *title = [newspaper objectForKey:@"title"];
                NSString *state = [newspaper objectForKey:@"state"];
                
                // look up the newspaper
                TPNewspaper *newspaper = [newspapersDict objectForKey:lccn];
                if (newspaper == nil) {
                    // not in the dict, first time seen this newspaper
                    newspaper = [[TPNewspaper alloc] initWithLccn:lccn title:title state:state];
                    [newspapersDict setObject:newspaper forKey:[newspaper lccn]];
                    [newspapers addObject:newspaper];
                } else {
                    // already in dict
                    [newspaper addState:state];
                }
            }
            
            // load full information async, becasue it is slow
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self loadFullNewspapers];
            });

        }
        return newspapers;
    }
}

//
// using http://chroniclingamerica.loc.gov/newspapers.txt to get full information
//
+ (void)loadFullNewspapers
{
    NSError *error;
    NSString *newspapersText = [self responseOfUrl:@"http://chroniclingamerica.loc.gov/newspapers.txt" error:&error];
    NSArray *lines = [newspapersText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    // format: Persistent Link | State | Title | LCCN | OCLC | ISSN | No. of Issues | First Issue Date | Last Issue Date | More Info
    // example http://chroniclingamerica.loc.gov/lccn/sn83045160/issues/ | Alabama | Memphis daily appeal. (Memphis, Tenn.) 1847-1886 | sn83045160 | 9355541 | 2166-1898 | 5447 | Jan. 1, 1857 | Dec. 31, 1876 | http://chroniclingamerica.loc.gov/lccn/sn83045160/essays/
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"^.*\\|(.*)\\|(.*)\\|(.*)\\|.*\\|.*\\|(.*)\\|(.*)\\|(.*)\\|.*$" options:0 error:nil];
    
    int lineNumber = 0;
    for (NSString *line in lines) {
        lineNumber++;
        if (lineNumber == 1) {
            // first line is the heading
            NSTextCheckingResult *matchResult = [regex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
            if ([matchResult range].location == NSNotFound
                || [matchResult range].length == 0) {
                NSLog(@"Unexpected header from newspapers text api");
                return;
            }
            if (![[self stringFromMatchResult:matchResult index:0 string:line] isEqualToString:@"State"]
                || ![[self stringFromMatchResult:matchResult index:1 string:line] isEqualToString:@"Title"]
                || ![[self stringFromMatchResult:matchResult index:2 string:line] isEqualToString:@"LCCN"]
                || ![[self stringFromMatchResult:matchResult index:3 string:line] isEqualToString:@"No. of Issues"]
                || ![[self stringFromMatchResult:matchResult index:4 string:line] isEqualToString:@"First Issue Date"]
                || ![[self stringFromMatchResult:matchResult index:5 string:line] isEqualToString:@"Last Issue Date"]) {
                // unexpected headers
                NSLog(@"Unexpected header from newspapers text api");
                return;
            }
            continue;
        }
        
        // process newspaper
        NSTextCheckingResult *matchResult = [regex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
        if ([matchResult range].location == NSNotFound
            || [matchResult range].length == 0) {
            // could be empty line
            continue;
        }
        
        NSString *lccn = [self stringFromMatchResult:matchResult index:2 string:line];
        int numberOfIssue = [[self stringFromMatchResult:matchResult index:3 string:line] intValue];
        NSString *firstDate = [self stringFromMatchResult:matchResult index:4 string:line];
        int firstYear = [[firstDate substringFromIndex:[firstDate length]-4] intValue];
        NSString *lastDate = [self stringFromMatchResult:matchResult index:5 string:line];
        int lastYear = [[lastDate substringFromIndex:[lastDate length]-4] intValue];
        
        TPNewspaper *newspaper = [self newspaperOfLccn:lccn];
        [newspaper setNumberOfIssues:numberOfIssue];
        [newspaper setFirstIssueYear:firstYear];
        [newspaper setLastIssueYear:lastYear];
    }
}

+ (NSString *)stringFromMatchResult:(NSTextCheckingResult *)result index:(int)index string:(NSString *)string
{
    NSString *field = [string substringWithRange:[result rangeAtIndex:index+1]];
    return [field stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


//
// load newspaper edition for this date
// return nil if network error
// return TPNewspaperEdition with zero page for no newspaper edition published
//
+ (TPNewspaperEdition *)newspaperEdition:(NSString *)lccn year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    // example http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1.json
    
    NSString *url = [[NSString alloc] initWithFormat:@"http://chroniclingamerica.loc.gov/lccn/%@/%02d-%02d-%02d/ed-1.json",
                     lccn, (int)year, (int)month, (int)day];
    
    if (editionCache == nil) {
        [self setupCaches];
    }
    
    // cache is keyed on url,
    TPNewspaperEdition *edition = [editionCache objectForKey:url];
    
    if (edition != nil) {
        return edition;
    }
    
    // create a new edition object
    edition = [[TPNewspaperEdition alloc] init];
    
    NSError *error;
    NSData *newspaperEditionJson = [self responseDataOfUrl:url error:&error];
    
    if (newspaperEditionJson == nil || [newspaperEditionJson length] == 0) {
        if (error == nil) {
            // no I/O error, assume it is 404
            // that means newspaper edition is not found
            // save to cache even it is nil, to save the next request
            [editionCache setObject:edition forKey:url];
            return edition;
        } else {
            return nil;
        }
    }
    
    // parse json
    NSDictionary *newspaperEdDict = [NSJSONSerialization JSONObjectWithData:newspaperEditionJson options: NSJSONReadingMutableContainers error: &error];
    /*
     
     {
     "title": {
     "url": "http://chroniclingamerica.loc.gov/lccn/sn86069873.json",
     "name": "The Bourbon news."
     },
     "url": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1.json",
     "date_issued": "1900-01-05",
     "batch": {
     "url": "http://chroniclingamerica.loc.gov/batches/batch_kyu_one_ver01.json",
     "name": "batch_kyu_one_ver01"
     },
     "volume": "",
     "edition": 1,
     "pages": [
     {
     "url": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1.json",
     "sequence": 1
     },
     {
     "url": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-2.json",
     "sequence": 2
     }
     ]
     }
     
     */
    [edition setDateIssued:[newspaperEdDict objectForKey:@"date_issued"]];

    for (NSDictionary* page in [newspaperEdDict objectForKey:@"pages"]) {
        NSString *url = [page objectForKey:@"url"];
        [edition addPageUrl:url];
    }
    
    [edition setNewspaper:[self newspaperOfLccn:lccn]];
    
    [edition setThumbnail:[self thumbnailForNewspaperEdition:edition page:0]];
    
    // save to cache
    [editionCache setObject:edition forKey:url];
    
    return edition;
}


+ (NSData *)pdfForNewspaperEdition:(TPNewspaperEdition *)edition page:(NSUInteger)pageNumber
{
    if (pdfCache == nil) {
        [self setupCaches];
    }
    
    // cache is keyed on page json url,
    // example: "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1.json"
    NSString *pageJsonUrl = [edition urlForPage:pageNumber];
    NSData *pdfData = [pdfCache objectForKey:pageJsonUrl];
    
    if (pdfData != nil) {
        return pdfData;
    }
    
    NSError *error;
    NSData *pageJson = [self responseDataOfUrl:pageJsonUrl error:&error];
    
    if (error != nil || pageJson == nil || [pageJson length] == 0) {
        // I/O error
        return nil;
    }
    
    /*
     {
     "jp2": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1.jp2",
     "sequence": 1,
     "text": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1/ocr.txt",
     "title": {
     "url": "http://chroniclingamerica.loc.gov/lccn/sn86069873.json",
     "name": "The Bourbon news."
     },
     "pdf": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1.pdf",
     "ocr": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1/ocr.xml",
     "issue": {
     "url": "http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1.json",
     "date_issued": "1900-01-05"
     }
     }
     */
    
    // parse json
    NSDictionary *pageDict = [NSJSONSerialization JSONObjectWithData:pageJson options: NSJSONReadingMutableContainers error: &error];
    
    NSString *pdfUrl = [pageDict objectForKey:@"pdf"];
    error = nil;
    pdfData = [self responseDataOfUrl:pdfUrl error:&error];
    
    if (error != nil) {
        return nil;
    }
    
    // put into cache
    [pdfCache setObject:pdfData forKey:pageJsonUrl];
    
    return pdfData;
}

+ (UIImage *)thumbnailForNewspaperEdition:(TPNewspaperEdition *)edition page:(NSUInteger)pageNumber
{
    NSMutableString *pageJsonUrl = [[NSMutableString alloc] initWithString:[edition urlForPage:pageNumber]];
    // example: http://chroniclingamerica.loc.gov/lccn/sn86069873/1900-01-05/ed-1/seq-1.json
    // replace ".json" with "/thumbnail.jpg"
    // example: http://chroniclingamerica.loc.gov/lccn/sn83030272/1887-07-11/ed-1/seq-1/thumbnail.jpg
    
    // to match .json
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                   @"\\.json" options:0 error:nil];
    [regex replaceMatchesInString:pageJsonUrl options:0 range:NSMakeRange(0, [pageJsonUrl length]) withTemplate:@"/thumbnail.jpg"];
    NSError *error;
    NSData *thumbnailData = [self responseDataOfUrl:pageJsonUrl error:&error];
    if (error != nil) {
        return nil;
    } else {
        return [[UIImage alloc] initWithData:thumbnailData];
    }
}

//
// clear cache in case of memory warning
//
+ (void)clearCache:(NSNotification *)note
{
    NSLog(@"Cache is cleared");
    [editionCache removeAllObjects];
    [pdfCache removeAllObjects];
}



@end
