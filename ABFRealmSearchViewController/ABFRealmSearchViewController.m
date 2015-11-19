//
//  ABFRealmSearchViewController.m
//  ABFRealmSearchViewControllerExample
//
//  Created by Adam Fish on 6/1/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "ABFRealmSearchViewController.h"

#import <Realm/Realm.h>
#import <Realm/RLMRealm_Dynamic.h>


@interface ABFRealmSearchViewController () <UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) RLMRealmConfiguration *realmConfiguration;
@property (assign, nonatomic) BOOL viewLoaded;

@property (strong, nonatomic) RLMResults *results;
@property (strong, nonatomic) RLMNotificationToken *resultsToken;
@property (strong, nonatomic) NSString *searchText;
@end

@implementation ABFRealmSearchViewController
@synthesize sortPropertyKey = _sortPropertyKey;

#pragma mark - UIKit

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.searchBarInTableView) {
        
        self.tableView.tableHeaderView = self.searchBar;
        
        [self.searchBar sizeToFit];
    }
    
    self.definesPresentationContext = YES;
    
    self.viewLoaded = YES;
    [self updateSearch];
}

#pragma mark - ABFRealmSearchViewController Initializiation

- (instancetype)initWithEntityName:(NSString *)entityName
             searchPropertyKeyPath:(NSString *)keyPath
{
    return [self initWithEntityName:entityName
                            inRealm:[RLMRealm defaultRealm]
              searchPropertyKeyPath:keyPath
                      basePredicate:nil
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
{
    return [self initWithEntityName:entityName
                            inRealm:realm
              searchPropertyKeyPath:keyPath
                      basePredicate:nil
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
{
    return [self initWithEntityName:entityName
                            inRealm:[RLMRealm defaultRealm]
              searchPropertyKeyPath:keyPath
                      basePredicate:basePredicate
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
{
    return [self initWithEntityName:entityName
                            inRealm:realm
              searchPropertyKeyPath:keyPath
                      basePredicate:basePredicate
                     tableViewStyle:UITableViewStylePlain];
}

- (instancetype)initWithEntityName:(NSString *)entityName
                           inRealm:(RLMRealm *)realm
             searchPropertyKeyPath:(NSString *)keyPath
                     basePredicate:(NSPredicate *)basePredicate
                    tableViewStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        [self defaultInitWithEntityName:entityName
                                inRealm:realm
                  searchPropertyKeyPath:keyPath
                          basePredicate:basePredicate];
    }
    
    return self;
}

#pragma mark UITableViewController Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)defaultInitWithEntityName:(NSString *)entityName
                          inRealm:(RLMRealm *)realm
            searchPropertyKeyPath:(NSString *)keyPath
                    basePredicate:(NSPredicate *)basePredicate
{
    [self baseInit];
    
    _entityName = entityName;
    _realmConfiguration = realm.configuration;
    _searchPropertyKeyPath = keyPath;
    _basePredicate = basePredicate;
}

- (void)baseInit
{
    // Defaults
    _resultsDataSource = self;
    _resultsDelegate = self;
    
    _searchBarInTableView = YES;
    _useContainsSearch = NO;
    _caseInsensitiveSearch = YES;
    _sortAscending = YES;
    
    _realmConfiguration = [RLMRealmConfiguration defaultConfiguration];
    
    // Create the search controller
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    
    _searchBar = _searchController.searchBar;
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchText = searchController.searchBar.text;
    [self updateSearch];
}

#pragma mark - <UITableViewDelegate>

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.resultsDelegate respondsToSelector:@selector(searchViewController:willSelectObject:atIndexPath:)]) {
        
        id object = self.results[indexPath.row];
        
        [self.resultsDelegate searchViewController:self willSelectObject:object atIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.resultsDelegate respondsToSelector:@selector(searchViewController:didSelectObject:atIndexPath:)]) {
        
        id object = self.results[indexPath.row];
        
        [self.resultsDelegate searchViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.results[indexPath.row];
    
    UITableViewCell *cell = [self.resultsDataSource searchViewController:self
                                                           cellForObject:object
                                                             atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - <ABFRealmSearchControllerDataSource>

- (UITableViewCell *)searchViewController:(ABFRealmSearchViewController *)searchViewController
                            cellForObject:(id)anObject
                              atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Getters

- (RLMRealm *)realm
{
    return [RLMRealm realmWithConfiguration:self.realmConfiguration error:nil];
}

- (NSString *)sortPropertyKey
{
    if (!_sortPropertyKey &&
        ![self.searchPropertyKeyPath containsString:@"."]) {
        
        return self.searchPropertyKeyPath;
    }
    
    return _sortPropertyKey;
}

#pragma mark - Setters

- (void)setEntityName:(NSString *)entityName
{
    _entityName = entityName;
    [self updateSearch];
}

- (void)setSearchPropertyKeyPath:(NSString *)searchPropertyKeyPath
{
    _searchPropertyKeyPath = searchPropertyKeyPath;
    [self updateSearch];
}

- (void)setBasePredicate:(NSPredicate *)basePredicate
{
    _basePredicate = basePredicate;
    [self updateSearch];
}

- (void)setSortPropertyKey:(NSString *)sortPropertyKey
{
    _sortPropertyKey = sortPropertyKey;
    [self updateSearch];
}

- (void)setSortAscending:(BOOL)sortAscending
{
    _sortAscending = sortAscending;
    [self updateSearch];
}

- (void)setCaseInsensitiveSearch:(BOOL)caseInsensitiveSearch
{
    _caseInsensitiveSearch = caseInsensitiveSearch;
    [self updateSearch];
}

- (void)setUseContainsSearch:(BOOL)useContainsSearch
{
    _useContainsSearch = useContainsSearch;
    [self updateSearch];
}

#pragma mark - Private

- (void)updateWithNewResults:(RLMResults *)results
{
    self.results = results;
    [self.tableView reloadData];
}

- (void)updateSearch
{
    RLMResults *search = [self.realm allObjects:self.entityName];
    if (self.basePredicate) {
        search = [search objectsWithPredicate:self.basePredicate];
    }
    if (self.searchText.length) {
        search = [search objectsWithPredicate:[self searchPredicateWithText:self.searchText]];
    }
    if (self.sortPropertyKey) {
        search = [search sortedResultsUsingProperty:self.sortPropertyKey ascending:self.sortAscending];
    }

    [self.resultsToken stop];

    if (self.viewLoaded) {
        __weak typeof(self) weakSelf = self;
        self.resultsToken = [search deliverOnMainThread:^(RLMResults *results, NSError *error) {
            [weakSelf updateWithNewResults:results];
        }];
    }
}

- (NSPredicate *)searchPredicateWithText:(NSString *)text
{
    NSExpression *leftExpression = [NSExpression expressionForKeyPath:self.searchPropertyKeyPath];

    NSExpression *rightExpression = [NSExpression expressionForConstantValue:text];

    NSPredicateOperatorType operatorType = self.useContainsSearch ? NSContainsPredicateOperatorType : NSBeginsWithPredicateOperatorType;

    NSComparisonPredicateOptions options = self.caseInsensitiveSearch ? NSCaseInsensitivePredicateOption : 0;

    NSComparisonPredicate *filterPredicate = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                                rightExpression:rightExpression
                                                                                       modifier:NSDirectPredicateModifier
                                                                                           type:operatorType options:options];

    return filterPredicate;
}

@end
