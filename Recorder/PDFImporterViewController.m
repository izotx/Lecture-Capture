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



@interface PDFImporterViewController ()<TJLFetchedResultsSourceDelegate, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSFetchedResultsController * fetchedController;
@property (strong, nonatomic)TJLFetchedResultsSource * datasource;
@property (strong,nonatomic) PDF * pdf;
@property (strong, nonatomic) PDFParser * parser;
@end

@implementation PDFImporterViewController



-(void)parsePDF:(NSURL *)pdf;{

    _parser = [[PDFParser alloc]initWithFilePath:[pdf path]];
    [_parser getPagesWithGeneratedPageHandler:^(UIImage *img, UIImage * thumb, int pageNr, float progress) {
        //Create page
        PDFPage *page = [self createNewPDFPage];
        page.image = UIImageJPEGRepresentation(img, 0.5);
        page.thumb =UIImageJPEGRepresentation(thumb, 0.5);

        [self.pdf addPageObject:page];
    
        
    } completed:^{
        NSLog(@"Completed");
    } error:^(NSString *error) {
        NSLog(@"Error");
    }];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *frequest = [[NSFetchRequest alloc]init];
    [frequest setFetchBatchSize:20];
    [frequest setEntity: [NSEntityDescription entityForName:  @"PDFPage" inManagedObjectContext:appDelegate.managedObjectContext ]];
   
    //initialize pdf
    PDF * pdf =[NSEntityDescription insertNewObjectForEntityForName:@"PDF" inManagedObjectContext:appDelegate.managedObjectContext];
    [appDelegate.managedObjectContext insertObject:pdf];
    NSError * e;
    
    [appDelegate.managedObjectContext save:&e];
    if(e){
        NSLog(@"Error: %@",e.debugDescription);
    }
    
    self.pdf = pdf;
    
    [frequest setPredicate: [NSPredicate predicateWithFormat: @"pdf == %@", self.pdf]];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"pagenr" ascending:YES];
    [frequest setSortDescriptors:@[sd]];
   
    _fetchedController  = [[NSFetchedResultsController alloc]initWithFetchRequest:frequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:Nil cacheName:nil];
    _datasource  = [[TJLFetchedResultsSource alloc]initWithFetchedResultsController:_fetchedController  delegate:self andCellID:@"pdfCell"];
    
    self.collectionView.dataSource = _datasource;
    self.collectionView.delegate = self;

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
    [self.collectionView reloadData];
    
}

- (void)didInsertObjectAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *strongCollectionView = self.collectionView;
    [strongCollectionView insertItemsAtIndexPaths:@[indexPath]];
    if(indexPath.row != 0) {
       // [strongCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}



@end
