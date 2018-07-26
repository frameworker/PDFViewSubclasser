 /*
 
 File: PDFViewSubclass.m
 
 Abstract: Subclass of PDFView that shows you how to override -[mouseDown] 
 in order to handle your own events and map between view coordinates and page 
 coordinates.  Also demonstrates how to override PDFView drawing routines 
 (-[drawPage:] and -[drawPagePost:]) in order to overlay your own drawing 
 on top of the PDF content.
 */

#import "PDFViewSubclass.h"


#define kPushPinImageWide			111.0
#define kPushPinImageTall			116.0
#define kPushPinImageHotspotX		4.0
#define kPushPinImageHotspotY		1.0


@implementation PDFViewSubclass
// ===================================================================================================== PDFViewSubclass
// ------------------------------------------------------------------------------------------------------------- dealloc

- (void) dealloc
{
	// Release instance vars.
	[pushpin release];
	
	// Super.
	[super dealloc];
}

// ------------------------------------------------------------------------------------------------------------ drawPage

- (void) drawPage: (PDFPage *) page
{
	// Super (PDF content will draw)
	[super drawPage: page];
	
	// Draw marker if this is the page the marker is on.
	if (page == pageMarkerPage)
	{
		NSRect		bounds;
		NSRect		box;
		
		// Set a translucent color.
		[[NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 1.0 alpha: 0.5] set];
		
		// The context is in "page space" for us (and so is our marker) so we don't need to do any coordinate mapping.
		bounds = [self pageMarkerBounds];
		box = [page boundsForBox: [self displayBox]];
		bounds.origin.x -= box.origin.x;
		bounds.origin.y -= box.origin.y;
		
		// Draw a cicrle.
		[[NSBezierPath bezierPathWithOvalInRect: bounds] fill];
	}
}

// -------------------------------------------------------------------------------------------------------- drawPagePost

- (void) drawPagePost: (PDFPage *) page
{
	// Super (text selections, etc. may draw)
	[super drawPagePost: page];
	
	// Draw marker if this is the page the marker is on.
	if (page == pageMarkerPage)
	{
		NSRect		destRect;
		
		// Lazily allocate push-pin image.
		if (pushpin == NULL)
			pushpin = [[NSImage imageNamed: @"Pin"] retain];
		
		// Get the a destination rectangle to draw the push pin image in view coordinates.
		destRect = [self pushPinBoundsInViewSpace];
		
		// Draw image.
		[pushpin drawInRect: destRect fromRect: NSMakeRect(0.0, 0.0, kPushPinImageWide, kPushPinImageTall) 
				operation: NSCompositeSourceOver fraction: 1.0];
	}
}

// ---------------------------------------------------------------------------------------------------------- mouseMoved

- (void) mouseMoved: (NSEvent *) event
{
	NSPoint		localMouse;
	PDFPage		*page;
	NSPoint		pagePoint;
	
	// Get mouse in page space.
	localMouse = [self convertPoint: [event locationInWindow] fromView: NULL];
	page = [self pageForPoint: localMouse nearest: YES];
	pagePoint = [self convertPoint: localMouse toPage: page];
	
	// Is mouse over marker?
	if ((page == pageMarkerPage) && (NSPointInRect(pagePoint, [self pageMarkerBounds])))
		[[NSCursor openHandCursor] set];
	else
		[[NSCursor arrowCursor] set];
}

// ----------------------------------------------------------------------------------------------------------- mouseDown

