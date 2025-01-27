*** Settings ***
Documentation     Support Sample tests
Resource          ../Support.robot

*** Keywords ***
I concatenate hello with world
   Concatenates hello with world

Concatenates hello with world
    Set suite variable    ${result}    helloworld

I receive result as helloworld
    Results received as helloworld

Results received as helloworld
    Should be equal    ${result}    helloworld

I navigate to visualization website
    Navigated to visualization website

Navigated to visualization website
    Open Browser    ${wvar('robot_site')}    ${browser}    options=${global_browser_options}
    Log    Opened ${wvar('robot_site')} on browser ${browser}

I check for presence of data
    checks for data presence in website

checks for data presence in website
    Element Should Be Visible    ${wvar('robot_check_id')}
    Take Screenshot    Selenium

I can read the correct data is present
    Correct data is present

Correct data is present
    Check xpath ${wvar('robot_loc_value_id')} has value Robot Framework

Navigate to calculator browser
    Open page to calculator in browser
    Wait until the page has loaded successfully

Navigate to calculator browser headless
    Set Chrome Options to open calculator headless
    Wait until the page has loaded successfully

Set Chrome Options to open calculator headless
    Open Browser    ${wvar('calculator_url')}    headlesschrome    options=${global_browser_options}
    Maximize Browser Window

Open page to calculator in browser
    ${options}=    Add options to global browser options from list    --incognito
    Open Browser    ${wvar('calculator_url')}    ${browser}    options=${options}

Wait until the page has loaded successfully
    Wait until page contains element    ${wvar('page_loaded_check')}

Reset the calculator
    Click calculator button    ${wvar('reset_button')}

Click calculator button
    [Arguments]    ${button}
    ${button_xpath}=    Format String    ${wvar('button_format')}    ${button}
    click element    ${button_xpath}

User selects two random number
    Log    Opened ${wvar('calculator_url')} on browser ${browser}
    Select first random number
    Log    First Number selected is ${random1}
    Select second random number
    Log    Second Number selected is ${random2}

User selects a random number
    Log    Opened ${wvar('calculator_url')} on browser ${browser}
    Select first random number
    Log    Number selected is ${random1}

User Enters a number into calculator
    Log    Opened ${wvar('calculator_url')} on browser ${browser}
    Select first random number
    Enter number ${random1} into calculator

User selects two random float numbers
    Log    Opened ${wvar('calculator_url')} on browser ${browser}
    Selected two random float numbers

Selected two random float numbers
    ${random1}=    Get a random float number
    ${random2}=    Get a random float number
    Set Test Variable    ${random1}
    Set Test Variable    ${random2}

User selects two large random numbers
    Log    Opened ${wvar('calculator_url')} on browser ${browser}
    Select first large random number
    Log    First large number selected is ${random1}
    Select second large random number
    Log    Second large number selected is ${random2}

Select first random number
    ${random1}=    Get a random number
    Set Test Variable    ${random1}

Select second random number
    ${random2}=    Get a random number
    Set Test Variable    ${random2}

Select first large random number
    ${random1}=    Get a large random number
    Set Test Variable    ${random1}

Select second large random number
    ${random2}=    Get a large random number
    Set Test Variable    ${random2}

Get a large random number
    ${random}=    Evaluate    random.randint(-1000000000, 1000000000)    modules=random
    ${random}=    Run keyword if    ${random} < 1000000    Evaluate    ${random}*1000000
    ...    ELSE    get variable value    ${random}
    [Return]    ${random}

Get a random float number
    [Documentation]    Generates a random float number number
    ${random_number}=    Evaluate    random.random()    modules=random
    ${random_number}=    convert to number    ${random_number}
    ${random_number}=    Evaluate    ${random_number} * ${100}
    ${random_number}=    Evaluate    round(${random_number}, 2)
    [Return]    ${random_number}

Get a random number
    [Documentation]    Generates a random number
    ${random_number}=    Evaluate    random.randint(-1000000, 1000000)    modules=random
    [Return]    ${random_number}

User adds the selected numbers
    Enter the numbers into calculator with operation +
    Add the random generated numbers to get result

User subracts second number from first
    Enter the numbers into calculator with operation -
    Subtract the random generated numbers to get result

User multiplies the selected numbers
    Enter the numbers into calculator with operation x
    Multiply the random generated numbers to get result

Result is converted for comparison
    Coverted results to desired format for comparision

