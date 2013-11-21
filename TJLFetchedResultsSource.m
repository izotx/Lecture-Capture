//
//  TJLFetchedResultsSource.m
//  Peer Chat
//
//  Created by Terry Lewis II on 11/3/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import "TJLFetchedResultsSource.h"
/*
#import "MPCMessageCollectionCell.h"
#import "MPCMessageImageCollectionViewCell.h"
#import "MPCoreMessage.h"
#import "MPCUser.h"
#import "MPCoreUser.h"
*/

#import "Slide.h"
#import "SlideCell.h"

@interface TJLFetchedResultsSource ()
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSMutableArray *objectChanges;
@property(strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation TJLFetchedResultsSource
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)controller delegate:(id <TJLFetchedResultsSourceDelegate>)delegate;// user:(MPCUser *)user {
{
self = [super init];
    if(!self) {
        return nil;
    }

    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setDateFormat:@"MM/dd/yyyy : h:m:s"];
   // _user = user;
    _objectChanges = [NSMutableArray new];
    _fetchedResultsController = controller;
    NSError *error = nil;
    if(![_fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    _fetchedResultsController.delegate = self;
    _delegate = delegate;

    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][(NSUInteger)section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
   Slide * slide = [self itemAtIndexPath:indexPath];
   SlideCell *cell;

    cell = (SlideCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell configureWithSlide:slide];
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
