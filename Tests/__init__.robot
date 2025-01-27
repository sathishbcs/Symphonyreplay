*** Settings ***
Documentation     Testing functionality through Robot Framework
Suite Setup       Setup highest level suite
Force Tags        Regression
Resource          Support.robot

*** Keywords ***
Setup highest level suite
    ${d.test_server}=    Set Variable    ${test_server}
    Reset screenshot count variable
    Set global Variable    ${screenshot_taking}    ${True}
    Setup linux execution
    Set Suite Metadata    environment    ${test_server}