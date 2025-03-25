*** Settings ***
Resource    ../Tests/Resource/Spam_Patch.robot
Task Tags   spampatch
Suite Setup    Spam_Patch.System Logon
Suite Teardown    Spam_Patch.System Logout
 
*** Test Cases *** 
Check_Spam_update
    Spam Transaction
    Certificate Verification
    Loading package
    Display/Define
    Spam Component selection
    Spam Patch selection
    Important SAP note handling

# Import Queue
#     Importing queue from support package
#     Confirm Queue




    





