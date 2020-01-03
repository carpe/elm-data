# Elm-Data

This project exists to help manage the lifecycle of data from external sources as it flows through your applications. This includes DAOs for helping to make requests (both authenticated AND unauthenticated) to APIs, helpers for decoding and utilizing JWTs, and so much more.

## Usage

Install the package with:

```
elm install carpe/elm-data
``` 

### DAO (Data Access Object)

A DAO is used to wrap any necessary Configuration/Settings needed in order for your Elm application to communicate with an API. 

I recommend you create them and store them in the top level of your application.

### Resource and ListResource

Resources are used to make requests. You can create them by providing them with a DAO instance.

A Resource is used to make requests that target a single record. (i.e. SHOW/CREATE/UPDATE)

A ListResource is used to make requests that target multiple records. (i.e. INDEX/DELETE)