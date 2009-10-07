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
@import "DataController+Authenticated.j"
@import "DataView.j"
@import "Login.j"
@import "ToolbarSearchView.j"

/* Toolbar Identifiers */
var DisconnectedToolbarIdentifier = "DisconnectedToolbarIdentifier";
var ConnectedToolbarIdentifier = "ConnectedToolbarIdentifier";


/* ToolbarItem Identifiers */
var DisconnectDatabaseToolbarItemIdentifier = "DisconnectDatabaseToolbarItemIdentifier";
var ConnectDatabaseToolbarItemIdentifier = "ConnectDatabaseToolbarItemIdentifier";
var ReloadDatabaseToolbarItemIdentifier = "ReloadDatabaseToolbarItemIdentifier";
var SaveDatabaseToolbarItemIdentifier = "SaveDatabaseToolbarItemIdentifier";
var EditPropertyToolbarItemIdentifier = "EditPropertyToolbarItemIdentifier";
var SearchQueryToolbarItemIdentifier = "SearchQueryToolbarItemIdentifier";



@implementation AppController : CPObject
{
    IBOutlet    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    IBOutlet    CPTableView dataTableView;
    IBOutlet    CPTextField dataTableSearchField;
    IBOutlet    DataView    dataView;
    IBOutlet    CPTextField locationLabel;
    
                CPToolbar   disconnectedToolbar;
                CPToolbar   connectedToolbar;
                ToolbarSearchView   searchView;
    
                Login       loginPanel;

    
                DataController  dataController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [[theWindow contentView] setBackgroundColor: [CPColor grayColor]];
    
    //setup the toolbars
    disconnectedToolbar = [[CPToolbar alloc] initWithIdentifier: DisconnectedToolbarIdentifier];
    [disconnectedToolbar setDelegate: self];
    [disconnectedToolbar setVisible: YES];
    
    connectedToolbar = [[CPToolbar alloc] initWithIdentifier: ConnectedToolbarIdentifier];
    [connectedToolbar setDelegate: self];
    [connectedToolbar setVisible: YES];
    
    [theWindow setToolbar: disconnectedToolbar];
    
    //dataController = [DataController withExampleData];
    dataController = [[DataController alloc] init];
    [dataController setDelegate: self];
    //[dataTableView reloadData];
    [dataView setDataStore: dataController];
    
    // Setup location label observing
    // locationLabel = [CPTextField labelWithTitle: "http://..."];
    //     [locationLabel setStringValue: [dataController urlPath]];
    //     [dataController addObserver: self forKeyPath:"urlPath" options: CPKeyValueObservingOptionNew context: nil];
    
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
    [locationLabel setStringValue: [dataController url]];

}

-(void)queryDataWith: (id)sender {
    console.debug(sender);
    var query = [sender stringValue];
    if(query) {
        var fullQuery = "?metadata." + query;
        [dataController setQuery: fullQuery];
    }
    else {
        [dataController setQuery: ""];
    }
}

// datacontroller delegate methods
-(void)dataController:(DataController)dc didReceiveData:(CPArray)data {
    [dataTableView reloadData];
}

-(void)dataController:(DataController)dc authenticationSucceeded:(BOOL)succeeded {
    [dc reload];

}

// datasource delegate methods for dataTableView
-(int)numberOfRowsInTableView: (CPTableView)aTableView {
    var num = [[dataController data] count];
    console.debug("numberOfRowsInTableView = " + num);
    return num;
}

