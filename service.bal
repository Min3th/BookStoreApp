import ballerina/http;
import ballerina/persist;
import bookstore.store;

final store:Client sClient = check new();

service / on new http:Listener(9090){

    resource function post books(store:BookRequest book) returns int|error {
        store:BookInsert bookInsert = check book.cloneWithType();
        int[] bookIds = check sClient->/books.post([bookInsert]);
        return bookIds[0];
        
    }
}