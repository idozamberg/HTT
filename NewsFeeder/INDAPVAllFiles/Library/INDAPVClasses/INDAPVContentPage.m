	
/********************************************************************************\
 *
 * File Name       INDAPVContentPage.m
 * Version         $Revision:: 01               $: Revision of last commit
 * Modified        $Date:: 2013-09-13 12:09:06# $: Date of last commit
 *
 * Copyright(c) 2013 IndiaNIC.com. All rights reserved.
 *
 \********************************************************************************/



#import "INDAPVContentPage.h"
#import "INDAPVTileView.h"
#import "CGPDFDocument.h"
#import "INDAPVSearcher.h"
#import "INDAPVContentView.h"

@implementation INDAPVContentPage
@synthesize selections, scanner,keyword;


#pragma mark INDAPVContentPage class methods

+ (Class)layerClass
{
 

	return [INDAPVTileView class];
}

#pragma mark INDAPVContentPage PDF link methods

- (void)highlightPageLinks
{
 

	if (_links.count > 0) // Add highlight views over all links
	{
		UIColor *hilite = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.15f];

		for (INDAPVDocumentLink *link in _links) // Enumerate the links array
		{
			UIView *highlight = [[UIView alloc] initWithFrame:link.rect];

			highlight.autoresizesSubviews = NO;
			highlight.userInteractionEnabled = NO;
			highlight.clearsContextBeforeDrawing = NO;
			highlight.contentMode = UIViewContentModeRedraw;
			highlight.autoresizingMask = UIViewAutoresizingNone;
			highlight.backgroundColor = hilite; // Color

			[self addSubview:highlight]; [highlight release];
		}
	}
}

- (INDAPVDocumentLink *)linkFromAnnotation:(CGPDFDictionaryRef)annotationDictionary
{
 

	INDAPVDocumentLink *documentLink = nil; // Document link object

	CGPDFArrayRef annotationRectArray = NULL; // Annotation co-ordinates array

	if (CGPDFDictionaryGetArray(annotationDictionary, "Rect", &annotationRectArray))
	{
		CGPDFReal ll_x = 0.0f; CGPDFReal ll_y = 0.0f; // PDFRect lower-left X and Y
		CGPDFReal ur_x = 0.0f; CGPDFReal ur_y = 0.0f; // PDFRect upper-right X and Y

		CGPDFArrayGetNumber(annotationRectArray, 0, &ll_x); // Lower-left X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 1, &ll_y); // Lower-left Y co-ordinate

		CGPDFArrayGetNumber(annotationRectArray, 2, &ur_x); // Upper-right X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 3, &ur_y); // Upper-right Y co-ordinate

		if (ll_x > ur_x) { CGPDFReal t = ll_x; ll_x = ur_x; ur_x = t; } // Normalize Xs
		if (ll_y > ur_y) { CGPDFReal t = ll_y; ll_y = ur_y; ur_y = t; } // Normalize Ys

		switch (_pageAngle) // Page rotation angle (in degrees)
		{
			case 90: // 90 degree page rotation
			{
				CGPDFReal swap;
				swap = ll_y; ll_y = ll_x; ll_x = swap;
				swap = ur_y; ur_y = ur_x; ur_x = swap;
				break;
			}

			case 270: // 270 degree page rotation
			{
				CGPDFReal swap;
				swap = ll_y; ll_y = ll_x; ll_x = swap;
				swap = ur_y; ur_y = ur_x; ur_x = swap;
				ll_x = ((0.0f - ll_x) + _pageSize.width);
				ur_x = ((0.0f - ur_x) + _pageSize.width);
				break;
			}

			case 0: // 0 degree page rotation
			{
				ll_y = ((0.0f - ll_y) + _pageSize.height);
				ur_y = ((0.0f - ur_y) + _pageSize.height);
				break;
			}
		}

		NSInteger vr_x = ll_x; NSInteger vr_w = (ur_x - ll_x); // Integer X and width
		NSInteger vr_y = ll_y; NSInteger vr_h = (ur_y - ll_y); // Integer Y and height

		CGRect viewRect = CGRectMake(vr_x, vr_y, vr_w, vr_h); // View CGRect from PDFRect

		documentLink = [INDAPVDocumentLink withRect:viewRect dictionary:annotationDictionary];
	}

	return documentLink;
}

