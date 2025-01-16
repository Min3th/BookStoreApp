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

    isolated resource function get books() returns stream<record {|anydata...;|}, persist:Error?> {
        return queryBooks([]);
    }

    isolated resource function get books/[int id]() returns record {|anydata...;|}|persist:NotFoundError{
        return queryOneBooks(id);
    }

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

isolated function queryBooks(string[] fields) returns stream<Book, persist:Error?> {
    table<Book> key(id) booksClonedTable;
    lock {
        booksClonedTable = booksTable.clone();
    }
    
    // Returning a stream of Book objects after casting from the generic record
    return from Book book in booksClonedTable
            select book;
}

isolated function queryOneBooks(anydata key) returns Book|persist:NotFoundError{
    table<Book> key(id) booksClonedTable;
    lock {
        booksClonedTable = booksTable.clone();

    }
    from Book book in booksClonedTable where persist:getKey(book,["id"])== key
    do {
        return {...book};
    };
    return persist:getNotFoundError("Book", key);
}
    

