-- Task Manager Database Schema

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS task_manager;
CREATE DATABASE task_manager;
USE task_manager;

-- Create Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Tasks table
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    user_id INT NOT NULL,
    category_id INT,
    status ENUM('Not Started', 'In Progress', 'Completed', 'On Hold', 'Cancelled') DEFAULT 'Not Started',
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Insert sample data into Users table
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
('johndoe', 'john@example.com', '$2b$12$1NfYBdG/a7d0YutMOG5v2e7E7G9Ujw5Q9vJgFpT3KVAKm5jzPJUi.', 'John', 'Doe'),
('janedoe', 'jane@example.com', '$2b$12$WMJ4ZY4OqKqUb7n5/GxRCO.9HGe3Eq5WGUXJPn7yJ74B8MfmApM82', 'Jane', 'Doe'),
('bobsmith', 'bob@example.com', '$2b$12$L8J5jPEVxz16szr5u6G9b.YqPiLcEm/QdkUu7H5rFJKTx98qTV3ve', 'Bob', 'Smith');

-- Insert sample data into Categories table
INSERT INTO categories (name, description) VALUES
('Work', 'Professional and career-related tasks'),
('Personal', 'Personal goals and activities'),
('Health', 'Health and fitness related tasks'),
('Home', 'Household chores and projects'),
('Education', 'Learning and educational activities');

-- Insert sample data into Tasks table
INSERT INTO tasks (title, description, user_id, category_id, status, priority, due_date) VALUES
('Complete Project Proposal', 'Draft and submit the Q3 project proposal to management', 1, 1, 'In Progress', 'High', '2025-05-15'),
('Schedule Dentist Appointment', 'Call Dr. Johnson for a check-up', 1, 3, 'Not Started', 'Medium', '2025-05-20'),
('Grocery Shopping', 'Buy ingredients for weekend dinner party', 2, 4, 'Not Started', 'Low', '2025-05-08'),
('Study Python', 'Complete chapter 7 of Python course', 2, 5, 'In Progress', 'Medium', '2025-05-12'),
('Gym Workout', 'Complete 45 minute cardio session', 3, 3, 'Completed', 'Medium', '2025-05-04'),
('Team Meeting', 'Weekly team sync-up', 1, 1, 'Not Started', 'High', '2025-05-10'),
('Birthday Gift', 'Buy birthday gift for mom', 3, 2, 'Not Started', 'High', '2025-05-25'),
('Home Repairs', 'Fix leaking faucet in kitchen', 2, 4, 'On Hold', 'Low', '2025-06-01');

Task Managers API
"""
Task Manager API built with FastAPI and MySQL
"""
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional
from datetime import date, datetime
import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(
    title="Task Manager API",
    description="A simple CRUD API for managing tasks",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection configuration
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "task_manager"),
}

# Database connection function
def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database connection error",
        )

# Data Models
class UserBase(BaseModel):
    username: str
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class Category(CategoryBase):
    category_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    user_id: int
    category_id: Optional[int] = None
    status: str = "Not Started"
    priority: str = "Medium"
    due_date: Optional[date] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[int] = None
    status: Optional[str] = None
    priority: Optional[str] = None
    due_date: Optional[date] = None

class Task(TaskBase):
    task_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

# API Routes

@app.get("/")
def read_root():
    """Root endpoint"""
    return {"message": "Welcome to the Task Manager API"}

# User endpoints
@app.post("/users/", response_model=User, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate):
    """Create a new user"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Check if username or email already exists
        cursor.execute(
            "SELECT * FROM users WHERE username = %s OR email = %s", 
            (user.username, user.email)
        )
        if cursor.fetchone():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username or email already registered"
            )
        
        # In a real app, hash the password here
        password_hash = user.password  # Replace with proper hashing
        
        # Insert new user
        cursor.execute(
            """
            INSERT INTO users (username, email, password_hash, first_name, last_name)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (user.username, user.email, password_hash, user.first_name, user.last_name)
        )
        conn.commit()
        
        # Get the created user
        user_id = cursor.lastrowid
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        new_user = cursor.fetchone()
        
        return new_user
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating user: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.get("/users/", response_model=List[User])
def read_users():
    """Get all users"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        return users
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving users: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.get("/users/{user_id}", response_model=User)
def read_user(user_id: int):
    """Get a specific user by ID"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} not found"
            )
            
        return user
    
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving user: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