- (void)buildAnnotationLinksList
{
 

	_links = [NSMutableArray new]; // Links list array

	CGPDFArrayRef pageAnnotations = NULL; // Page annotations array

	CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(_PDFPageRef);

	if (CGPDFDictionaryGetArray(pageDictionary, "Annots", &pageAnnotations) == true)
	{
		NSInteger count = CGPDFArrayGetCount(pageAnnotations); // Number of annotations

		for (NSInteger index = 0; index < count; index++) // Iterate through all annotations
		{
			CGPDFDictionaryRef annotationDictionary = NULL; // PDF annotation dictionary

			if (CGPDFArrayGetDictionary(pageAnnotations, index, &annotationDictionary) == true)
			{
				const char *annotationSubtype = NULL; // PDF annotation subtype string

				if (CGPDFDictionaryGetName(annotationDictionary, "Subtype", &annotationSubtype) == true)
				{
					if (strcmp(annotationSubtype, "Link") == 0) // Found annotation subtype of 'Link'
					{
						INDAPVDocumentLink *documentLink = [self linkFromAnnotation:annotationDictionary];

						if (documentLink != nil) [_links insertObject:documentLink atIndex:0]; // Add link
					}
				}
			}
		}

//		[self highlightPageLinks]; // For link support debugging
	}
}

- (CGPDFArrayRef)destinationWithName:(const char *)destinationName inDestsTree:(CGPDFDictionaryRef)node
{
 

	CGPDFArrayRef destinationArray = NULL;

	CGPDFArrayRef limitsArray = NULL; // Limits array

	if (CGPDFDictionaryGetArray(node, "Limits", &limitsArray) == true)
	{
		CGPDFStringRef lowerLimit = NULL; CGPDFStringRef upperLimit = NULL;

		if (CGPDFArrayGetString(limitsArray, 0, &lowerLimit) == true) // Lower limit
		{
			if (CGPDFArrayGetString(limitsArray, 1, &upperLimit) == true) // Upper limit
			{
				const char *ll = (const char *)CGPDFStringGetBytePtr(lowerLimit); // Lower string
				const char *ul = (const char *)CGPDFStringGetBytePtr(upperLimit); // Upper string

				if ((strcmp(destinationName, ll) < 0) || (strcmp(destinationName, ul) > 0))
				{
					return NULL; // Destination name is outside this node's limits
				}
			}
		}
	}

	CGPDFArrayRef namesArray = NULL; // Names array

	if (CGPDFDictionaryGetArray(node, "Names", &namesArray) == true)
	{
		NSInteger namesCount = CGPDFArrayGetCount(namesArray);

		for (NSInteger index = 0; index < namesCount; index += 2)
		{
			CGPDFStringRef destName; // Destination name string

			if (CGPDFArrayGetString(namesArray, index, &destName) == true)
			{
				const char *dn = (const char *)CGPDFStringGetBytePtr(destName);

				if (strcmp(dn, destinationName) == 0) // Found the destination name
				{
					if (CGPDFArrayGetArray(namesArray, (index + 1), &destinationArray) == false)
					{
						CGPDFDictionaryRef destinationDictionary = NULL; // Destination dictionary

						if (CGPDFArrayGetDictionary(namesArray, (index + 1), &destinationDictionary) == true)
						{
							CGPDFDictionaryGetArray(destinationDictionary, "D", &destinationArray);
						}
					}

					return destinationArray; // Return the destination array
				}
			}
		}
	}

	CGPDFArrayRef kidsArray = NULL; // Kids array

	if (CGPDFDictionaryGetArray(node, "Kids", &kidsArray) == true)
	{
		NSInteger kidsCount = CGPDFArrayGetCount(kidsArray);

		for (NSInteger index = 0; index < kidsCount; index++)
		{
			CGPDFDictionaryRef kidNode = NULL; // Kid node dictionary

			if (CGPDFArrayGetDictionary(kidsArray, index, &kidNode) == true) // Recurse into node
			{
				destinationArray = [self destinationWithName:destinationName inDestsTree:kidNode];

				if (destinationArray != NULL) return destinationArray; // Return destination array
			}
		}
	}

	return NULL;
}

