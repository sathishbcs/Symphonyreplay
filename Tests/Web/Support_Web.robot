*** Settings ***
Documentation     Executes web based tests.
...               Keywords created are based on http://robotframework.org/

*** Variables ***
${web_test}=      True

*** Keywords ***
Set chrome download preferences and open chrome browser
    ${prefs}=    Setup Chrome download preferences
    Create Webdriver for chrome preferences    &{prefs}

Set chrome download preferences and open headless chrome browser
    ${prefs}=    Setup Chrome download preferences
    Create Webdriver for chrome preferences    headless    &{prefs}

Setup Global Docker Execution Options
    Set Global Variable    ${global_browser_options}    None
    ${docker_check}=    Get Environment Variable    EXECUTION_ENVIRONMENT    not_found
    Run keyword And Return if    "${docker_check}"!="docker"    Log    Not executing on Docker
    @{options}=    Create List    --headless    --no-sandbox    --disable-dev-shm-usage
    Set Global Variable    @{docker_options}    @{options}

Setup Suite Metadata
    [Arguments]    ${browser}
    &{browser_information}=    Get Browser Metadata    browser=${browser}
    Set Suite Metadata    test_browser_name    ${browser}
    Set Suite Metadata    test_browser_version    ${browser_information.browser_version}
    Set Suite Metadata    test_driver_version    ${browser_information.driver_version}

Setup Docker Execution Options
    Setup Suite Metadata    ${browser}
    Setup Global Docker Execution Options
    Create Webdriver for chrome preferences

Create Chrome Options for download preferences
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    [Return]    ${chrome_options}

Setup Chrome download preferences
    # list of plugins to disable. disabling PDF Viewer is necessary
    # so that PDFs are saved rather than displayed
    ${disabled}    Create List    Chrome PDF Viewer
    ${prefs}    Create Dictionary    download.default_directory=${OUTPUT DIR}${/}${wvar('download_dir')}
    ...    plugins.plugins_disabled=${disabled}
    [Return]    ${prefs}

Update Docker Execution Options
    [Arguments]    @{list_prefs}
    ${docker_check}=    Run Keyword and Return Status
    ...    Variable Should Exist    ${docker_options}
    ${list_prefs_length}=    Get Length    ${list_prefs}
    ${list_prefs}=    Run Keyword If    ${docker_check} and ${list_prefs_length}>0 and ${list_prefs}[0] != []
    ...    Combine Lists    ${list_prefs}    ${docker_options}
    ...    ELSE IF    ${docker_check}    Set Variable    ${docker_options}
    ...    ELSE    Set Variable    ${list_prefs}
    [Return]    ${list_prefs}

Update Preferences List
    [Arguments]    ${chrome_options}    @{list_prefs}
    ${string_prefs}=    Convert To String    ${list_prefs}
    Return From Keyword If    ${string_prefs} == [[]]
    FOR    ${preference}    IN    @{list_prefs}
        Call Method    ${chrome_options}    add_argument    ${preference}
    END

Create options for chrome browser from list
    [Arguments]    @{additional_options}
    ${chrome_options}=    Create Chrome Options for download preferences
    FOR    ${preference}    IN    @{additional_options}
        Call Method    ${chrome_options}    add_argument    ${preference}
    END
    [Return]    ${chrome options}

Add options to global browser options from list
    [Arguments]    @{additional_options}
    ${docker_check}=    Run Keyword and Return Status
    ...    Variable Should Exist    ${global_browser_options}
    ${list_prefs}    Run Keyword If    ${docker_check}==False
    ...    ${global_browser_options}=    Create Chrome Options for download preferences
    FOR    ${preference}    IN    @{additional_options}
        Call Method    ${global_browser_options}    add_argument    ${preference}
    END
    [Return]    ${global_browser_options}

