import ballerina/persist as _;

public type Book record {|
        readonly int id;
        string book_title;
        string author;
        string category;
        int published_year;
        decimal price;
        int copies_in_stock;|};

