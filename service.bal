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

    resource function get books/[int id]() returns store:Book|error {

        return check sClient->/books/[id];
        
    }

    resource function get books() returns store:Book[]|error {
        stream<store:Book,persist:Error?> resultStream = sClient->/books;
        return check from store:Book book in resultStream
            select book;
    }

    //instead of directly mapping to an array we have used a stream to allow data to be processed incrementally, instead of having to load the entire data set at once.

    resource function put books/[int id](store:BookUpdate book) returns store:Book|error {
        return check sClient->/books/[id].put(book);
    }

    resource function delete books/[int id]()returns store:Book|error{
        return check sClient->/books/[id].delete();
    }
}