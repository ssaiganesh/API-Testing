*** Settings ***
Library  RequestsLibrary
Library  Collections
Library  OperatingSystem
Library  JSONLibrary
# Suite Setup       # can start db
# Test Setup        # maybe can run some dependency api or configuration for the specific test
# Test Teardown     # reset back to before the test setup was done
# Suite Teardown    # clear db of the changes made
# Resource          # Files referenced to




*** Variables ***
${base_url}     https://simple-books-api.glitch.me
#   Base URL for all the API endpoints tested in this suite.
#   Endpoint is the address where API is hosted on teh server.


*** Test Cases ***
Status 200 and should be OK
    [Documentation]     Checks if API is working    # log includes this documentation to explain the test case

    ${response}=  GET  ${base_url}/status       expected_status=200
    Should Be Equal As Strings    ${response.json()}[status]    OK

#     HTTP Status Codes Reference Link: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
#     We assert the HTTP Status for the different endpoints to ensure our API request has been sent correctly
#     JSON Response:
#        {
#            "status" : "OK"
#        }

Register
    [Documentation]    Registers user to use access token for authorization

    ${body}=  create dictionary  clientName=e2sai  clientEmail=e2sai@email.com.sg
    ${header}=  create dictionary  Content-Type=application/json
    ${response}=  POST  ${base_url}/api-clients  json=${body}  headers=${header}    expected_status=201
    ${bearer_token_list}=  get value from json  ${response.json()}  $.accessToken
    ${bearer_token}=  catenate  Bearer  ${bearer_token_list[0]}
    ${bearer_token}=  convert to string  ${bearer_token}
    # will be used for Authorization header
    set global variable  ${bearer_token}


Get List of Books
    [Documentation]     Gets list of non-fiction books and checks the first book that's available

    ${response}=  GET  ${base_url}/books  params=type=non-fiction  expected_status=200
    FOR    ${book}    IN    @{response.json()}
        IF    ${book}[available] == True
            ${bookId}=  Get Value From Json    ${book}    $.id
            END
        END
    Set Global Variable    ${bookId}
    Should Be Equal As Strings    ${book}[type]    non-fiction
    Should Be Equal As Strings    ${book}[available]    True

Get Single Book
    [Documentation]     Checks information on the book saved from previous test case

    ${book_url}=    Catenate    SEPARATOR=    ${base_url}/books/     ${book_id}[0]
    # Have to catenate path variable, can set as suite or global variable if needed for other testcases
    # SEPARATOR=    needed to remove any space between url and path variable
    ${response}=    GET   ${book_url}    expected_status=200
    Should Not Be Equal As Numbers    ${response.json()}[current-stock]    0

Order Book
    [Documentation]     Orders the book that was saved previously

    ${headers}  create dictionary  Authorization=${bearer_token}   Content-Type=application/json
    ${req_body}=  create dictionary  bookId=${bookId}  customerName=sai ganesh
    ${response}=  POST  ${base_url}/orders  json=${req_body}  headers=${headers}    expected_status=201
    Should Be Equal As Strings    ${response.json()}[created]    True
    ${orderId}=     Get Value From Json    ${response.json()}    $.orderId
    Set Suite Variable    ${orderId}



Update Customer Name In Order
     [Documentation]        Updates customer name in order, gets the order to check if name udpated

    ${order_url}=   Catenate    SEPARATOR=  ${base_url}/orders/   ${orderId}[0]
    Set Suite Variable    ${order_url}

    ${headers}  create dictionary  Authorization=${bearer_token}   Content-Type=application/json
    ${req_body}=  create dictionary  customerName=shankar
    ${response}=  PATCH  ${order_url}  json=${req_body}  headers=${headers}   expected_status=204
    ${get_response}=  GET  ${order_url}   headers=${headers}
    Should Be Equal As Integers    ${get_response.json()}[bookId]    ${bookId}[0]
    should be equal as strings  ${get_response.json()}[customerName]  shankar

Delete Order
    [Documentation]     Deletes order and gets order to check if error is handled

    ${headers}  create dictionary  Authorization=${bearer_token}   Content-Type=application/json
    ${response}=  DELETE  ${order_url}  headers=${headers}      expected_status=204
    ${get_response}=  GET  ${order_url}   headers=${headers}    expected_status=404
    Dictionary Should Contain Key    ${get_response.json()}    error