- (void) mouseDown: (NSEvent *) event
{
	NSPoint		localMouse;
	PDFPage		*page;
	NSPoint		pagePoint;
	NSRect		testBounds;
	
	// Get mouse in view space.
	localMouse = [self convertPoint: [event locationInWindow] fromView: NULL];
	
	// Convert to page coordinates.
	page = [self pageForPoint: localMouse nearest: YES];
	pagePoint = [self convertPoint: localMouse toPage: page];
	
	// We're going to do our hit-testing in "page space".
	// The marker bounds are already in page space but the push-pin needs to be mapped to page space since it will be 
	//larger or smaller(relative to the PDF content) as the user zooms in or out.
	// Get the union of the two rectangles.
	testBounds = NSUnionRect([self pageMarkerBounds], [self pushPinBoundsInPageSpace]);
	
	// Test mouse hit (in page space) with page marker.
	if ((page == pageMarkerPage) && (NSPointInRect(pagePoint, testBounds)))
	{
		NSPoint		wasMarkerLocation;
		NSEvent		*nextEvent;
		
		wasMarkerLocation = pageMarker;
		
        while ((nextEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged]))
		{
			NSPoint		newPoint;
			NSPoint		newMarker;
			NSRect		wasBounds;
			
			// Break when mnouse is let up.
            if ([nextEvent type] == NSEventTypeLeftMouseUp)
				break;
			
			localMouse = [self convertPoint: [nextEvent locationInWindow] fromView: NULL];
			newPoint = [self convertPoint: localMouse toPage: page];
			newMarker = NSMakePoint(wasMarkerLocation.x + newPoint.x - pagePoint.x, wasMarkerLocation.y + newPoint.y - pagePoint.y);
			
			wasBounds = NSUnionRect([self pageMarkerBounds], [self pushPinBoundsInPageSpace]);
			[self setPageMarkerLocation: newMarker onPage: page];
			[self dirtyRect: NSUnionRect(wasBounds, NSUnionRect([self pageMarkerBounds], [self pushPinBoundsInPageSpace])) onPage: pageMarkerPage];
		}
	}
}

#pragma mark ------ page marker
// -------------------------------------------------------------------------------------------------- pageMarkerLocation
// Marker is in page coordinates.

- (NSPoint) pageMarkerLocation
{
	return pageMarker;
}

// ------------------------------------------------------------------------------------------------------ pageMarkerPage

- (PDFPage *) pageMarkerPage
{
	return pageMarkerPage;
}

// ----------------------------------------------------------------------------------------------- setPageMarkerLocation

- (void) setPageMarkerLocation: (NSPoint) point onPage: (PDFPage *) page
{
	pageMarker = point;
	pageMarkerPage = page;
}

// ---------------------------------------------------------------------------------------------------- pageMarkerBounds

- (NSRect) pageMarkerBounds
{
	return NSMakeRect(pageMarker.x - 10.0, pageMarker.y - 10.0, 20.0, 20.0);
}

// -------------------------------------------------------------------------------------------- pushPinBoundsInPageSpace

- (NSRect) pushPinBoundsInPageSpace
{
	NSPoint		point;
	NSRect		bounds;
	
	// Convert marker coordinate to PDFView space.
	point = [self convertPoint: pageMarker fromPage: pageMarkerPage];
	
	// Now that we have the marker in view space, create a rectangle for the image around this point.
	bounds = NSMakeRect(point.x - kPushPinImageHotspotX, point.y - kPushPinImageHotspotY,
                        kPushPinImageWide, kPushPinImageTall);
	
	// Convert to page space.
	bounds = [self convertRect: bounds toPage: pageMarkerPage];
	
	return bounds;
}

// -------------------------------------------------------------------------------------------- pushPinBoundsInViewSpace

- (NSRect) pushPinBoundsInViewSpace
{
	NSPoint		point;
	NSRect		bounds;
	
	// Convert marker coordinate to PDFView space, and then map to the PDFView's documentView coordinates.
	point = [self convertPoint: pageMarker fromPage: pageMarkerPage];
	point = [self convertPoint: point toView: [self documentView]];
	
	// Now that we have the marker in view space, create a rectangle for the image around this point.
	// Note, the image (push pin) never changes size and so, in view space, always has the same width and height.
	bounds = NSMakeRect(point.x - kPushPinImageHotspotX, point.y - kPushPinImageHotspotY, 
                        kPushPinImageWide, kPushPinImageTall);
	
	return bounds;
}

#pragma mark ------ utility
// ---------------------------------------------------------------------------------------------------- dirtyRect:onPage

- (void) dirtyRect: (NSRect) pageRect onPage: (PDFPage *) page
{
	NSRect		viewBounds;
	
	viewBounds = [self convertRect: pageRect fromPage: page];
	[self setNeedsDisplayInRect: viewBounds];
}


@end