Create Webdriver for chrome preferences
    [Arguments]    @{list_prefs}    &{kw_prefs}
    ${list_prefs}=    Update Docker Execution Options    ${list_prefs}
    ${chrome_options}=    Create Chrome Options for download preferences
    Update Preferences List    ${chrome_options}    @{list_prefs}
    Call Method    ${chrome_options}    add_experimental_option    prefs    ${kw_prefs}
    Set Global Variable    ${global_browser_options}    ${chrome options}

Combine ${list1} and ${list2}
    ${newList}=    Create list
    FOR    ${item}    IN    @{list1}
        Append to list    ${newList}    ${item}
    END
    FOR    ${item}    IN    @{list2}
        Append to list    ${newList}    ${item}
    END
    [Return]    ${newList}

Move Most Recent Excel File
    [Arguments]    ${FROM_DIRECTORY}    ${TO_DIRECTORY}
    @{files}=    List Files In Directory    ${FROM_DIRECTORY}    [!~]*.xlsx
    ${fileListLength}=    Get length    ${files}
    Run keyword if    '${fileListLength}'=='0'    Fail    File download from Qlik not successful
    ${lastModifiedFile} =    Get From List    ${files}    0
    ${time1}=    OperatingSystem.Get Modified Time    ${FROM_DIRECTORY}    epoch
    FOR    ${file}    IN    @{files}
        log    ${file}
        ${time}    Get Modified Time    ${FROM_DIRECTORY}${/}${file}    epoch
        ${lastModifiedFile}    Set Variable If    ${time1} < ${time}    ${FROM_DIRECTORY}${/}${file}    ${lastModifiedfile}
        ${path}    ${lastModifiedFile}=    Split path    ${lastModifiedfile}
        ${time1}    Set Variable If    ${time1} < ${time}    ${time}    ${time1}
    END
    log    ${lastModifiedFile}
    log    ${FROM_DIRECTORY}
    Copy File    ${FROM_DIRECTORY}${/}${lastModifiedFile}    ${TO_DIRECTORY}
    Remove file    ${FROM_DIRECTORY}${/}${lastModifiedFile}

Wait for file download
    [Arguments]    ${directory}    ${wait_time_in_secs}
    [Documentation]    Waits for the file to be downloaded into the directory.
    ...    Assumes that the file should not have an extension .tmp
    ...    in the download directory.
    Wait Until Keyword Succeeds    ${wait_time_in_secs}    1s
    ...    File should exist    ${directory}\\[!~]*.xlsx
# Selenium Check functionality

Check ${property} ${value} contains strings from ${stringList}
    ${complete} =    get_text    ${property}=${value}
    Check part strings ${stringList} are displayed in ${complete}

Check part strings ${subStringList} are displayed in ${string}
    FOR    ${text}    IN    @{subStringList}
        should contain    ${string}    ${text}
    END

Check ${property} ${value} has value ${expected}
    ${actual} =    get_text    ${property}=${value}
    should contain    ${actual}    ${expected}

Check ${property} ${value} is present with no value
    ${actual} =    get_text    ${property}=${value}
    should be empty    ${actual}

Check ${property} ${value} has ${occurs} occurences
    ${actual} =    get_matching_xpath_count    ${property}=${value}
    Should Not Be Equal As Integers    ${occurs}    ${actual}

Check ${property} ${value} has more than ${occurs} occurence
    ${actual} =    get_matching_xpath_count    ${property}=${value}
    Should Be True    ${actual} > ${occurs}
# Click functionality

Click ${web_element} if present
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    ${web_element}
    Run Keyword If    ${present}    click element    ${web_element}
# Wait functionality

Wait Then Click Element
    [Documentation]    Wait until page contains supplied element and then Click the element.
    [Arguments]    ${element}
    Wait Until Page Contains Element    ${element}
    Click Element    ${element}

Wait Until Visible Then Click Element
    [Documentation]    Wait until element is visible and then Click the element.
    [Arguments]    ${element}
    Wait Until Element is Visible    ${element}
    Click Element    ${element}

Wait Until Visible Then Click Element With Retry
    [Documentation]    Wait until element is visible and then Click the element. Retry if fails.
    [Arguments]    ${element}
    Wait Until Keyword Succeeds    3x    1 sec    Wait Until Element is Visible    ${element}
    Click Element    ${element}

