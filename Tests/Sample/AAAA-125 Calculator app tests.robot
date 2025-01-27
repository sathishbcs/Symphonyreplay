*** Settings ***
Documentation     Tests Calculator app functionality. Jira-ID: AAAA-125
Suite Setup       Navigate to calculator browser
Suite Teardown    Close All Browsers
Test Setup        Reset the calculator
Force Tags        AAAA-125    Calculator    debug_listener_messages
Resource          Support_Sample.robot

*** Test Cases ***
Addition is tested successfully
    [Documentation]    Test to check Addition on calculator is working correctly
    [Tags]    addition
    Given User selects two random number
    When User adds the selected numbers
    Then The result of operation is as expected

Subtraction is tested successfully
    [Documentation]    Test to check if subraction of two number is successful
    [Tags]    subtraction
    Given User selects two random number
    When User subracts second number from first
    Then The result of operation is as expected

Multiplication is tested successfully
    [Documentation]    Test to check if multiplication of two number is successful
    [Tags]    multiplication
    Given User selects two random number
    When User multiplies the selected numbers
    Then The result of operation is as expected

Division is tested successfully
    [Documentation]    Test to check if division of two number is successful
    [Tags]    division
    Given User selects two random number
    When User divides second number by first
    Then The result of operation is as expected

Division by Zero
    [Documentation]    Test to check if division of a number by zero is possible
    [Tags]    divide_by_zero
    Given User selects a random number
    When User divides the number by zero
    Then The result of operation is as expected

Multiplication of float numbers
    [Documentation]    Test to check if multiplication of two float numbers is successful
    [Tags]    float_multiplication
    Given User selects two random float numbers
    When User multiplies the selected numbers
    Then The result of operation is as expected

Clear of state
    [Documentation]    Test to check if clear of state is possible
    [Tags]    clear_state
    Given User Enters a number into calculator
    When User clears the calculator
    Then The state of calculator is cleared

Negation of number sign
    [Documentation]    Test to check if negation of number is possible
    [Tags]    number_negation
    Given User Enters a number into calculator
    When User negates its sign
    Then The sign of number entered is reversed

Large number addition
    [Documentation]    Test to check addition of large number is successful
    [Tags]    large_number_add
    Given User selects two large random numbers
    When User adds the selected numbers
    Then The result of operation is as expected

Large number multiplication
    [Documentation]    Test to check multiplication of large number is successful
    [Tags]    large_number_multiply
    Given User selects two large random numbers
    When User multiplies the selected numbers
    And Result is converted for comparison
    Then The result of large multiplication operation is as expected
