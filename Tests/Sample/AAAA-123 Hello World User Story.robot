*** Settings ***
Documentation     Checks for setup to work correctly. Jira-ID: AAAA-123
Suite Setup       Log to Console    Keyword is executed once before first test in the suite
Suite Teardown    Log to Console    Keyword is executed once after last test in the suite
Test Setup        Log to Console    This keyword is executed before every test
Test Teardown     Log to Console    This keyword is executed after every test
Force Tags        AAAA-123    SampleTest    debug_listener_messages
Resource          Support_Sample.robot

*** Test Cases ***
Hello World is tested correctly
    [Documentation]    Test to check that the setup is working currently through string
    [Tags]    helloworld    regression
    Given I concatenate hello with world
    Then I receive result as helloworld
