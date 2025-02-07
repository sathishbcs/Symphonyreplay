*** Settings ***
Resource    ../Tests/Resource/Addon.robot
Task Tags   RBTLOGIN
Suite Setup    Addon.System Logon
Suite Teardown    Addon.System Logout
 
 
*** Test Cases ***
Check_Saint Transation Code
    Saint Transation Code
    Get Cell Text From SAP Table
  
Selecting the path for the Addon
    Patch selection for the Addon
    Important SAP note handling
    FOR ST/BNWVS 

Process Until Finish Button Visible
    Process Until Finish Button Visible




