*** Settings ***
Documentation    Imports libraries and gets the setup ready for execution.
Library           SeleniumLibrary
Library           Screenshot
Library            ../Library/BrowserSupport.py
Library           RequestsLibrary
Library           json
Library        SapGuiLibrary
Library           OperatingSystem
Library           String
Library           Process
Library           Collections
# Resource          Api/Support_Api.robot
Resource          Web/Support_Web.robot


*** Keywords ***
Set up screenshot directory
    Create directory  ${OUTPUTDIR}${/}${wvar('screenshot_dir')}

Take Screenshot
    [Arguments]    ${module}
    [Documentation]    Expects arguments as Selenium or Appium to control which type of 
    ...    screenshot to take for the action
    Run Keyword If		${screenshot_taking}    Take a Screenshot  ${module}

Take a Screenshot
    [Arguments]    ${module}
    ${Result}=  Run Keyword And Return Status  Take ${module} screenshot at Test Level
    Run Keyword If	${Result}==${False}  Take ${module} Screenshot at Suite Level
	Add to screenshot count

Take Selenium Screenshot at Test Level
    Capture page screenshot  ${OUTPUTDIR}${/}${wvar('screenshot_dir')}${/}${TEST NAME}_${screenshotCount}.png

Take Selenium Screenshot at Suite Level
    Capture page screenshot  ${OUTPUTDIR}${/}${wvar('screenshot_dir')}${/}${SUITE NAME}_${screenshotCount}.png

Take Appium Screenshot at Test Level
    Capture page screenshot  ${OUTPUTDIR}${/}${mvar('screenshot_dir')}${/}${TEST NAME}_${screenshotCount}.png

Take Appium Screenshot at Suite Level
    Capture page screenshot  ${OUTPUTDIR}${/}${mvar('screenshot_dir')}${/}${SUITE NAME}_${screenshotCount}.png

Add to screenshot count
    ${current_counter}=     evaluate    int("${screenshotCount}".rsplit("_", 1)[1])+1
	${screenshotCount}=  Set variable  ${PABOTQUEUEINDEX}_${current_counter}
	Set global variable  ${screenshotCount}

Reset screenshot count variable
	${screenshotCount}=  Set variable  ${PABOTQUEUEINDEX}_1
	Set global variable  ${screenshotCount}
	Set up screenshot directory
	
Turn Screenhots Off
    Set global variable  ${screenshot_taking}  ${FALSE}

Turn Screenhots On
    Set global variable  ${screenshot_taking}  ${TRUE}

Setup linux execution
    ${web_test_check}=      Run Keyword and Return Status    Variable Should Exist       ${web_test}
    Run keyword if      ${web_test_check}     Setup Docker Execution Options

Log file to report ${filepath}
	Log	<msg src="${filepath}">img src="${filepath}"</msg>	HTML

Update test log information
    [Arguments]     ${update_dictionary}
    ${test_data_dict}=     get variable value  ${test_data_dict}     ${None}
    ${test_data_dict}=  Run Keyword If   ${test_data_dict}==${None}   get variable value  ${update_dictionary}     ${None}
    ...     ELSE    Add values to test data dict  ${update_dictionary}  ${test_data_dict}
    set test variable    ${test_data_dict}

Add values to test data dict
    [Arguments]         ${update_dictionary}        ${test_data_dict}
    FOR    ${key}   IN    @{update_dictionary.keys()}
        Run Keyword if    ${test_data_dict}["${key}"]        Set variable    ${test_data_dict}["${key}"]
             ${test_data_dict}["${key}"]:${update_arguments}["${key}"]
        ELSE    ${test_data_dict}["${key}"]    Set variable      ${update_arguments}["${key}"]
    END
    [Return]  ${test_data_dict}
