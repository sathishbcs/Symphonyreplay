*** Settings ***
Documentation       Multiple data set run using DataDriver. Jira-ID: AGKL-659
Suite Teardown      Close All Browsers

Resource            ../../Sample/Datadriver/Support.robot

# Install dependency by running command "pip install -U robotframework-datadriver[XLS]"
# Give excel path and sheet name where data need to be read
Library             DataDriver  ${CURDIR}//TextExcel.xlsx  sheet_name=Addition

*** Test Cases ***
Add two number with datadriver
    [Documentation]  Test Objective: To test multiple data set with single test case using datadriver.
    [Tags]  DatadriverTest
    [Template]  Add two numbers

*** Keywords ***
Add two numbers
    [Arguments]  ${Cal_URL}  ${browser}  ${random1}  ${random2}
    Given User Navigate to calculator browser datadriver  ${Cal_URL}  ${browser}
    When User reads data from excel for two numbers  ${Cal_URL}  ${browser}  ${random1}  ${random2}
    Then User adds the selected numbers
    And The result of operation is as expected

