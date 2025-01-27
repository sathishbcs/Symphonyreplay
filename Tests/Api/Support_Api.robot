*** Settings ***
Documentation     Executes API testing keywords.
...   Keywords created are based on http://bulkan.github.io/
...      robotframework-requests/doc/RequestsLibrary.html


*** Keywords ***
Execute request and return the response
    [Arguments]  ${url}  ${headers}
    ${response}=  Get Request  ${url}  ${headers}
    [return]	  ${response}

Check Response is valid
    [Arguments]  ${response}
    Should Be Equal As Strings      ${response.status_code}     200

Execute getrequest and return the response
    [Arguments]  ${alias}  ${uri}
    ${response}=  Get Request  ${alias}  ${uri}
    [return]	  ${response}

Check Status Code of Response
    [Arguments]  ${response}    ${statuscode}
    Should Be Equal As Strings      ${response.status_code}     ${statuscode}

Execute postrequest and return the response
    [Arguments]  ${alias}  ${uri}   ${body}     ${header}
    ${response}=    Post On Session    ${alias}  ${uri}     data=${body}     headers=${header}
    [return]	  ${response}

Create session with basicauthentication
    [Arguments]  ${alias}  ${url}   ${authentication}
    create session    ${alias}    ${url}      auth=${authentication}

Verify the json response
    [Arguments]  ${response}  ${valuetoverify}
    Dictionary should contain value     ${response.json()}     ${valuetoverify}