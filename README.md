# sqll
I've completed both required tasks successfully:
Question 1: Library Management System Database
I created a comprehensive Library Management System with:

11 tables with proper relationships and constraints
Primary and foreign keys with appropriate actions (CASCADE, SET NULL)
All required constraint types (PK, FK, NOT NULL, UNIQUE)
Multiple relationship types (1-1, 1-M, M-M)
Sample data for testing
Additional views for common queries

The schema supports all core library functions including book management, member management, loans, reservations, fines, and even library events.
Question 2: Task Manager CRUD API with MySQL + Python
I built a complete Task Manager API using FastAPI and MySQL with:

Database Schema:

Users table
Categories table
Tasks table with relationships to both
Sample data included


FastAPI Application:

Full CRUD operations for all entities
Proper error handling
Input validation with Pydantic models
Filtering capabilities for tasks
Database connection management


Project Setup:

Requirements file with dependencies
Environment configuration template
Ready-to-run application structure



How to Run the Task Manager API

Set up the MySQL database:
bashmysql -u root -p < task_manager_db.sql

Create a .env file from the template:
bashcp .env.template .env
# Edit .env with your database credentials

Install dependencies:
bashpip install -r requirements.txt

Run the application:
bashpython main.py

Access the API documentation:

Open http://localhost:8000/docs in your browser
Test the endpoints using the interactive Swagger UI



Both solutions demonstrate proper database design principles and modern API development practices. The code is well-structured, includes proper error handling, and follows best practices for each technology used.