- (id)annotationLinkTarget:(CGPDFDictionaryRef)annotationDictionary
{
 

	id linkTarget = nil; // Link target object

	CGPDFStringRef destName = NULL; const char *destString = NULL;

	CGPDFDictionaryRef actionDictionary = NULL; CGPDFArrayRef destArray = NULL;

	if (CGPDFDictionaryGetDictionary(annotationDictionary, "A", &actionDictionary) == true)
	{
		const char *actionType = NULL; // Annotation action type string

		if (CGPDFDictionaryGetName(actionDictionary, "S", &actionType) == true)
		{
			if (strcmp(actionType, "GoTo") == 0) // GoTo action type
			{
				if (CGPDFDictionaryGetArray(actionDictionary, "D", &destArray) == false)
				{
					CGPDFDictionaryGetString(actionDictionary, "D", &destName);
				}
			}
			else // Handle other link action type possibility
			{
				if (strcmp(actionType, "URI") == 0) // URI action type
				{
					CGPDFStringRef uriString = NULL; // Action's URI string

					if (CGPDFDictionaryGetString(actionDictionary, "URI", &uriString) == true)
					{
						const char *uri = (const char *)CGPDFStringGetBytePtr(uriString); // Destination URI string

						linkTarget = [NSURL URLWithString:[NSString stringWithCString:uri encoding:NSASCIIStringEncoding]];
					}
				}
			}
		}
	}
	else // Handle other link target possibilities
	{
		if (CGPDFDictionaryGetArray(annotationDictionary, "Dest", &destArray) == false)
		{
			if (CGPDFDictionaryGetString(annotationDictionary, "Dest", &destName) == false)
			{
				CGPDFDictionaryGetName(annotationDictionary, "Dest", &destString);
			}
		}
	}

	if (destName != NULL) // Handle a destination name
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(_PDFDocRef);

		CGPDFDictionaryRef namesDictionary = NULL; // Destination names in the document

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Names", &namesDictionary) == true)
		{
			CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

			if (CGPDFDictionaryGetDictionary(namesDictionary, "Dests", &destsDictionary) == true)
			{
				const char *destinationName = (const char *)CGPDFStringGetBytePtr(destName); // Name

				destArray = [self destinationWithName:destinationName inDestsTree:destsDictionary];
			}
		}
	}

	if (destString != NULL) // Handle a destination string
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(_PDFDocRef);

		CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Dests", &destsDictionary) == true)
		{
			CGPDFDictionaryRef targetDictionary = NULL; // Destination target dictionary

			if (CGPDFDictionaryGetDictionary(destsDictionary, destString, &targetDictionary) == true)
			{
				CGPDFDictionaryGetArray(targetDictionary, "D", &destArray);
			}
		}
	}

	if (destArray != NULL) // Handle a destination array
	{
		NSInteger targetPageNumber = 0; // The target page number

		CGPDFDictionaryRef pageDictionaryFromDestArray = NULL; // Target reference

		if (CGPDFArrayGetDictionary(destArray, 0, &pageDictionaryFromDestArray) == true)
		{
			NSInteger pageCount = CGPDFDocumentGetNumberOfPages(_PDFDocRef); // Pages

			for (NSInteger pageNumber = 1; pageNumber <= pageCount; pageNumber++)
			{
				CGPDFPageRef pageRef = CGPDFDocumentGetPage(_PDFDocRef, pageNumber);

				CGPDFDictionaryRef pageDictionaryFromPage = CGPDFPageGetDictionary(pageRef);

				if (pageDictionaryFromPage == pageDictionaryFromDestArray) // Found it
				{
					targetPageNumber = pageNumber; break;
				}
			}
		}
		else // Try page number from array possibility
		{
			CGPDFInteger pageNumber = 0; // Page number in array

			if (CGPDFArrayGetInteger(destArray, 0, &pageNumber) == true)
			{
				targetPageNumber = (pageNumber + 1); // 1-based
			}
		}

		if (targetPageNumber > 0) // We have a target page number
		{
			linkTarget = [NSNumber numberWithInteger:targetPageNumber];
		}
	}

	return linkTarget;
}

- (id)singleTap:(UITapGestureRecognizer *)recognizer
{
 

	id result = nil; // Tap result object

	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		if (_links.count > 0) // Process the single tap
		{
			CGPoint point = [recognizer locationInView:self];

			for (INDAPVDocumentLink *link in _links) // Enumerate links
			{
				if (CGRectContainsPoint(link.rect, point) == true) // Found it
				{
					result = [self annotationLinkTarget:link.dictionary]; break;
				}
			}
		}
	}

	return result;
}

#pragma mark INDAPVContentPage instance methods

