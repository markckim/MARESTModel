# MARESTModel

A lightweight HTTP client specialized in supporting simple REST APIs.

Basic Usage:

* Subclass `MARESTModel` and over-ride the following methods:
 * `+ (NSString *)baseUrl // the base url associated with the REST API, e.g., @"https://api.xyz.com/"`
 * `+ (NSString *)api // e.g., "https://api.xyz.com/Messages.json" => @"Messages.json"`
 * `+ (NSString *)username // for basic authorization, the username`
 * `+ (NSString *)password // for basic authorization, the password`
 * `+ (NSString *)contentType // the type of data sent to the recipient, e.g., @"application/json"`
 * `+ (NSString *)accept // the type of data acceptable for the response, e.g., @"application/json"`
 * `+ (NSDictionary *)authHeaderParams // if needed, can be over-ridden to change the auth header` 
 * `+ (NSString *)urlStringWithObjectId:(NSString *)objectId // formulate url based on objectId`

* As `MARESTModel` is a subclass of `JSONModel` (https://github.com/icanzilb/JSONModel), it can easily be transformed between JSON and Objective-C classes; this can be used to your advantage by storing properties (read how JSONModel is used) on your `MARESTModel` subclass

* One strategy that works well is to create a 'base' subclass of `MARESTModel` to store the main elements of your REST API (e.g., baseUrl, username, password, etc.), and further subclass your model while modifying the `+ (NSString *)api` method and properties of your respective classes. For example, you may have a base class called `BaseRESTModel` which populates the `baseUrl`, `username`, `password`, `contentType`, and `accept` methods. You may then have a subclass of `BaseRESTModel` called `MessageModel` with the `api` method over-ridden and `MessageModel` may have a property, `@property (nonatomic, copy) NSString *text`

* Dependencies:
 * JSONModel (https://github.com/icanzilb/JSONModel)
 * AFNetworking (https://github.com/AFNetworking/AFNetworking)
