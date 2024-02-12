import mysql.connector

# AWS database configuration
db_config = {
    'host': 'jaspermysqldb.cmxvo66xv0u1.us-east-1.rds.amazonaws.com',
    'user': 'jasper',
    'password': 'biggenweide',
    'database': 'webserverdb',
}
conn = mysql.connector.connect(**db_config)

# Create a cursor object to interact with the database
cursor = conn.cursor()

# Insert data into the 'books' table
insert_books_query = "INSERT INTO books (type, name, price) VALUES (%s, %s, %s)"
books_data = ("paperback", "Time Machine", 5.55)
cursor.execute(insert_books_query, books_data)
conn.commit()

# Retrieve a book from the 'books' table
select_books_query = "SELECT * FROM books WHERE name = %s"
book_name = ("Time Machine",)
cursor.execute(select_books_query, book_name)
book = cursor.fetchone()

# Print information about the book
if book:
    print("The book's name is " + book[2])  # Assuming 'name' is the third column in the 'books' table

# Close the cursor and connection
cursor.close()
conn.close()
