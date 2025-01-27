*** Settings ***
Documentation     This is a sample user story.
...               The documentation here should ideally match the user story doc.
...               It only works if you have Web libraries enabled and the chromedriver
...               is available in the environment PATH. Jira-ID: AAAA-124
Suite Setup       Log to Console    Keyword is executed once before first test in the suite
Suite Teardown    Close All Browsers
Test Setup        Log to Console    This keyword is executed before every test
Test Teardown     Log to Console    This keyword is executed after every test
Force Tags        AAAA-124    Web
Resource          Support_Sample.robot

*** Test Cases ***
Visualization is received correctly
    [Documentation]    Test to check Visualization is working correctly
    [Tags]    selenium    uat
    Given I navigate to visualization website
    When I check for presence of data
    Then I can read the correct data is present
    [Teardown]    Close Browser
