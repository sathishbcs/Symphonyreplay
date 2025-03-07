*** Settings ***
Resource    ../Tests/Resource/Spam_Patch_enhance.robot
Test Tags   spampatchenhance
Suite Setup    Spam_Patch_enhance.System Logon
Suite Teardown    Spam_Patch_enhance.System Logout
  
*** Test Cases ***

Check_Spam_update
    Spam Transaction
    Certificate Verification
    Loading package
    Display/Define
    Spam Component selection
    Spam Patch selection

    # Spam software selection
    Important SAP note handling

Import Queue
    Importing queue from support package
    Start Options
    Import Option
    Confirm Queue




    





