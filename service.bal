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

    resource function get books/[int id]() returns store:Book|persist:NotFoundError {
        
        var result = sClient->/books/[id];
        if (result is persist:NotFoundError) {
            return result;
        }
        return <store:Book>result;
        
    }

    resource function get books() returns store:Book[]|error {
        stream<record {|anydata...;|},persist:Error?> resultStream = sClient->/books;

        store:Book[] booksArray = [];
        check from record {|anydata...;|} bookRecord in resultStream
            do{
                store:Book book =<store:Book> bookRecord;
                booksArray.push(book);
            };
        return booksArray;
    }

    //instead of directly mapping to an array we have used a stream to allow data to be processed incrementally, instead of having to load the entire data set at once.

    resource function put books/[int id](store:BookUpdate book) returns store:Book|error {
        return check sClient->/books/[id].put(book);
    }

    resource function delete books/[int id]()returns store:Book|error{
        return check sClient->/books/[id].delete();
    }
}