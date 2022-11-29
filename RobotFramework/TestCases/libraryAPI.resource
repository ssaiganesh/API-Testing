*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections

*** Variables ***
${base_url}     https://rahulshettyacademy.com
${book_id}
${bookName}     Robot Framework

*** Keywords ***
Add Book Template
    [Arguments]     ${book_name}    ${isbn_value}   ${aisle_value}  ${author_name}
    &{req_body}=    Create Dictionary   name=${book_name}   isbn=${isbn_value}  aisle=${aisle_value} author=${author_name}
    &{response}=    POST    ${base_url}/Library/Addbook.php     json=${req_body}    expected_status=200
    Dictionary Should Contain Key    ${response.json()}    ID
    ${book_id}=     Get From Dictionary    ${response.json()}    ID
    Set Global Variable    ${book_id}
    Should Be Equal As Strings    successfully added    ${response.json()}[Msg]

Add Duplicate Book Template
    [Arguments]     ${book_name}    ${isbn_value}   ${aisle_value}  ${author_name}
    &{req_body}=    Create Dictionary   name=${book_name}   isbn=${isbn_value}  aisle=${aisle_value} author=${author_name}
    &{response}=    POST    ${base_url}/Library/Addbook.php     json=${req_body}    expected_status=200
    Dictionary Should Contain Key    ${response.json()}    ID
    Should Be Equal As Strings    The Book with the entered Isbn and Aisle already Exists!!    ${response.json()}[Msg]
