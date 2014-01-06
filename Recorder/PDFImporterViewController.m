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
@end

@implementation PDFImporterViewController

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)parsePDF:(NSURL *)pdf;{

    
    _parser = [[PDFParser alloc]initWithFilePath:[pdf path]];
    [_parser getPagesWithGeneratedPageHandler:^(UIImage *img, UIImage * thumb, int pageNr, float progress) {
        //Create page
        PDFPage *page = [self createNewPDFPage];
        page.image = UIImageJPEGRepresentation(img, 0.9);
        page.thumb =UIImageJPEGRepresentation(thumb, 0.5);
        page.pagenr = [NSNumber numberWithInteger:pageNr];
        [self.pdf addPageObject:page];
    
        
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

-(void)setup{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //if pdf doesn' exist create a new one
    if(!self.pdf){
    //initialize pdf
    PDF * pdf =[NSEntityDescription insertNewObjectForEntityForName:@"PDF" inManagedObjectContext:appDelegate.managedObjectContext];
    [appDelegate.managedObjectContext insertObject:pdf];
    NSError * e;
    
    [appDelegate.managedObjectContext save:&e];
    if(e){
        NSLog(@"Error: %@",e.debugDescription);
    }
    
    self.pdf = pdf;
    }

    NSFetchRequest *frequest = [[NSFetchRequest alloc]init];
    [frequest setFetchBatchSize:20];
    [frequest setEntity: [NSEntityDescription entityForName:  @"PDFPage" inManagedObjectContext:appDelegate.managedObjectContext ]];
    

    [frequest setPredicate: [NSPredicate predicateWithFormat: @"pdf == %@", self.pdf]];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"pagenr" ascending:YES];
    [frequest setSortDescriptors:@[sd]];
    
    _fetchedController  = [[NSFetchedResultsController alloc]initWithFetchRequest:frequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:Nil cacheName:nil];
    _datasource  = [[TJLFetchedResultsSource alloc]initWithFetchedResultsController:_fetchedController  delegate:self andCellID:@"pdfCell"];
    
    self.collectionView.dataSource = _datasource;
    self.collectionView.delegate = self;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
       [self setup];

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
