*** Settings ***
Documentation     Support Cases object. This file should be
...				  populated ONLY with very generic, flexible functions and variables.
Resource          ../../Sample/Support_Sample.robot

*** Keywords ***
User Navigate to calculator browser datadriver
    [Arguments]  ${Cal_URL}  ${browser}
    Navigated to calculator browser datadriver  ${Cal_URL}  ${browser}

Navigated to calculator browser datadriver
    [Arguments]  ${Cal_URL}  ${browser}
    Set Chrome Options to open calculator  ${Cal_URL}  ${browser}
    Wait until the page has loaded successfully
    Take Screenshot    Selenium

Set Chrome Options to open calculator
    [Arguments]  ${Cal_URL}  ${browser}
    Open Browser    ${Cal_URL}  ${browser}    options=${global_browser_options}
    Maximize Browser Window

User reads data from excel for two numbers
    [Arguments]  ${Cal_URL}  ${browser}  ${random1}  ${random2}
    Read data from excel for two numbers  ${Cal_URL}  ${browser}  ${random1}  ${random2}

Read data from excel for two numbers
    [Arguments]  ${Cal_URL}  ${browser}  ${random1}  ${random2}
    Log    Opened ${Cal_URL} on browser ${browser}
    Log    First Number selected is ${random1}
    Set Test Variable    ${random1}
    Log    Second Number selected is ${random2}
    Set Test Variable    ${random2}
