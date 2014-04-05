/*
 
 Copyright (c) 2013 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSVGParser.h"
#import "JAMStyledBezierPath.h"
#import "JAMStyledBezierPathFactory.h"

@interface JAMSVGParser () <NSXMLParserDelegate>
@property (nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) JAMStyledBezierPathFactory *pathFactory;
@end

@implementation JAMSVGParser

+ (NSArray *)parseFileNamed:(NSString *)fileName;
{
    JAMSVGParser *svgParser = [JAMSVGParser.alloc initWithSVGDocument:[NSBundle.mainBundle pathForResource:fileName ofType:@"svg"]];
    if ([svgParser parseSVGDocument])
        return svgParser.paths;

    return nil;
}

- (id)initWithSVGDocument:(NSString *)path;
{
    if (!(self = [super init])) return nil;
    
    self.xmlParser = [NSXMLParser.alloc initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    self.xmlParser.delegate = self;
    self.paths = NSMutableArray.new;
    self.pathFactory = JAMStyledBezierPathFactory.new;
    return self;
}

- (BOOL)parseSVGDocument;
{
    BOOL didSucceed = [self.xmlParser parse];
    if (self.xmlParser.parserError)
        NSLog(@"parserError: %@", self.xmlParser.parserError);

    return didSucceed;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"svg"]) {
        [self parseRootElement:attributeDict];
        return;
    }
    JAMStyledBezierPath *path = [self.pathFactory styledPathFromElementName:elementName attributes:attributeDict];
    if (path)
        [self.paths addObject:path];
}

- (void)parseRootElement:(NSDictionary *)attributeDict;
{
    CGRect viewBox = CGRectZero;
    
    NSScanner *viewBoxScanner = [NSScanner scannerWithString:attributeDict[@"viewBox"]];
    [viewBoxScanner scanFloat:&viewBox.origin.x];
    [viewBoxScanner scanFloat:&viewBox.origin.y];
    [viewBoxScanner scanFloat:&viewBox.size.width];
    [viewBoxScanner scanFloat:&viewBox.size.height];

    self.viewBox = viewBox;
}

@end
