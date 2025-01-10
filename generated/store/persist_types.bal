public type Book record {|
    readonly int id;
    string book_title;
    string author;
    string category;
    int published_year;
    decimal price;
    int copies_in_stock;|};

public type BookRequest record {|
    int id;
    string book_title;
    string author;
    string category;
    int published_year;
    decimal price;
    int copies_in_stock;
|}; 

public type BookOptionalized record {|
    int id?;
    string book_title?;
    string author?;
    string category?;
    int published_year?;
    decimal price?;
    int copies_in_stock?;|};

public type BookTargetType typedesc<BookOptionalized>;

public type BookInsert Book;

public type BookUpdate record {|
    string book_title?;
    string author?;
    string category?;
    int published_year?;
    decimal price?;
    int copies_in_stock?;|};