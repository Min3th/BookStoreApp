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
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor"
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
}


    
