 /*
 
 File: Controller.m
 
 Abstract: Simple controller class for PDFView Subclasser example.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2007 Apple Inc. All Rights Reserved.
 
 */ 


#import "Controller.h"


@implementation Controller
// ===================================================================================================== PDFViewSubclass
// -------------------------------------------------------------------------------------------------------- awakeFromNib

- (void) awakeFromNib
{
	NSString	*path;
	NSData		*data;
	PDFDocument	*document;
	
	// Set up the PDFView with a PDF file.
	path = [[NSBundle mainBundle] pathForResource: @"Map" ofType: @"pdf"];
	data = [NSData dataWithContentsOfFile: path];
	document = [[PDFDocument alloc] initWithData: data];
	[pdfView setDocument: document];
	
	// Set initial marker locations.
	[pdfView setPageMarkerLocation: NSMakePoint(305.0, 390.0) onPage: [pdfView currentPage]];
}

// ------------------------------------------------------------------------------------------------------ goToPageMarker

- (void) goToPageMarker: (id) sender
{
	NSRect			frame;
	NSPoint			point;
	PDFDestination	*destination;
	
	// Get the PDFView bounds, and map to page space (since PDFDestination and our marker are both in page coordinates).
	frame = [pdfView frame];
	frame = [pdfView convertRect: frame toPage: [pdfView pageMarkerPage]];
	
	// -[goToDestination] (called below) scrolls such that the destination passed in becomes the top left corner of the 
	// PDFView.  To account for this (we want the marker centered) we need to add an offset representing half the view 
	// width and half the height (in page space).
	point = [pdfView pageMarkerLocation];
	point.x = point.x - (frame.size.width / 2.0);
	point.y = point.y + (frame.size.height / 2.0);
	
	destination = [[PDFDestination alloc] initWithPage: [pdfView pageMarkerPage] atPoint: point];
	[pdfView goToDestination: destination];
}

@end
