import ballerina/jballerina.java;
import ballerina/persist;
import ballerinax/persist.inmemory;




const BOOK = "books";

final isolated table<Book> key(id) booksTable = table [];

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final map<inmemory:InMemoryClient> persistClients;

    public isolated function init() returns persist:Error? {
        final map<inmemory:TableMetadata> metadata = {
            [BOOK] : {
                keyFields : ["id"],
                query: queryBooks,
                queryOne: queryOneBooks
            }
        };

        self.persistClients = {[BOOK] : check new (metadata.get(BOOK).cloneReadOnly())};
    }

    isolated resource function get books(BookTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {'class:"io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
    name: "query"} external;

    isolated resource function get books/[int id](BookTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "queryOne"
    }external;

    isolated resource function post books(BookInsert[] data) returns int[]|persist:Error{
        int[] keys = [];
        foreach BookInsert value in data{
            lock{
                if booksTable.hasKey(value.id){
                    return persist:getAlreadyExistsError("Book",value.id);
                }
                booksTable.put(value.clone());
            }
            keys.push(value.id);
        }
        return keys;
    }

    isolated resource function put books/[int id](BookUpdate value) returns Book|persist:Error {
        lock{
            if !booksTable.hasKey(id){
                return persist:getNotFoundError("Book", id);

            }

            Book book = booksTable.get(id);
            foreach var [k,v] in value.clone().entries() {
                book[k] = v;
                
            }
            booksTable.put(book);
            return book.clone();

        }
    }

    isolated  resource function delete books/[int id]() returns Book|persist:Error {
        lock{
            if !booksTable.hasKey(id){
                return persist:getNotFoundError("Book", id);
            }
            return booksTable.remove(id).clone();
        }

        
    }

    public isolated function close() returns persist:Error?{return ();}


}

isolated function queryBooks(string[] fields) returns stream<record {},persist:Error?>{
    table<Book> key(id) booksClonedTable;
    lock{
        booksClonedTable = booksTable.clone();
    }
    return from record {} 'object in booksClonedTable
        select persist:filterRecord({...'object}, fields);
}

isolated function queryOneBooks(anydata key) returns record{}|persist:NotFoundError{
    table<Book> key(id) booksClonedTable;
    lock {
        booksClonedTable = booksTable.clone();

    }
    from record {} 'object in booksClonedTable where persist:getKey('object,["id"])== key
    do {
        return {
            ...'object
        };
    };
    return persist:getNotFoundError("Book", key);
}
    
