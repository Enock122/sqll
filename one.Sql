-- Library Management System Database
-- A complete database for managing a library including books, members, staff, and transactions

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- ========== TABLES ==========

-- Table: authors
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: publishers
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: book_categories
CREATE TABLE book_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: books
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    publisher_id INT,
    publication_year YEAR,
    edition VARCHAR(20),
    language VARCHAR(50) DEFAULT 'English',
    pages INT,
    description TEXT,
    category_id INT,
    cover_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES book_categories(category_id) ON DELETE SET NULL
);

-- Table: book_authors (Many-to-Many relationship between books and authors)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role VARCHAR(50) DEFAULT 'Author', -- Could be 'Author', 'Co-author', 'Editor', etc.
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Table: book_copies
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    location VARCHAR(50), -- Shelf number, etc.
    acquisition_date DATE,
    price DECIMAL(10,2),
    status ENUM('Available', 'Loaned', 'Reserved', 'Lost', 'Damaged', 'Under Repair') DEFAULT 'Available',
    condition ENUM('New', 'Good', 'Fair', 'Poor') DEFAULT 'Good',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Table: members
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    membership_date DATE NOT NULL,
    membership_expiry DATE,
    status ENUM('Active', 'Expired', 'Suspended', 'Cancelled') DEFAULT 'Active',
    total_borrowed INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: staff
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: loans
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    notes TEXT,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);

-- Table: reservations
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Table: fines
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason TEXT,
    issue_date DATE NOT NULL,
    payment_date DATE,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Table: events
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(255),
    max_attendees INT,
    organizer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Table: event_attendees
