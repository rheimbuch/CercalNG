@import <Foundation/CPNotificationCenter.j>
@import <Foundation/CPException.j>
@import "DataController.j"

// Notifications
DataControllerAuthenticationSucceeded = "DataControllerAuthenticationSucceeded";
DataControllerAuthenticationFailed = "DataControllerAuthenticationFailed";

@implementation DataController (Authenticated) 
    
-(BOOL)isAuthenticated {
    return !!currentUser;
}

-(void)authenticateWithUser:(CPString)user andPassword:(CPString)password {
    !url && [CPException raise: DataControllerUrlException 
                         reason: "Data source cannot authenticate without a valid source url."];
    
    [self authenticateForUrl: url withUser: user andPassword: password];
}

-(void)authenticateForUrl:(CPString)aUrl withUser:(CPString)user andPassword:(CPString)password {
    var uri = new dojo._Url(aUrl);
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

    if(!user && !password) 
        console.debug("Logging in with nil user/pass. This will deauthenticate the current session.");

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

    });
}

-(void)_authenticationRequest:(JSObject)request succeededWithResponse:(JSObject)response {
    console.debug("Authentication Succeeded");
    console.debug(request);
    console.debug(response);
    
    
    [self willChangeValueForKey: "currentUser"];
    currentUser = response.result;
    [self didChangeValueForKey: "currentUser"];
    
    // Notify delegate that authentication succeeded.
    if([delegate respondsToSelector: @selector(dataController:authenticationSucceeded:)])
        [delegate dataController: self authenticationSucceeded: YES];
        
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerAuthenticationSucceeded
                                         object: self];
}

-(void)_authenticationRequest:(JSObject)request failedWithResponse:(JSObject)response {
    console.debug("Authentication Failed");
    console.debug(request);
    console.debug(response);
    
    [self willChangeValueForKey: "currentUser"];
    currentUser = response.result;
    [self didChangeValueForKey: "currentUser"];
    
    // Notify delegate that authentication failed
    if([delegate respondsToSelector: @selector(dataController:authenticationSucceeded:)])
        [delegate dataController: self authenticationSucceeded: NO];
        
    [[CPNotificationCenter defaultCenter] postNotificationName: DataControllerAuthenticationFailed
                                         object: self];
}

-(void)endAuthenticatedSession {
    [self authenticateWithUser: nil andPassword: nil];
}

@end