/*
 * AppController.j
 * CercalNG
 *
 * Created by You on September 10, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPToolbar.j>
@import "DataController.j"
@import "DataView.j"
@import "Login.j"
@import "ToolbarSearchView.j"


@implementation AppController : CPObject
{
    IBOutlet    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    IBOutlet    CPTableView dataTableView;
    IBOutlet    CPTextField dataTableSearchField;
    IBOutlet    DataView    dataView;
    IBOutlet    CPTextField locationLabel;
                CPToolbar   mainToolbar;
                ToolbarSearchView   searchView;
    
                Login       loginPanel;

    
                DataController  dataStore;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [[theWindow contentView] setBackgroundColor: [CPColor grayColor]];
    //setup the toolbar
    mainToolbar = [[CPToolbar alloc] initWithIdentifier: "Main"];
    [mainToolbar setDelegate: self];
    [mainToolbar setVisible: YES];
    [theWindow setToolbar: mainToolbar];
    
    //dataStore = [DataController withExampleData];
    dataStore = [[DataController alloc] init];
    [dataStore setDelegate: self];
    //[dataTableView reloadData];
    [dataView setDataStore: [dataStore dataStore]];
    
    // Setup location label observing
    // locationLabel = [CPTextField labelWithTitle: "http://..."];
    //     [locationLabel setStringValue: [dataStore urlPath]];
    //     [dataStore addObserver: self forKeyPath:"urlPath" options: CPKeyValueObservingOptionNew context: nil];
    
    // search view for toolbar
    // searchView = [[ToolbarSearchView alloc] initWithFrame: CGRectMake(0,0,180,32)];
    //     [searchView setAutoresizingMask: CPViewWidthSizable];
    //     var searchField = [searchView searchField];
    //     [searchField setTarget: self];
    //     [searchField setAction: @selector(queryDataWith:)];
    
    loginPanel = [[Login alloc] init];
    [loginPanel setDelegate: self];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
    
}

// Handle observing
-(void)observeValueForKeyPath:(CPString)keyPath
        ofObject:(id)object
        change:(CPDictionary)change
        context:(id)context {

    console.debug("location changed");
    [locationLabel setStringValue: [dataStore urlPath]];

}

-(void)queryDataWith: (id)sender {
    console.debug(sender);
    var query = [sender stringValue];
    if(query){
        var fullQuery = "?metadata." + query;
        [dataStore setQuery: fullQuery];
    }
    else {
        [dataStore setQuery: ""];
    }
}

// datacontroller delegate methods
-(void)dataStore:(DataController)ds didReceiveData:(CPArray)data {
    [dataTableView reloadData];
}

// datasource delegate methods for dataTableView
-(int)numberOfRowsInTableView: (CPTableView)aTableView {
    var num = [[dataStore data] count];
    console.debug("numberOfRowsInTableView = " + num);
    return num;
}

-(id)tableView: (CPTableView)aTableView
     objectValueForTableColumn: (CPTableColumn)aTableColumn
     row: (int)rowIndex {

    if(aTableView === dataTableView){
        var obj = nil;
        obj = [[dataStore data] objectAtIndex: rowIndex].id;
    
        console.debug("Getting data for row " + rowIndex);
        console.debug("Data: " + obj);
        return obj;
    }

}

// delegate methods for dataTableView
-(void)tableViewSelectionDidChange: (CPNotification)notification {
    console.debug("Table selection changed");
    var row = [[dataTableView selectedRowIndexes] firstIndex];
    
    if(row == -1) return;
    console.debug([dataStore data]);
    TESTDATA = [dataStore data];
    var selectedData = [[dataStore data] objectAtIndex: row];
    console.debug("Data selected:");
    console.debug(selectedData);
    
    console.debug("Setting dataView dataItem");
    [dataView setDataItem: selectedData];
}


-(void)connectTo:(id)sender {
    [loginPanel runModal];
}

-(void)logout: (id)sender {
    // Need to login with nil credentials to invalidate login session
    [loginPanel authenticateToServer: [dataSource urlPath]
                    withUser: nil
                    andPassword: nil];
    
    [dataSource setUrlPath: ""];
}



-(void)saveDatabase: (id)sender {
    [dataStore dataStore].save();
}

// Login delegate method
-(void)connectToServer: (CPString)url {
    console.debug("Connecting to: " + url);
    [dataStore setUrlPath: url];
    [dataView setDataStore: [dataStore dataStore]];
}


-(void)showAboutDialog:(id)sender {
    var dialog = [[CPAlert alloc] init];
    [dialog setAlertStyle: CPInformationalAlertStyle];
    [dialog setTitle: "About"];
    [dialog setMessageText: "Designed by the Yogo development team."];
    [dialog addButtonWithTitle:"Close"];
    [dialog runModal];
    console.debug(dialog);
}

// Toolbar delegate methods
-(CPArray)toolbarAllowedItemIdentifiers: (CPToolbar)aToolbar {
    return [CPToolbarSeparatorItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, CPToolbarSpaceItemIdentifier, "ConnectDatabaseToolbarItem", "EditPropertyToolbarItem", "SearchQueryToolbarItem"];
}

-(CPArray)toolbarDefaultItemIdentifiers: (CPToolbar)aToolbar {
    return ["ConnectDatabaseToolbarItem", CPToolbarSeparatorItemIdentifier, "EditPropertyToolbarItem", CPToolbarFlexibleSpaceItemIdentifier, "SearchQueryToolbarItem"];
}

-(CPToolbarItem)toolbar: (CPToolbar)aToolbar itemForItemIdentifier: (CPString)anItemIdentifier willBeInsertedIntoToolbar: (BOOL)aFlag {
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];
    var mainBundle = [CPBundle mainBundle];
    var iconSize = CPSizeMake(32,32);
    
    switch(anItemIdentifier) {
    case "ConnectDatabaseToolbarItem":
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "folder_green_ideas.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "folder_green_ideas-highlight.png"] size: iconSize];
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(connectTo:)];
        [toolbarItem setLabel: "Connect to Database"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case "EditPropertyToolbarItem":
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "tablet.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "tablet-highlight.png"] size: iconSize];
        
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        
        [toolbarItem setTarget: dataView];
        [toolbarItem setAction: @selector(editSelected:)];
        [toolbarItem setLabel: "Edit Property"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case "SearchQueryToolbarItem":
        var searchView = [[ToolbarSearchView alloc] initWithFrame: CGRectMake(0,0,180,32)];
        [searchView setAutoresizingMask: CPViewWidthSizable];
        var searchField = [searchView searchField];
        [searchField setTarget: self];
        [searchField setAction: @selector(queryDataWith:)];
        
        [toolbarItem setView: searchView];
        [toolbarItem setLabel: "Search"];
        [toolbarItem setMinSize:CGSizeMake(180,32)];
        [toolbarItem setMaxSize:CGSizeMake(180,32)];
        break;
    default:
    }
    
    
    return toolbarItem;
}

@end
