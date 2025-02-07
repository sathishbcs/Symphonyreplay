*** Settings ***
Resource    ../Tests/Resource/Spam_Update.robot
Task Tags   spamupdate
Suite Setup    Spam_Update.System Logon
Suite Teardown    Spam_Update.System Logout
 
 
*** Test Cases *** 
Check_Spam_update
    Spam Transaction
    Certificate Verification
    Loading package
    Import Spam/Saint update
    
    





