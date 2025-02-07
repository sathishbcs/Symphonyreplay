*** Settings ***
Resource    ../Tests/Resource/Spam_Patch_enhance.robot
Task Tags   spampatchenhance
Suite Setup    Spam_Patch_enhance.System Logon
# Suite Teardown    Spam_Patch_enhance.System Logout
  
*** Test Cases ***

Check_Spam_update
    Spam Transaction
    Certificate Verification
    Loading package
    Display/Define
    Spam software selection
    Important SAP note handling

Import Queue
    Importing queue from support package
    Confirm Queue




    