-(id)tableView: (CPTableView)aTableView
     objectValueForTableColumn: (CPTableColumn)aTableColumn
     row: (int)rowIndex {

    if(aTableView === dataTableView){
        var obj = nil;
        obj = [[dataController data] objectAtIndex: rowIndex].id;
    
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
    console.debug([dataController data]);
    TESTDATA = [dataController data];
    var selectedData = [[dataController data] objectAtIndex: row];
    console.debug("Data selected:");
    console.debug(selectedData);
    
    console.debug("Setting dataView dataItem");
    [dataView setDataItem: selectedData];
}


-(void)connectTo:(id)sender {
    [loginPanel runModal];
}

-(void)disconnect: (id)sender {
    // Need to login with nil credentials to invalidate login session
    [dataController currentUser] && [dataController endAuthenticatedSession];
    [dataController reset];
    [dataView setDataItem: nil];
    [theWindow setToolbar: disconnectedToolbar];
}

// Login delegate method
-(void)connectToServer: (CPString)url withUser: (CPString)user andPassword: (CPString)password {
    console.debug("Connecting to: " + url);
    //Need to make sure we authenticate before setting the datasource url (& fetching),
    // otherwise we might get a restricted set of data.
    [dataController authenticateForUrl: url withUser: user andPassword: password];
    [dataController setUrl: url];
    [dataView setDataStore: dataController];
    [theWindow setToolbar: connectedToolbar];
}

-(void)saveDatabase: (id)sender {
    [dataController save];
}

-(void)reloadDatabase: (id)sender {
    [dataController reload];
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

/* Toolbar delegate methods */
-(CPArray)toolbarAllowedItemIdentifiers: (CPToolbar)aToolbar {

    return [CPToolbarSeparatorItemIdentifier, 
            CPToolbarFlexibleSpaceItemIdentifier, 
            CPToolbarSpaceItemIdentifier, 
            DisconnectDatabaseToolbarItemIdentifier,
            ConnectDatabaseToolbarItemIdentifier, 
            SaveDatabaseToolbarItemIdentifier,
            EditPropertyToolbarItemIdentifier, 
            SearchQueryToolbarItemIdentifier];
}

-(CPArray)toolbarDefaultItemIdentifiers: (CPToolbar)aToolbar {
    
    if([aToolbar identifier] === ConnectedToolbarIdentifier) {
        return [DisconnectDatabaseToolbarItemIdentifier, 
                SaveDatabaseToolbarItemIdentifier,
                ReloadDatabaseToolbarItemIdentifier,
                CPToolbarSeparatorItemIdentifier, 
                EditPropertyToolbarItemIdentifier, 
                CPToolbarFlexibleSpaceItemIdentifier, 
                SearchQueryToolbarItemIdentifier];
    }
    else /* return DisconnectedToolbarIdentifier items */ {
        return [ConnectDatabaseToolbarItemIdentifier, CPToolbarSeparatorItemIdentifier];
    }
}

-(CPToolbarItem)toolbar: (CPToolbar)aToolbar itemForItemIdentifier: (CPString)anItemIdentifier willBeInsertedIntoToolbar: (BOOL)aFlag {
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];
    var mainBundle = [CPBundle mainBundle];
    var iconSize = CPSizeMake(32,32);
    
    switch(anItemIdentifier) {
    case ConnectDatabaseToolbarItemIdentifier:
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "connect.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "connect-highlight.png"] size: iconSize];
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(connectTo:)];
        [toolbarItem setLabel: "Connect"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case DisconnectDatabaseToolbarItemIdentifier:
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "disconnect.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "disconnect-highlight.png"] size: iconSize];
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(disconnect:)];
        [toolbarItem setLabel: "Disconnect"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case SaveDatabaseToolbarItemIdentifier:
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "save.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "save-highlight.png"] size: iconSize];
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(saveDatabase:)];
        [toolbarItem setLabel: "Save"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case ReloadDatabaseToolbarItemIdentifier:
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "reload.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "reload-highlight.png"] size: iconSize];
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(reloadDatabase:)];
        [toolbarItem setLabel: "Reload"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case EditPropertyToolbarItemIdentifier:
        var image = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "edit.png"] size: iconSize];
        var highlightImage = [[CPImage alloc] initWithContentsOfFile: [mainBundle pathForResource: "edit-highlight.png"] size: iconSize];
        
        [toolbarItem setImage: image];
        [toolbarItem setAlternateImage: highlightImage];
        
        [toolbarItem setTarget: dataView];
        [toolbarItem setAction: @selector(editSelected:)];
        [toolbarItem setLabel: "Edit Property"];
        [toolbarItem setMinSize:iconSize];
        [toolbarItem setMaxSize:iconSize];
        break;
    case SearchQueryToolbarItemIdentifier:
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
