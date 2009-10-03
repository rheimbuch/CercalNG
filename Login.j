@import <Foundation/CPObject.j>

@import <AppKit/CPApplication.j>
@import <AppKit/CPPanel.j>


@implementation Login : CPObject {
    IBOutlet    CPPanel             loginPanel;
    IBOutlet    CPTextField         connectionField;
    IBOutlet    CPTextField         userField;
    IBOutlet    CPSecureTextField   passwordField;
    
                id                  delegate        @accessors;
}

-(id)init {
    self = [super init];
    
    if(self){
        if(![CPBundle loadCibNamed: "LoginPanel" owner: self]){
            CPLog("Error loading Cib for LoginPanel");
        }
        else {
            console.debug(loginPanel);
        }
    }
    
    return self;
}

-(void)runModal {
    [CPApp runModalForWindow: loginPanel];
}

-(void)login: (id)sender {
    var url = [connectionField objectValue];
    var user = [userField objectValue];
    var password = [passwordField objectValue];
    
    if(url && user && password) {
        console.debug("Authenticating to server");
        [self authenticateToServer: url
                withUser: user
                andPassword: password];
    }
    else if(url) {
        console.debug("Connecting without authentication");
        [self _connectionRequestTo: url];
    }
    else {
        alert("Server URL must be provided.");
    }
    [CPApp abortModal];
    [loginPanel close];
}

-(void)cancel: (id)selector {
    [CPApp abortModal];
    [loginPanel close];
}

-(void)authenticateToServer: (CPString) url withUser: (CPString)user andPassword: (CPString)password {
    var uri = new dojo._Url(url);
    // authUri.scheme = "http";
    //     authUri.host = uri.host;
    //     authUri.path = "Class/User";
    var authUri = "";
    if(uri.host) {
        authUri += "http://" + uri.host;
    }
    if(uri.port) {
        authUri += ":" + uri.port;
    }
    authUri += "/Class/User";
    
    
    console.debug("Constructed auth url");
    console.debug(authUri);
    
    if(authUri.match(new RegExp("^\\w*://"))) {
		// if it is cross-domain, we will use window.name for communication
		console.debug("Loading cross domain xhr support");
		dojo.require("dojox.io.xhrScriptPlugin");
		dojox.io.xhrScriptPlugin(authUri, "callback", dojox.io.xhrPlugins.fullHttpAdapter);
	}
    
    dojo.xhrPost({
        url: authUri,
        postData: dojo.toJson({
            method: 'authenticate',
            id: 'login',
            params: [user, password]}),
        handleAs: 'json',
        load: function(response, request){
            if(response.error != null){
                [self _authenticationRequest: request failedWithResponse: response];
            }
            else {
                [self _authenticationRequest: request succeededWithResponse: response];
            }
        },
        error: function(response, request){
            [self _authenticationRequest: request failedWithResponse: response];
        }
        
    })
}

-(void)_connectionRequestTo: (CPObject)url {
    if([delegate respondsToSelector: @selector(connectToServer:)]) {
        [delegate connectToServer: url];
    }
}

-(void)_authenticationRequest: (JSObject)request succeededWithResponse: (JSObject)response {
    console.debug("Authentication Succeeded");
    console.debug(request);
    console.debug(response);
    var url = [connectionField objectValue];
    [self _connectionRequestTo: url];
}

-(void)_authenticationRequest: (JSObject)request failedWithResponse: (JSObject)response {
    console.debug("Authentication Failed");
    console.debug(request);
    console.debug(response);
}
@end