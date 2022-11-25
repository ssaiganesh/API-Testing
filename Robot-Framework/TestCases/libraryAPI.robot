*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Resource    libraryAPI.resource


*** Test Cases ***
Add Book
    [Template]          Add Book Template
    [Documentation]     This will add a book
    ...                 Test Case expects a book ID to be created and saved to global variable for other tests

    book_name=TestName      isbn_value=SAITEST123   aisle_value=1234    author_name=Sai Ganesh
    book_name=TaskName      isbn_value=SAITASK123   aisle_value=1234    author_name=Mary Jane
    book_name=${bookName}   isbn_value=SAIROB123    aisle_value=1234    author_name=John Doe

    # To Do:    Check how to use optional arguments. For example, we only use 1-3 arguments above instead of all 4.

Get Book
    ${get_response}=    GET     ${base_url}/Library/GetBook.php     params=ID=${book_id}        expected_status=200
    Should Be Equal As Strings    ${get_response.json()}[0][book_name]    ${bookName}

Delete Book
    ${del_req}=  Create Dictionary  ID=${book_id}
    ${del_resp}=    POST    ${base_url}/Library/DeleteBook.php      json=${del_req}     expected_status=200
    Should Be Equal As Strings    ${del_resp.json()}[msg]    book is successfully deleted

Add Duplicate Book
    [Template]          Add Duplicate Book Template
    [Documentation]     This test sends a duplicate add book request
    ...                 Expects an error message for duplicate adding of book

    book_name=TestName      isbn_value=SAITEST123   aisle_value=1234    author_name=Sai Ganesh
    book_name=TaskName      isbn_value=SAITASK123   aisle_value=1234    author_name=Mary Jane