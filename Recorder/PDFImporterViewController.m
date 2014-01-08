//
//  PDFImporterViewController.m
//  Lecture Capture
//
//  Created by sadmin on 12/23/13.

#import "PDFImporterViewController.h"
#import "TJLFetchedResultsSource.h"

#import "AppDelegate.h"
#import "LectureAPI.h"
#import "PDF.h"
#import "PDFPage.h"
#import "PDFParser.h"
#import "LectureAPI.h"
#import "Lecture.h"
#import "Slide.h"
#import  "RecorderViewController.h"


@interface PDFImporterViewController ()<TJLFetchedResultsSourceDelegate, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSFetchedResultsController * fetchedController;
@property (strong, nonatomic)TJLFetchedResultsSource * datasource;
@property (strong, nonatomic) PDFParser * parser;
@property (strong, nonatomic) NSManagedObjectContext * temporaryContext;
@property (strong,nonatomic ) NSString * pdfid;

@end

@implementation PDFImporterViewController

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)getUDID{
    int r1 = arc4random()%100;
    int r2 = arc4random()%10000;
    return [NSString stringWithFormat:@"%d__%d",r1,r2];
}


-(void)parsePDF:(NSURL *)__pdf;{
    NSLog(@"Parse PDF");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * temporaryContext = [self temporaryObjectContext];
    PDF * pdf =[NSEntityDescription insertNewObjectForEntityForName:@"PDF" inManagedObjectContext:temporaryContext];
    [temporaryContext insertObject:pdf];
    NSError * e;
    self.pdfid = [self getUDID];
    pdf.pdfid =self.pdfid;
    self.pdf =pdf;

    [temporaryContext save:&e];
    if(e){
        NSLog(@"Error: %@",e.debugDescription);
    }
    // setup
    
    
    _parser = [[PDFParser alloc]initWithFilePath:[__pdf path]];
    __block int counter =0;
    [_parser getPagesWithGeneratedPageHandler:^(UIImage *img, UIImage * thumb, int pageNr, float progress) {
        //Create page        
        [temporaryContext performBlock:^{
            
            PDFPage * page =[NSEntityDescription insertNewObjectForEntityForName:@"PDFPage" inManagedObjectContext:temporaryContext];
            [temporaryContext insertObject:page];
              NSError * e;
            e = nil;
            if(e){
                NSLog(@"Error: %@",e.debugDescription);
            }
            
            page.image = UIImageJPEGRepresentation(img, 0.9);
            page.thumb = UIImageJPEGRepresentation(thumb, 0.5);
            page.pagenr = [NSNumber numberWithInteger:pageNr];
            page.pdfid = self.pdfid;
        
            [pdf addPageObject:page];
            counter ++;
        
     
            NSError *error;
            if (![temporaryContext save:&error])
            {
                // handle error
                NSLog(@"%@",error);
            }
     
    
            // save parent to disk asynchronously
            [appDelegate.managedObjectContext performBlock:^{
               // [appDelegate.managedObjectContext processPendingChanges];
               
       //         [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                
                
                NSError *error;
                if (![appDelegate.managedObjectContext save:&error])
                {
                    // handle error
                }
            }];
       }];
    
        
    } completed:^{
        NSLog(@"Completed");
        
    
        

    } error:^(NSString *error) {
        NSLog(@"Error");
    }];
}

- (IBAction)voiceOver:(id)sender {
  
    Lecture * lapi = [LectureAPI createLectureWithName:self.pdf.filename];
    //create new lecture
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pagenr" ascending:YES];
    // Order
    NSArray * orderedPages = [self.pdf.page sortedArrayUsingDescriptors:@[sortDescriptor]];
    //import pdf pages into new lecture
    for(int i =0; i<orderedPages.count;i++){
        Slide * slide = [LectureAPI addNewSlideToLecture:lapi afterSlide:nil];
        PDFPage * page = orderedPages[i];
        slide.order = [NSNumber numberWithInt:i+1];
        slide.pdfimage= page.image;
        slide.thumbnail =page.thumb;
    
    }
    UINavigationController * nav = self.navigationController;
    [nav popViewControllerAnimated:NO];
    
    RecorderViewController *r=     [self.storyboard instantiateViewControllerWithIdentifier:@"RecorderViewController"];
    r.lecture = lapi;
    [nav pushViewController:r animated:YES];
}


-(PDF *)createNewPDF{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   

    PDF * pdf =[NSEntityDescription insertNewObjectForEntityForName:@"PDF" inManagedObjectContext:appDelegate.managedObjectContext];
    [appDelegate.managedObjectContext insertObject:pdf];
    NSError * e;
    
    [appDelegate.managedObjectContext save:&e];
    if(e){
        NSLog(@"Error: %@",e.debugDescription);
    }
  
    

    return pdf;
    
}


-(PDFPage *)createNewPDFPage{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PDFPage * pdfpage =[NSEntityDescription insertNewObjectForEntityForName:@"PDFPage" inManagedObjectContext:appDelegate.managedObjectContext];
    [appDelegate.managedObjectContext insertObject:pdfpage];
    NSError * e;
    
    [appDelegate.managedObjectContext save:&e];
    if(e){
        NSLog(@"Error: %@",e.debugDescription);
    }
    return pdfpage;
}

-(NSManagedObjectContext * )temporaryObjectContext{
    if(_temporaryContext){
        return _temporaryContext;
    }
    _temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _temporaryContext.parentContext =appDelegate.managedObjectContext;
  
   // return appDelegate.managedObjectContext;
    
    return _temporaryContext;
}

-(void)setup{
   
    //if pdf doesn' exist create a new one
    if(!self.pdf){
    //initialize pdf
    
    _temporaryContext =  [self temporaryObjectContext];
    PDF * pdf =[NSEntityDescription insertNewObjectForEntityForName:@"PDF" inManagedObjectContext:self.temporaryContext];
    [_temporaryContext insertObject:pdf];
    NSError * e;
    
    [_temporaryContext save:&e];
    if(e){
        NSLog(@"Error: %@",e.debugDescription);
    }
    
        self.pdf = pdf;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(!self.pdf)
    {
        [self setup];
    }
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *frequest = [[NSFetchRequest alloc]init];
    [frequest setFetchBatchSize:20];
    [frequest setEntity: [NSEntityDescription entityForName:  @"PDFPage" inManagedObjectContext:appDelegate.managedObjectContext ]];

    [frequest setPredicate: [NSPredicate predicateWithFormat: @"pdfid == %@", self.pdfid]];
     
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"pagenr" ascending:YES];
    [frequest setSortDescriptors:@[sd]];
    
    _fetchedController  = [[NSFetchedResultsController alloc]initWithFetchRequest:frequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:Nil cacheName:nil];
    _datasource  = [[TJLFetchedResultsSource alloc]initWithFetchedResultsController:_fetchedController  delegate:self andCellID:@"pdfCell"];
    
    self.collectionView.dataSource = _datasource;
    self.collectionView.delegate = self;
    NSLog(@"View Did Load");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - TJLFetchedResultsSourceDelegate & Collection View

-(void)didUpdateObjectAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionView *strongCollectionView = self.collectionView;
    [strongCollectionView  reloadItemsAtIndexPaths:@[indexPath]];
    //[self.collectionView reloadData];
    
}

- (void)didInsertObjectAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *strongCollectionView = self.collectionView;
    [strongCollectionView insertItemsAtIndexPaths:@[indexPath]];
   
    [strongCollectionView  reloadItemsAtIndexPaths:@[indexPath]];
    
    if(indexPath.row != 0) {
       // [strongCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}



@end
