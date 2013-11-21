//
//  TJLFetchedResultsSource.h
//  Peer Chat
//
//  Created by Terry Lewis II on 11/3/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJLFetchedResultsSourceDelegate <NSObject>
@optional
- (void)didInsertObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)didMoveObjectAtOldIndexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath;

- (void)didDeleteObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)didUpdateObjectAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TJLFetchedResultsSource : NSObject <UICollectionViewDataSource, NSFetchedResultsControllerDelegate>
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)controller delegate:(id <TJLFetchedResultsSourceDelegate>)delegate;// user:(MPCUser *)user;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@property(weak, nonatomic) id <TJLFetchedResultsSourceDelegate> delegate;
@end
