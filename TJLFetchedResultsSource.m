//
//  TJLFetchedResultsSource.m
//  Peer Chat
//
//  Created by Terry Lewis II on 11/3/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import "TJLFetchedResultsSource.h"
#import "Slide.h"
#import "SlideCell.h"
#import "AppDelegate.h"
@interface TJLFetchedResultsSource ()
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSMutableArray *objectChanges;
@property(strong, nonatomic) NSDateFormatter *dateFormatter;
@property(strong,nonatomic) NSString * cellId;

@end

@implementation TJLFetchedResultsSource
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)controller delegate:(id <TJLFetchedResultsSourceDelegate>)delegate andCellID:(NSString *)cellId
{
self = [super init];
    if(!self) {
        return nil;
    }

    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setDateFormat:@"MM/dd/yyyy : h:m:s"];

    _objectChanges = [NSMutableArray new];
    _fetchedResultsController = controller;
    [self updateContent];
    _fetchedResultsController.delegate = self;
    _delegate = delegate;
    self.cellId = cellId;
   
    return self;
}

-(void)updateContent;{
    NSError *error = nil;
    if(![_fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [collectionView.collectionViewLayout invalidateLayout];
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][(NSUInteger)section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {

    id cell;
    id object;
    object = [self itemAtIndexPath:indexPath];
    NSDictionary * dict = @{@"indexpath":indexPath, @"object" : object };
    
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellId forIndexPath:indexPath];
    [cell performSelector:@selector(configureCellWithObject:) withObject:dict];
    

    return cell;
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.objectChanges addObject:change];
}




- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Prevent item from being moved to index 0
    //    if (toIndexPath.item == 0) {
    //        return NO;
    //    }
    return YES;
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
   Slide * s1  = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
   Slide * s2 = [self.fetchedResultsController objectAtIndexPath:toIndexPath];

    NSLog(@"S1: %@, S2: %@",s1.order,s2.order);
    NSLog(@"%d %d %d %d",fromIndexPath.row,fromIndexPath.section,toIndexPath.row,toIndexPath.section);
    
    AppDelegate * sh = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
  //update all objects after the slide.
    int so = s2.order.integerValue;
    s1.order =s2.order;
    s2.order = [NSNumber numberWithInteger:so +1];
    
    
//    
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"order > %@",s2.order];
//
//    NSArray * array =   [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
//    
    
    //save context
    NSError * error;
    [sh.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    id<TJLFetchedResultsSourceDelegate>strongDelegate = self.delegate;
    for(NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            switch(type) {
                case NSFetchedResultsChangeInsert: {
                    if([strongDelegate respondsToSelector:@selector(didInsertObjectAtIndexPath:)]) {
                        [strongDelegate didInsertObjectAtIndexPath:obj];
                    }
                }
                    break;
                case NSFetchedResultsChangeDelete: {
                    if([strongDelegate respondsToSelector:@selector(didDeleteObjectAtIndexPath:)]) {
                        [strongDelegate didDeleteObjectAtIndexPath:obj];
                    }
                }
                    break;
               
                    
                case NSFetchedResultsChangeUpdate: {
                    if([strongDelegate respondsToSelector:@selector(didUpdateObjectAtIndexPath:)]) {
                        [strongDelegate didUpdateObjectAtIndexPath:obj];
                    }
                }
                    break;
                case NSFetchedResultsChangeMove: {
                    if([strongDelegate respondsToSelector:@selector(didMoveObjectAtOldIndexPath:newIndexPath:)]) {
                        [strongDelegate didMoveObjectAtOldIndexPath:[obj firstObject] newIndexPath:[obj lastObject]];
                    }
                }
                    break;
            }
        }];
    }
    [self.objectChanges removeAllObjects];
}

@end