CREATE TABLE event_attendees (
    event_id INT,
    member_id INT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attended BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (event_id, member_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ========== INSERTING SAMPLE DATA ==========

-- Insert Publishers
INSERT INTO publishers (name, address, contact_person, phone, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', 'John Smith', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', 'Jane Doe', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', 'Robert Johnson', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', 'Sarah Williams', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com'),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', 'Michael Brown', '212-364-1100', 'info@hachettebookgroup.com', 'www.hachettebookgroup.com');

-- Insert Book Categories
INSERT INTO book_categories (name, description) VALUES
('Fiction', 'Literary works based on imagination'),
('Non-Fiction', 'Informational and factual writing'),
('Science Fiction', 'Fiction based on scientific discoveries, futuristic science, etc.'),
('Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
('Fantasy', 'Fiction with magical or supernatural elements'),
('Biography', 'Non-fiction account of a person''s life'),
('History', 'Non-fiction accounts of past events'),
('Self-Help', 'Books that help readers solve personal problems'),
('Children''s Literature', 'Books written for children'),
('Reference', 'Resource materials such as dictionaries, encyclopedias, etc.');

-- Insert Authors
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography) VALUES
('J.K.', 'Rowling', '1965-07-31', 'British', 'Author of the Harry Potter series'),
('Stephen', 'King', '1947-09-21', 'American', 'Prolific author known for horror fiction'),
('Agatha', 'Christie', '1890-09-15', 'British', 'The Queen of Mystery, author of 66 detective novels'),
('Mark', 'Twain', '1835-11-30', 'American', 'Author of classics like Adventures of Huckleberry Finn'),
('Jane', 'Austen', '1775-12-16', 'British', 'Author of Pride and Prejudice and other classics'),
('George', 'Orwell', '1903-06-25', 'British', 'Author of 1984 and Animal Farm'),
('J.R.R.', 'Tolkien', '1892-01-03', 'British', 'Author of The Lord of the Rings and The Hobbit'),
('Harper', 'Lee', '1926-04-28', 'American', 'Author of To Kill a Mockingbird'),
('F. Scott', 'Fitzgerald', '1896-09-24', 'American', 'Author of The Great Gatsby'),
('Leo', 'Tolstoy', '1828-09-09', 'Russian', 'Author of War and Peace and Anna Karenina');

-- Insert Books
INSERT INTO books (isbn, title, publisher_id, publication_year, edition, language, pages, description, category_id) VALUES
('9780747532743', 'Harry Potter and the Philosopher''s Stone', 1, 1997, 'First Edition', 'English', 223, 'The first novel in the Harry Potter series', 5),
('9780385121675', 'The Shining', 2, 1977, 'First Edition', 'English', 447, 'A horror novel about a family at an isolated hotel', 1),
('9780062073488', 'Murder on the Orient Express', 3, 1934, 'Reprint', 'English', 256, 'A detective novel featuring Hercule Poirot', 4),
('9780743273565', 'The Great Gatsby', 4, 1925, 'Reprint', 'English', 180, 'A novel about the American dream in the Jazz Age', 1),
('9780061120084', 'To Kill a Mockingbird', 5, 1960, 'Reprint', 'English', 324, 'A novel about racial inequality in the American South', 1),
('9780451524935', '1984', 1, 1949, 'Reprint', 'English', 328, 'A dystopian novel about totalitarianism', 3),
('9780618640157', 'The Lord of the Rings', 2, 1954, 'Reprint', 'English', 1178, 'An epic fantasy trilogy', 5),
('9780141439518', 'Pride and Prejudice', 3, 1813, 'Reprint', 'English', 432, 'A romantic novel about manners and marriage', 1),
('9780143039433', 'War and Peace', 4, 1869, 'Reprint', 'English', 1296, 'A novel about Russian society during the Napoleonic Wars', 1),
('9780553211589', 'Adventures of Huckleberry Finn', 5, 1884, 'Reprint', 'English', 366, 'A novel about a boy''s journey down the Mississippi River', 1);

-- Insert Book Authors relationships
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, 'Author'),
(2, 2, 'Author'),
(3, 3, 'Author'),
(4, 9, 'Author'),
(5, 8, 'Author'),
(6, 6, 'Author'),
(7, 7, 'Author'),
(8, 5, 'Author'),
(9, 10, 'Author'),
(10, 4, 'Author');

-- Insert Book Copies
INSERT INTO book_copies (book_id, barcode, location, acquisition_date, price, status, condition) VALUES
(1, 'LIB-B001-C001', 'Floor 1, Shelf A1', '2020-01-15', 19.99, 'Available', 'Good'),
(1, 'LIB-B001-C002', 'Floor 1, Shelf A1', '2020-01-15', 19.99, 'Loaned', 'Good'),
(2, 'LIB-B002-C001', 'Floor 1, Shelf B3', '2019-07-22', 24.99, 'Available', 'Fair'),
(3, 'LIB-B003-C001', 'Floor 2, Shelf C2', '2018-11-05', 15.99, 'Available', 'Good'),
(4, 'LIB-B004-C001', 'Floor 2, Shelf D4', '2020-03-10', 12.99, 'Available', 'New'),
(5, 'LIB-B005-C001', 'Floor 3, Shelf E1', '2017-05-18', 14.99, 'Reserved', 'Fair'),
(6, 'LIB-B006-C001', 'Floor 3, Shelf F2', '2019-09-30', 17.99, 'Available', 'Good'),
(7, 'LIB-B007-C001', 'Floor 4, Shelf G3', '2020-02-14', 29.99, 'Loaned', 'New'),
(8, 'LIB-B008-C001', 'Floor 4, Shelf H1', '2018-06-20', 11.99, 'Available', 'Good'),
(9, 'LIB-B009-C001', 'Floor 5, Shelf I2', '2019-12-01', 22.99, 'Available', 'Good'),
(10, 'LIB-B010-C001', 'Floor 5, Shelf J3', '2020-04-05', 13.99, 'Available', 'Good');

-- Insert Members
INSERT INTO members (first_name, last_name, email, phone, address, date_of_birth, membership_date, membership_expiry, status) VALUES
('Emma', 'Johnson', 'emma.johnson@email.com', '555-123-4567', '123 Main St, Anytown, USA', '1990-05-15', '2019-03-10', '2025-03-10', 'Active'),
('Noah', 'Williams', 'noah.williams@email.com', '555-234-5678', '456 Elm St, Anytown, USA', '1985-09-22', '2020-01-15', '2025-01-15', 'Active'),
('Olivia', 'Brown', 'olivia.brown@email.com', '555-345-6789', '789 Oak St, Anytown, USA', '1992-11-30', '2018-07-20', '2023-07-20', 'Expired'),
('Liam', 'Jones', 'liam.jones@email.com', '555-456-7890', '101 Pine St, Anytown, USA', '1988-03-17', '2021-02-05', '2026-02-05', 'Active'),
('Ava', 'Garcia', 'ava.garcia@email.com', '555-567-8901', '202 Maple St, Anytown, USA', '1995-07-08', '2019-11-12', '2024-11-12', 'Active'),
('William', 'Miller', 'william.miller@email.com', '555-678-9012', '303 Cedar St, Anytown, USA', '1980-12-04', '2020-09-30', '2025-09-30', 'Active'),
('Sophia', 'Davis', 'sophia.davis@email.com', '555-789-0123', '404 Birch St, Anytown, USA', '1993-04-19', '2021-05-15', '2026-05-15', 'Active'),
('Benjamin', 'Rodriguez', 'benjamin.rodriguez@email.com', '555-890-1234', '505 Walnut St, Anytown, USA', '1987-01-25', '2019-08-18', '2024-08-18', 'Active'),
('Isabella', 'Martinez', 'isabella.martinez@email.com', '555-901-2345', '606 Chestnut St, Anytown, USA', '1991-06-12', '2020-04-22', '2025-04-22', 'Suspended'),
('James', 'Hernandez', 'james.hernandez@email.com', '555-012-3456', '707 Spruce St, Anytown, USA', '1984-10-08', '2021-03-03', '2026-03-03', 'Active');

-- Insert Staff
INSERT INTO staff (first_name, last_name, email, phone, address, position, hire_date, salary, username, password_hash, is_admin) VALUES
('Michael', 'Smith', 'michael.smith@library.com', '555-111-2222', '111 Cherry St, Anytown, USA', 'Head Librarian', '2015-06-15', 65000.00, 'msmith', 'hashed_password_1', TRUE),
('Emily', 'Taylor', 'emily.taylor@library.com', '555-222-3333', '222 Peach St, Anytown, USA', 'Librarian', '2017-09-20', 52000.00, 'etaylor', 'hashed_password_2', FALSE),
('Daniel', 'Anderson', 'daniel.anderson@library.com', '555-333-4444', '333 Plum St, Anytown, USA', 'IT Specialist', '2018-11-12', 58000.00, 'danderson', 'hashed_password_3', TRUE),
('Olivia', 'Thomas', 'olivia.thomas@library.com', '555-444-5555', '444 Apple St, Anytown, USA', 'Librarian Assistant', '2019-03-05', 42000.00, 'othomas', 'hashed_password_4', FALSE),
('Matthew', 'Wilson', 'matthew.wilson@library.com', '555-555-6666', '555 Grape St, Anytown, USA', 'Custodian', '2016-08-14', 38000.00, 'mwilson', 'hashed_password_5', FALSE);

-- Insert Loans
INSERT INTO loans (copy_id, member_id, staff_id, loan_date, due_date, return_date, status, notes) VALUES
(2, 1, 2, '2023-05-01', '2023-05-15', '2023-05-10', 'Returned', 'Returned in good condition'),
(7, 2, 2, '2023-05-05', '2023-05-19', NULL, 'Active', 'First loan for this member'),
(5, 3, 1, '2023-04-20', '2023-05-04', '2023-05-08', 'Returned', 'Returned late, fine issued'),
(2, 4, 3, '2023-05-12', '2023-05-26', NULL, 'Active', 'Member requested renewal'),
(7, 5, 4, '2023-05-03', '2023-05-17', NULL, 'Overdue', 'Called member about overdue book');

-- Insert Reservations
INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status) VALUES
(5, 6, '2023-05-01', '2023-05-08', 'Pending'),
(3, 7, '2023-05-02', '2023-05-09', 'Fulfilled'),
(8, 8, '2023-05-03', '2023-05-10', 'Cancelled'),
(2, 9, '2023-05-04', '2023-05-11', 'Pending'),
(4, 10, '2023-05-05', '2023-05-12', 'Pending');

