//
//  PDFParser.m
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.

#import "PDFParser.h"


@interface PDFParser(){
    CGPDFDocumentRef document;
    NSString * filePath;
    size_t count;
    NSOperation * blockOperation;
}
@property(nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic,strong) pageGenerated pageGeneratedBlock;
@property (nonatomic,strong) errorBlock errorBlock;
@property (nonatomic,strong) completedBlock completedBlock;
@property (readonly) float progress;
@property(nonatomic) BOOL completed;

@end

@implementation PDFParser

-(void)getPagesWithGeneratedPageHandler:(pageGenerated )pageGeneratorBlock completed:(completedBlock )completed error:(errorBlock)errorBlock;
{
    self.pageGeneratedBlock = [pageGeneratorBlock copy];
    self.completedBlock = [completed copy];
    self.errorBlock = errorBlock;
    
    [self extractPages];

}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"operationCount"]){
        if([[change objectForKey:@"new"] isEqual:@0]){
            self.completed = YES;
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
               NSLog(@"Completed. ");
               self.completedBlock();
            
            }];

            
        }
    }
}



-(id)initWithFilePath:(NSString*)filename{
    self = [super init];
    if(self){
        //document = [self MyGetPDFDocumentRef: filename];
        filePath = filename;
        blockOperation = [[NSOperation alloc]init];
        _queue = [[NSOperationQueue alloc]init];
     
        [self.queue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
       
    }
    return self;
}


//gets pdf document ref
-(CGPDFDocumentRef) CreatePDFDocumentRef: (NSString *) fileName;{
   
    const char *cfileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    CFStringRef path = CFStringCreateWithCString (NULL, cfileName,
                                      
                                      kCFStringEncodingUTF8);
    
    //free((char*)cfileName);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path, // 1
                                         
                                         kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    
    CGPDFDocumentRef  _document = CGPDFDocumentCreateWithURL (url);// 2
    CFRelease(url);

    
    count = CGPDFDocumentGetNumberOfPages (_document);// 3
    
    if (count == 0) {
        NSLog(@"PDF needs at least one page");
        return NULL;
    }
    
    
    return _document;
}
//returns number of pages in pdf
-(size_t)getNumberOfPages{
    if(!document){
        document  = [self CreatePDFDocumentRef:filePath];
    }
    return count;
}




-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(CGPDFPageRef )getPage:(int) pageNumber inDocument: (CGPDFDocumentRef)_document
{
    CGPDFPageRef page = CGPDFDocumentGetPage (_document, pageNumber);
    return page;
}


-(UIImage *)imageForPage:(int)pageNumber sized:(CGSize)size{
    
    CGPDFDocumentRef _document  = [self CreatePDFDocumentRef:filePath];
    CGPDFPageRef page = CGPDFDocumentGetPage (_document, pageNumber);
    
    
    CGRect pageRect = CGPDFPageGetBoxRect(page,kCGPDFTrimBox);
    CGSize pageSize = pageRect.size;
    pageSize = MEDSizeScaleAspectFit(pageSize, size);
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//    CGContextSetRenderingIntent(context, kCGRenderingInt
    
    CGContextFillRect(context, pageRect);
    
    CGContextTranslateCTM(context, 0.0, pageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor]CGColor]);
    
    CGContextFillRect(context, pageRect);
    
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFTrimBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
    CGContextConcatCTM(context, pdfTransform);
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease (_document);
    return resultingImage;
}


CGSize MEDSizeScaleAspectFit(CGSize size, CGSize maxSize) {
    CGFloat originalAspectRatio = size.width / size.height;
    CGFloat maxAspectRatio = maxSize.width / maxSize.height;
    CGSize newSize = maxSize;
    // The largest dimension will be the `maxSize`, and then we need to scale
    // the other dimension down relative to it, while maintaining the aspect
    // ratio.
    if (originalAspectRatio > maxAspectRatio) {
        newSize.height = maxSize.width / originalAspectRatio;
    } else {
        newSize.width = maxSize.height * originalAspectRatio;
    }
    
    return newSize;
}

-(void)extractPages{
   
    int totalCount = [self getNumberOfPages];
    __block int processed = 0;
    if(totalCount <100){
        self.queue.maxConcurrentOperationCount = -1;
    }
    else{
        self.queue.maxConcurrentOperationCount = 1;
    }
    for(int i =1; i<totalCount;i++){
        NSBlockOperation * bl = [[NSBlockOperation alloc]init];
        __weak NSBlockOperation * weakOperation = bl;
        __block UIImage *im;
        __block UIImage *thumb;
        [bl addExecutionBlock:^{
            if(!weakOperation.isCancelled)
            {
                CGSize size;
                //check if it is retina screen
                if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                    ([UIScreen mainScreen].scale == 2.0)) {
                    size = CGSizeMake(800, 600);
                    // Retina display
                } else {
                    // non-Retina display
                    size = CGSizeMake(1600, 1200);
                }
                 size = CGSizeMake(1024, 580);
                
                im = [self imageForPage:i sized:size];
                thumb = [self imageWithImage:im scaledToSize:CGSizeMake(200, 200)];
               
                //NSData * png = UIImagePNGRepresentation(im);
                //NSString * fname = [NSString stringWithFormat:@"%@,%d.png",DOCUMENTS_FOLDER,i];
                
                //[png writeToFile:fname atomically:YES];
                
            }
            else{
                self.errorBlock(@"Operation Cancelled");
            }
        }];
        [bl setCompletionBlock:^{
            processed++;
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                self.pageGeneratedBlock(im,thumb, i, 100.0 * processed/totalCount*1.0);
                NSLog(@"%f",100.0 * processed/totalCount*1.0);
            }];
        }];
        [_queue addOperation:bl];
    }
}



-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}


@end