Wait Until Visible With Retry
    [Documentation]    Wait until element is visible. Retry if fails.
    [Arguments]    ${element}
    Wait Until Keyword Succeeds    3x    1 sec    Wait Until Element is Visible    ${element}

Wait Until Visible Then Get Element Text
    [Documentation]    Wait until element is visible and then get the text of the element.
    [Arguments]    ${element}
    Wait Until Element is Visible    ${element}
    ${ret}=    Get Text    ${element}
    [Return]    ${ret}

Wait Then Get Element Text
    [Documentation]    Wait until page contains the supplied element and then get the text of
    ...    the element.
    [Arguments]    ${element}
    Wait Until Page Contains Element    ${element}
    ${ret}=    Get Text    ${element}
    [Return]    ${ret}

Wait Then Assert Element Text
    [Documentation]    Wait until page contains the supplied element and make sure the text is the
    ...    same as that supplied.
    [Arguments]    ${element}    ${text}
    Wait Until Page Contains Element    ${element}
    Element Text Should Be    ${element}    ${text}

Wait Then Assert Element Contains Text
    [Documentation]    Wait until page contains the supplied element and make sure the text of the element
    ...    contains supplied text.
    [Arguments]    ${element}    ${text}
    Wait Until Page Contains Element    ${element}
    Element Should Contain Text    ${element}    ${text}

Wait Until Visible Then Assert Element Contains Text
    [Documentation]    Wait until page contains the supplied element and make sure the text of the element
    ...    contains supplied text.
    [Arguments]    ${element}    ${text}
    Wait Until Element is Visible    ${element}
    Element Should Contain Text    ${element}    ${text}

Wait Then Assert Stripped Text
    [Documentation]    Wait until page contains the supplied element and make sure the text is the
    ...    same as that supplied after both texts are stripped of special characters
    ...    (incl. spaces, html, new lines, carriage returns).
    [Arguments]    ${element}    ${text}
    Wait Until Page Contains Element    ${element}
    ${element_text}=    Get Text    ${element}
    Compare Stripped Strings    ${element_text}    ${text}

