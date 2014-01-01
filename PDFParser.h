//
//  PDFParser.h
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFParser : NSObject
typedef void (^completedBlock)();
typedef void (^errorBlock)(NSString *error);
typedef void (^pageGenerated)(UIImage * img, UIImage * thumb, int pageNr, float progress);


- (id)initWithFilePath:(NSString*)filename;
-(size_t)getNumberOfPages;
-(UIImage *)imageForPage:(int)pageNumber sized:(CGSize)size;
-(void)getPagesWithGeneratedPageHandler:(pageGenerated )pageGeneratorBlock completed:(completedBlock )completed error:(errorBlock)errorBlock;


@end