# Category endpoints
@app.post("/categories/", response_model=Category, status_code=status.HTTP_201_CREATED)
def create_category(category: CategoryCreate):
    """Create a new category"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Check if category name already exists
        cursor.execute("SELECT * FROM categories WHERE name = %s", (category.name,))
        if cursor.fetchone():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Category name '{category.name}' already exists"
            )
        
        # Insert new category
        cursor.execute(
            """
            INSERT INTO categories (name, description)
            VALUES (%s, %s)
            """,
            (category.name, category.description)
        )
        conn.commit()
        
        # Get the created category
        category_id = cursor.lastrowid
        cursor.execute("SELECT * FROM categories WHERE category_id = %s", (category_id,))
        new_category = cursor.fetchone()
        
        return new_category
    
    except Exception as e:
        conn.rollback()
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating category: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.get("/categories/", response_model=List[Category])
def read_categories():
    """Get all categories"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM categories")
        categories = cursor.fetchall()
        return categories
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving categories: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.get("/categories/{category_id}", response_model=Category)
def read_category(category_id: int):
    """Get a specific category by ID"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM categories WHERE category_id = %s", (category_id,))
        category = cursor.fetchone()
        
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Category with ID {category_id} not found"
            )
            
        return category
    
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving category: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

# Task endpoints
@app.post("/tasks/", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(task: TaskCreate):
    """Create a new task"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Validate user exists
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (task.user_id,))
        if not cursor.fetchone():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {task.user_id} not found"
            )
        
        # Validate category exists if provided
        if task.category_id:
            cursor.execute("SELECT * FROM categories WHERE category_id = %s", (task.category_id,))
            if not cursor.fetchone():
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Category with ID {task.category_id} not found"
                )
        
        # Insert new task
        cursor.execute(
            """
            INSERT INTO tasks (title, description, user_id, category_id, status, priority, due_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                task.title, 
                task.description, 
                task.user_id, 
                task.category_id, 
                task.status, 
                task.priority, 
                task.due_date
            )
        )
        conn.commit()
        
        # Get the created task
        task_id = cursor.lastrowid
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        new_task = cursor.fetchone()
        
        return new_task
    
    except Exception as e:
        conn.rollback()
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating task: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.get("/tasks/", response_model=List[Task])
def read_tasks(
    user_id: Optional[int] = None,
    category_id: Optional[int] = None,
    status: Optional[str] = None,
    priority: Optional[str] = None
):
    """
    Get all tasks with optional filtering
    """
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        query = "SELECT * FROM tasks WHERE 1=1"
        params = []
        
        # Add filters if provided
        if user_id:
            query += " AND user_id = %s"
            params.append(user_id)
        
        if category_id:
            query += " AND category_id = %s"
            params.append(category_id)
        
        if status:
            query += " AND status = %s"
            params.append(status)
        
        if priority:
            query += " AND priority = %s"
            params.append(priority)
        
        query += " ORDER BY due_date ASC"
        
        cursor.execute(query, tuple(params))
        tasks = cursor.fetchall()
        return tasks
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving tasks: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.get("/tasks/{task_id}", response_model=Task)
def read_task(task_id: int):
    """Get a specific task by ID"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        task = cursor.fetchone()
        
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Task with ID {task_id} not found"
            )
            
        return task
    
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving task: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.put("/tasks/{task_id}", response_model=Task)
def update_task(task_id: int, task: TaskUpdate):
    """Update a specific task"""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Check if task exists
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        existing_task = cursor.fetchone()
        
        if not existing_task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Task with ID {task_id} not found"
            )
        
        # Validate category exists if provided
        if task.category_id:
            cursor.execute("SELECT * FROM categories WHERE category_id = %s", (task.category_id,))
            if not cursor.fetchone():
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Category with ID {task.category_id} not found"
                )
        
        # Build update query dynamically based on provided fields
        update_fields = []
        params = []
        
        if task.title is not None:
            update_fields.append("title = %s")
            params.append(task.title)
        
        if task.description is not None:
            update_fields.append("description = %s")
            params.append(task.description)
        
        if task.category_id is not None:
            update_fields.append("category_id = %s")
            params.append(task.category_id)
        
        if task.status is not None:
            update_fields.append("status = %s")
            params.append(task.status)
        
        if task.priority is not None:
            update_fields.append("priority = %s")
            params.append(task.priority)
        
        if task.due_date is not None:
            update_fields.append("due_date = %s")
            params.append(task.due_date)
        
        # If no fields to update
        if not update_fields:
            return existing_task
        
        # Execute update query
        query = f"UPDATE tasks SET {', '.join(update_fields)} WHERE task_id = %s"
        params.append(task_id)
        
        cursor.execute(query, tuple(params))
        conn.commit()
        
        # Get the updated task
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        updated_task = cursor.fetchone()
        
        return updated_task
    
    except Exception as e:
        conn.rollback()
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating task: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

@app.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int):
    """Delete a specific task"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Check if task exists
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        if not cursor.fetchone():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Task with ID {task_id} not found"
            )
        
        # Delete task
        cursor.execute("DELETE FROM tasks WHERE task_id = %s", (task_id,))
        conn.commit()
        
        return None
    
    except Exception as e:
        conn.rollback()
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting task: {str(e)}"
        )
    finally:
        cursor.close()
        conn.close()

# Run server
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

Requirements
fastapi==0.104.0
uvicorn==0.23.2
mysql-connector-python==8.1.0
pydantic==2.4.2
pydantic-extra-types==2.1.0
python-dotenv==1.0.0
email-validator==2.0.0

a,evn file
# Database connection settings
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=task_manager

# Server settings
PORT=8000
HOST=0.0.0.0