Coverted results to desired format for comparision
    ${calculator_result}=    Read value of result from calculator
    ${result}=    Get base value of large number    ${result}
    ${calculator_result}=    Evaluate    str(${calculator_result})[:6]
    ${calculator_result}=    convert to number    ${calculator_result}
    ${calculator_result}=    Evaluate    round(float(${calculator_result}), 2)
    set test variable    ${result}
    set test variable    ${calculator_result}

Get base value of large number
    [Arguments]    ${number}
    ${negative}=    Run keyword if    ${number} < 0    set variable    True
    ${number}=    Run keyword if    ${negative}    Set Variable    ${number}*-1
    ...    ELSE    Set Variable    ${number}
    ${str_number}=    Evaluate    str(${number})
    ${base}=    get length    ${str_number}
    ${number}=    Evaluate    ${number} / (10 ** (${base} - 1))
    ${number}=    Evaluate    round(${number}, 2)
    ${number}=    Run keyword if    ${negative}    Evaluate    ${number}*-1
    ...    ELSE    get variable value    ${number}
    [Return]    ${number}

User divides second number by first
    Enter the numbers into calculator with operation ÷
    Divide the random generated numbers to get result

User divides the number by zero
    Divided the number by zero

Divided the number by zero
    set test variable    ${random2}    0
    ${result}=    Convert to Number    0
    set test variable    ${result}

User clears the calculator
    Reset the calculator

User negates its sign
    Clicked on negate sign

Clicked on negate sign
    Click calculator button    ${wvar('negation_sign')}

Enter the numbers into calculator with operation ${operation}
    Enter number ${random1} into calculator
    Take Screenshot    Selenium
    Enter operation ${operation} into calculator
    Enter number ${random2} into calculator
    Take Screenshot    Selenium
    Enter equal to sign into calculator

Enter number ${number} into calculator
    ${str_number}=    Convert to String    ${number}
    @{list_number}=    Split String To Characters    ${str_number}
    ${negation}=    set variable if    "${list_number}[0]" == "-"    True
    @{list_number}=    Run Keyword If    ${negation}    Remove negative sign    @{list_number}
    ...    ELSE    Set variable    @{list_number}
    FOR    ${character}    IN    @{list_number}
        Click calculator button    ${character}
    END
    Run Keyword If    ${negation}    User negates its sign

Remove negative sign
    [Arguments]    @{numbers}
    @{numbers}=    set variable    ${numbers}[1:]
    [Return]    @{numbers}

Enter operation ${operation} into calculator
    Click calculator button    ${operation}

Enter equal to sign into calculator
    Click calculator button    ${wvar('equal_sign')}

Add the random generated numbers to get result
    ${result}=    Evaluate    ${random1} + ${random2}
    Set Test Variable    ${result}

Subtract the random generated numbers to get result
    ${result}=    Evaluate    ${random1} - ${random2}
    Set Test Variable    ${result}

Multiply the random generated numbers to get result
    ${result}=    Evaluate    ${random1} * ${random2}
    ${result}=    Evaluate    round(${result}, 2)
    Set Test Variable    ${result}

Divide the random generated numbers to get result
    ${result}=    Evaluate    ${random1} / ${random2}
    ${result}=    Evaluate    round(${result}, 2)
    Set Test Variable    ${result}

The result of operation is as expected
    Verify result of operation is correct
    Log    Result of ${random1} and ${random2} test is: ${result}

The result of large multiplication operation is as expected
    Verify result of large multiplication operation is correct
    Log    Result of ${random1} and ${random2} test is: ${result}

The state of calculator is cleared
    ${calculator_result}=    Read value of result from calculator
    should be equal    ${0.0}    ${calculator_result}

The sign of number entered is reversed
    Reversed sign of number entered

Reversed sign of number entered
    ${calculator_result}=    Read value of result from calculator
    ${calculator_result}=    Convert To Integer    ${calculator_result}
    ${calculator_result}=    Evaluate    ${calculator_result} * ${-1}
    should be equal    ${random1}    ${calculator_result}

Verify result of operation is correct
    Take Screenshot    Selenium
    ${calculator_result}=    Read value of result from calculator
    ${calculator_result}=    evaluate    round(${calculator_result}, 2)
    should be equal    ${result}    ${calculator_result}

Verify result of large multiplication operation is correct
    Take Screenshot    Selenium
    should be equal    ${result}    ${calculator_result}

Read value of result from calculator
    ${calculator_result}=    Get Text    ${wvar('calculator_result')}
    ${calculator_result}=    Convert To Number    ${calculator_result}
    [Return]    ${calculator_result}

Addition Template is tested through this
    [Arguments]    ${var1}
    Given User selects two random number
    When User adds the selected numbers
    Then The result of operation is as expected