-- Insert Fines
INSERT INTO fines (loan_id, amount, reason, issue_date, payment_date, status) VALUES
(3, 4.50, 'Book returned 4 days late', '2023-05-08', '2023-05-10', 'Paid'),
(5, 7.00, 'Book overdue for 7 days', '2023-05-24', NULL, 'Pending');

-- Insert Events
INSERT INTO events (title, description, event_date, start_time, end_time, location, max_attendees, organizer_id) VALUES
('Book Club: Science Fiction', 'Monthly meetup discussing sci-fi novels', '2023-05-20', '14:00:00', '16:00:00', 'Meeting Room A', 20, 1),
('Children''s Story Time', 'Weekly story reading session for children', '2023-05-15', '10:00:00', '11:00:00', 'Children''s Area', 15, 2),
('Author Talk: Local Writers', 'Meet and greet with local authors', '2023-05-25', '18:00:00', '20:00:00', 'Auditorium', 50, 1),
('Digital Literacy Workshop', 'Learn basic computer skills', '2023-05-18', '13:00:00', '15:00:00', 'Computer Lab', 10, 3),
('Poetry Reading', 'Open mic poetry session', '2023-05-22', '19:00:00', '21:00:00', 'Café Area', 30, 4);

-- Insert Event Attendees
INSERT INTO event_attendees (event_id, member_id, registration_date, attended) VALUES
(1, 1, '2023-05-10', FALSE),
(1, 2, '2023-05-11', FALSE),
(2, 3, '2023-05-08', FALSE),
(2, 4, '2023-05-09', FALSE),
(3, 5, '2023-05-12', FALSE),
(3, 6, '2023-05-13', FALSE),
(4, 7, '2023-05-14', FALSE),
(4, 8, '2023-05-15', FALSE),
(5, 9, '2023-05-16', FALSE),
(5, 10, '2023-05-17', FALSE);

