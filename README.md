# sqll
I've created a comprehensive Library Management System database that includes:

11 well-structured tables with relationships:

Core tables: books, book_copies, authors, publishers, categories
User tables: members, staff
Transaction tables: loans, reservations, fines
Event management tables: events, event_attendees


Relationship types implemented:

One-to-One: Each loan corresponds to one fine
One-to-Many: Books to copies, publishers to books
Many-to-Many: Books to authors, events to members


Proper constraints:

Primary keys
Foreign keys with appropriate ON DELETE actions
NOT NULL where required
UNIQUE constraints (ISBN, barcode, email)
ENUM types for status fields


Sample data for all tables to demonstrate functionality
Additional features:

Timestamp tracking (created_at, updated_at)
Views for common queries (available books, overdue loans, member activity)
