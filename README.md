Project Title: Library Management System – SQL Database Project

Project Description:

- This project involves the design and implementation of a relational database for managing a library's operations, including books, authors, readers, and loans. The database was developed using Oracle SQL and includes comprehensive data modeling, querying, and automation features.

Key Features & Implementation:

- Database Schema Design: Designed a complete relational schema for managing library entities (authors, books, readers, loans) with properly defined primary keys, foreign keys, and relationships.

- Sequences & Triggers: Created sequences and BEFORE INSERT triggers for automatic generation of primary keys for all main tables (authors, books, readers, loans).

- Complex Queries: Implemented a wide range of SQL queries for data retrieval and analysis, including:

- Listing books with their authors (handling multiple authors per book)

- Tracking active loans with overdue calculations

- Identifying books that are currently available or loaned out

- Analyzing reader borrowing history and performance

- Ranking top readers and most borrowed books

- Advanced Analytics: Developed queries for:

- Calculating reader ratings based on loan-to-delay ratios

- Identifying overdue books and calculating delay days

- Finding the most requested authors based on loan frequency

- Monitoring loans expiring within the next week

Data Manipulation: Implemented UPDATE and DELETE operations for maintaining data integrity, including:

- Updating book titles and author names

- Extending loan periods for specific book domains

- Transferring loans between readers

- Cleaning up reader records with proper cascade handling

- User-Defined Functions: Created a PL/SQL function to calculate the number of books written by a specific author.

- Automation Triggers: Developed triggers to automatically populate loan start and end dates upon insertion.

Technologies Used: Oracle SQL, PL/SQL, Sequences, Triggers, Subqueries, Joins, Aggregate Functions