Wait Then Assert Stripped Text With Retry
    [Documentation]    Wait until page contains the supplied element (retry if it doesn't) and make sure the text is the
    ...    same as that supplied after both texts are stripped of special characters
    ...    (incl. spaces, html, new lines, carriage returns).
    [Arguments]    ${element}    ${text}
    Wait Until Keyword Succeeds    3x    1 sec    Wait Until Page Contains Element    ${element}
    ${element_text}=    Get Text    ${element}
    Compare Stripped Strings    ${element_text}    ${text}

Wait Until Enabled
    [Documentation]    Wait until page contains the supplied element and make sure it is enabled.
    [Arguments]    ${element}
    Wait Until Page Contains Element    ${element}
    Element Should Be Enabled    ${element}

Wait Until Enabled Then Assert Element Text
    [Documentation]    Wait until element is enabled and make sure the text is the
    ...    same as that supplied.
    [Arguments]    ${element}    ${text}
    Wait Until Page Contains Element    ${element}
    Element Should Be Enabled    ${element}
    Element Text Should Be    ${element}    ${text}

Run Keyword And Warn On Failure
    [Documentation]    Logs a warning when the given keyword fails. Does not fail the keyword.
    [Arguments]    ${keyword}    @{arguments}
    ${result}    ${output}=    Run Keyword And Ignore Error    ${keyword}    @{arguments}
    Run Keyword If    '${result}'!='PASS'
    ...    Run Keywords    Log    ${\n}Warning: Keyword '${keyword} @{arguments}' failed.    WARN
    ...    AND    Capture Page Screenshot
    [Return]    ${output}

Element Should Be Visible and Enabled
    [Documentation]    Checks element is enabled and visible.
    [Arguments]    ${element}
    Wait Until Element is Visible    ${element}
    Element Should Be Enabled    ${element}

########## Applitools Keywords ############
Initialize Visual Check
   [Documentation]  Create an Applitools test. This will start a session with the Applitools server.
   Eyes Open

Visual Check Window
    [Documentation]  Generate a screenshot of the current page and add it to the Applitools Test
    ...  Fully - a screenshot of everything that exists in the DOM at the point of calling eyesCheckWindow will be rendered
    [Arguments]  ${pageName}     ${sizeMode}
    Eyes Check Window  ${pageName}  ${sizeMode}

Close Visual Check
    [Documentation]  Close the applitools test and check that all screenshots are valid.
    ...   It is important to call this at the end of each test
    Eyes close async

Get All Visual Results
    [Documentation]  Get the test results for all the tests that were run
    ${result}=  Eyes Get All Test Results

Abort Visual Check
    [Documentation]  When a test is aborted, and it may be that not all of its checkpoints have excuted
    Eyes Abort Async

########## Saucelab web Keywords ############
Setup for Test App and Saucelabs
# VARIABLES SPECIFIC TO PROJECT TEST
# ... SHOULD BE DEFINE WITHIN PROJECT's SUPPORT OR DATA FILE
# ....OR DEFINE WITHIN PROJECT's RUN CONFIGURATION: example: -vars platform_version:"Android 8.0.0"
# ... OR DEFINE WITHIN OVERRIDING PROPERTIES IN JPM
    Set Test Variable   ${execution_name}        Xena_Saucelab_Web

#BELOW ONLY FOR RUN TEST IN LOCAL: ENTER YOUR SAUCELABS CREDENTIALS
    Set Test Variable       ${saucelabs_id}          <our saucelabs id>
    Set Test Variable       ${saucelabs_key}         <our saucelabs key>
    Set Test Variable   ${saucelabs_auth}        <your saucelab authorization>

Connect to Sauce Labs Chrome Browser
    ${sauceLabsServer}=    Set Variable    https://${saucelabs_id}:${saucelabs_key}${wvar('ServerSauceLabs')}
    log to console      ${sauceLabsServer}

launch the chrome browser
    [Arguments]   ${web_page}
    ${sauceLabsServer}=    Set Variable    https://${saucelabs_id}:${saucelabs_key}${wvar('ServerSauceLabs')}
    &{SAUCE_OPTIONS}    Create Dictionary
    ...    name=${execution_name}
    &{DESIRED_CAPABILITIES}    Create Dictionary
    ...    browserName=Chrome
    ...    platform=Windows 10
    ...    browserVersion=latest
    ...    sauce:options=&{SAUCE_OPTIONS}
    ${remote_url}    Set Variable    ${sauceLabsServer}
    Open Browser     ${web_page}
    ...    browser=${DESIRED_CAPABILITIES['browserName']}
    ...    remote_url=${remote_url}
    ...    desired_capabilities=${desired_capabilities}
    Sleep    5s
    SeleniumLibrary.capture page screenshot

Connect to Sauce Labs Safari Browser
    ${sauceLabsServer}=    Set Variable    https://${saucelabs_id}:${saucelabs_key}${wvar('ServerSauceLabs')}
    log to console      ${sauceLabsServer}

launch the safari browser
    [Arguments]   ${web_page}
    ${sauceLabsServer}=    Set Variable    https://${saucelabs_id}:${saucelabs_key}${wvar('ServerSauceLabs')}
    &{SAUCE_OPTIONS}    Create Dictionary
    ...    name=${execution_name}
    &{DESIRED_CAPABILITIES}    Create Dictionary
    ...    browserName=Safari
    ...    platform=macOS 12
    ...    browserVersion=15
    ...    sauce:options=&{SAUCE_OPTIONS}
    ${remote_url}    Set Variable    ${sauceLabsServer}
    Open Browser     ${web_page}
    ...    browser=${DESIRED_CAPABILITIES['browserName']}
    ...    remote_url=${remote_url}
    ...    desired_capabilities=${desired_capabilities}
    Sleep    5s
