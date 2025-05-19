    Transactions {
        int TransactionID PK
        int OrderID FK
        datetime TransactionDate
        decimal Amount
        varchar TransactionStatus
        varchar ReceiptNumber
        text Notes
    }