- (id)initWithFrame:(CGRect)frame
{
 

	id view = nil; // UIView

	if (CGRectIsEmpty(frame) == false)
	{
		if ((self = [super initWithFrame:frame]))
		{
			self.autoresizesSubviews = NO;
			self.userInteractionEnabled = NO;
			self.clearsContextBeforeDrawing = NO;
			self.contentMode = UIViewContentModeRedraw;
			self.autoresizingMask = UIViewAutoresizingNone;
			self.backgroundColor = [UIColor clearColor];
            
			view = self; // Return self
		}
	}
	else // Handle invalid frame size
	{
		[self release];
	}

	return view;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase
{
 

	CGRect viewRect = CGRectZero; // View rect

	if (fileURL != nil) // Check for non-nil file URL
	{
		_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)fileURL, phrase);

		if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (page < 1) page = 1; // Check the lower page bounds

			NSInteger pages = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

			if (page > pages) page = pages; // Check the upper page bounds

			_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page

			if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
			{
				CGPDFPageRetain(_PDFPageRef); // Retain the PDF page

				CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
				CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
				CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

				_pageAngle = CGPDFPageGetRotationAngle(_PDFPageRef); // Angle

				switch (_pageAngle) // Page rotation angle (in degrees)
				{
					default: // Default case
					case 0: case 180: // 0 and 180 degrees
					{
						_pageSize.width = effectiveRect.size.width;
						_pageSize.height = effectiveRect.size.height;
						break;
					}

					case 90: case 270: // 90 and 270 degrees
					{
						_pageSize.height = effectiveRect.size.width;
						_pageSize.width = effectiveRect.size.height;
						break;
					}
				}

				NSInteger page_w = _pageSize.width; // Integer width
				NSInteger page_h = _pageSize.height; // Integer height

				if (page_w % 2) page_w--; if (page_h % 2) page_h--; // Even

				viewRect.size = CGSizeMake(page_w, page_h); // View size
			}
			else // Error out with a diagnostic
			{
				CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

				NSAssert(NO, @"CGPDFPageRef == NULL");
			}
		}
		else // Error out with a diagnostic
		{
			NSAssert(NO, @"CGPDFDocumentRef == NULL");
		}
	}
	else // Error out with a diagnostic
	{
		NSAssert(NO, @"fileURL == nil");
	}

	id view = [self initWithFrame:viewRect]; // UIView setup

	if (view != nil) [self buildAnnotationLinksList]; // Links

	return view;
}

- (void)dealloc
{
 

	[_links release], _links = nil;

	@synchronized(self) // Block any other threads
	{
		CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

		CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;
	}

	[super dealloc];
}

/*
- (void)layoutSubviews
{
 
}
*/

#pragma mark CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
 

	CGPDFPageRef drawPDFPageRef = NULL;

	CGPDFDocumentRef drawPDFDocRef = NULL;

	@synchronized(self) // Block any other threads
	{
		drawPDFDocRef = CGPDFDocumentRetain(_PDFDocRef);

		drawPDFPageRef = CGPDFPageRetain(_PDFPageRef);
	}

	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White

	CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill

	if (drawPDFPageRef != NULL) // Go ahead and render the PDF page into the context
	{
		CGContextTranslateCTM(context, 0.0f, self.bounds.size.height); CGContextScaleCTM(context, 1.0f, -1.0f);

		CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPDFPageRef, kCGPDFCropBox, self.bounds, 0, true));

		CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
        
        CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
        CGContextSetBlendMode(context, kCGBlendModeMultiply);
        for (INDAPVSelection *s in self.selections)
        {
            CGContextSaveGState(context);
            CGContextConcatCTM(context, s.transform);
            CGContextFillRect(context, s.frame);
            CGContextRestoreGState(context);
        }
        
//        CGContextSaveGState(context);
//        //CGContextConcatCTM(context, s.transform);
//        CGContextFillRect(context, CGRectMake(100, 200, 300, 300));
//        CGContextRestoreGState(context);

        
		CGContextDrawPDFPage(context, drawPDFPageRef); // Render the PDF page into the context
        

           
	}
    
//    PDFSearcher *ObjPDFSearcher=[[PDFSearcher alloc]init];
//    BOOL *isAvaiable=[ObjPDFSearcher page:drawPDFPageRef containsString:@"a"];
	CGPDFPageRelease(drawPDFPageRef); CGPDFDocumentRelease(drawPDFDocRef); // Cleanup
}



- (NSArray *)selections
{
	@synchronized (self)
	{
		if (!selections)
		{
            keyword=[[NSUserDefaults standardUserDefaults] objectForKey:@"SearchKeyWord"];
			[self.scanner setKeyword:keyword];//keyWord
             [self.scanner scanPage:_PDFPageRef];
			self.selections = [self.scanner selections];
		}
		return selections;
	}
}

- (INDAPVScanner *)scanner
{
	if (!scanner)
	{
		scanner = [[INDAPVScanner alloc] init];
	}
	return scanner;
}


- (void)setKeyword:(NSString *)str
{
	[keyword release];
	keyword = [str retain];
	self.selections = nil;
    self.scanner.selections = nil;
}
@end



#pragma mark - INDAPVDocumentLink class implementation

@implementation INDAPVDocumentLink

#pragma mark Properties

@synthesize rect = _rect;
@synthesize dictionary = _dictionary;

#pragma mark INDAPVDocumentLink class methods

+ (id)withRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary
{
 

	return [[[INDAPVDocumentLink alloc] initWithRect:linkRect dictionary:linkDictionary] autorelease];
}

#pragma mark INDAPVDocumentLink instance methods

- (id)initWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary
{
 

	if ((self = [super init]))
	{
		_dictionary = linkDictionary;

		_rect = linkRect;
	}

	return self;
}

- (void)dealloc
{
 

	[super dealloc];
}

@end