-- ========== OPTIONAL VIEWS ==========

-- Create a view for available books
CREATE VIEW available_books AS
SELECT b.book_id, b.title, a.first_name, a.last_name, bc.name AS category, bc.copy_id, bc.barcode
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN book_categories bc ON b.category_id = bc.category_id
JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.status = 'Available';

-- Create a view for overdue loans
CREATE VIEW overdue_loans AS
SELECT l.loan_id, b.title, m.first_name AS member_first_name, m.last_name AS member_last_name, 
       l.loan_date, l.due_date, DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM loans l
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.status = 'Overdue'
ORDER BY days_overdue DESC;

-- Create a view for member activity
CREATE VIEW member_activity AS
SELECT m.member_id, m.first_name, m.last_name, m.email,
       COUNT(DISTINCT l.loan_id) AS total_loans,
       COUNT(DISTINCT r.reservation_id) AS total_reservations,
       COUNT(DISTINCT ea.event_id) AS total_events,
       SUM(CASE WHEN f.status = 'Pending' THEN f.amount ELSE 0 END) AS pending_fines
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN reservations r ON m.member_id = r.member_id
LEFT JOIN event_attendees ea ON m.member_id = ea.member_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY m.member_id, m.first_name, m.last_name, m.email
ORDER BY total_loans DESC;
