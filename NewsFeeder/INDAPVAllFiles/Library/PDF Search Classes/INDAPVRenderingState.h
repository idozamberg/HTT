
/********************************************************************************\
 *
 * File Name       INDAPVRenderingState.h
 * Version         $Revision:: 01               $: Revision of last commit
 * Modified        $Date:: 2013-09-13 12:09:06# $: Date of last commit
 *
 * Copyright(c) 2013 IndiaNIC.com. All rights reserved.
 *
 \********************************************************************************/

#import <Foundation/Foundation.h>
#import "INDAPVFont.h"

@interface INDAPVRenderingState : NSObject <NSCopying> {
	CGAffineTransform lineMatrix;
	CGAffineTransform textMatrix;
	CGAffineTransform ctm;
	CGFloat leading;
	CGFloat wordSpacing;
	CGFloat characterSpacing;
	CGFloat horizontalScaling;
	CGFloat textRise;
	INDAPVFont *font;
	CGFloat fontSize;
}

/* Set the text matrix and (optionally) the line matrix */
- (void)setTextMatrix:(CGAffineTransform)matrix replaceLineMatrix:(BOOL)replace;

/* Transform the text matrix */
- (void)translateTextPosition:(CGSize)size;

/* Move to start of next line, optionally with custom line height and indent, and optionally save line height */
- (void)newLineWithLeading:(CGFloat)aLeading indent:(CGFloat)indent save:(BOOL)save;
- (void)newLineWithLeading:(CGFloat)lineHeight save:(BOOL)save;
- (void)newLine;

/* Converts a size from text space to user space */
- (CGSize)convertSizeToUserSpace:(CGSize)aSize;

/* Converts a float to user space */
- (CGFloat)convertToUserSpace:(CGFloat)value;


/* Matrixes (line-, text- and global) */
@property (nonatomic, assign) CGAffineTransform lineMatrix;
@property (nonatomic, assign) CGAffineTransform textMatrix;
@property (nonatomic, assign) CGAffineTransform ctm;

/* Text size, spacing, scaling etc. */
@property (nonatomic, assign) CGFloat characterSpacing;
@property (nonatomic, assign) CGFloat wordSpacing;
@property (nonatomic, assign) CGFloat leadning;
@property (nonatomic, assign) CGFloat textRise;
@property (nonatomic, assign) CGFloat horizontalScaling;

/* Font and font size */
@property (nonatomic, retain) INDAPVFont *font;
@property (nonatomic, assign) CGFloat fontSize;

@end


@interface RenderingStateStack : NSObject {
	NSMutableArray *stack;
}

+ (RenderingStateStack *)stack;

/* Push a rendering state to the stack */
- (void)pushRenderingState:(INDAPVRenderingState *)state;

/* Pops the top rendering state off the stack */
- (INDAPVRenderingState *)popRenderingState;

/* The rendering state currently on top of the stack */
@property (nonatomic, readonly) INDAPVRenderingState *topRenderingState;

@end