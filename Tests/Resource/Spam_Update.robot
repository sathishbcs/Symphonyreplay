*** Settings ***    
Library    Process
Library    CustomSapGuiLibrary.py
Library    OperatingSystem
Library    String


*** Variables ***
# ${EXE_PAD}  C:\\Program Files (x86)\\SAP\\FrontEnd\\SAPgui\\saplogon.exe
# ${TITLE_PAD}    SAP Logon 760
# ${Connection_Name}  RBT
# ${SAP_CLIENT}   000
# ${SAP_USER}    DDIC
# ${SAP_PASSWORD}    Sym@rocks2023    

# System Variables
${certificate_id}    wnd[0]/sbar/pane[0]
${runtimeerror_id}    wnd[0]/titl    
${back_id}    wnd[0]/tbar[0]/btn[3]
${text_id}    wnd[1]/usr/lbl[5,2]        
${import_id}    wnd[1]/tbar[0]/btn[25]
${continue_id}    wnd[1]/tbar[0]/btn[0]
${no_Queue_id}    wnd[0]/usr/txtPAT100-STAT_LINE2
${spam_id}    wnd[0]/mbar/menu[0]/menu[2]
${epi_id}    wnd[0]/usr/txtPAT100-PATCH_STEP
${window_1_id}    wnd[1]/usr/lbl[5,3]      
${version_id}    wnd[0]/titl


*** Keywords ***
System Logon
    CustomSapGuiLibrary.Ensure Console Session
    Start Process    ${symvar('EXE_PAD')}
    Sleep   2
    Connect To Session
    Sleep    2
    Open Connection     ${symvar('Connection_Name')}
    Sleep   2
    Input Text    wnd[0]/usr/txtRSYST-MANDT    ${symvar('SAP_CLIENT')}
    Sleep    1
    Input Text    wnd[0]/usr/txtRSYST-BNAME    ${symvar('SAP_USER')}    
    Sleep    1
    Input Password    wnd[0]/usr/pwdRSYST-BCODE    %{SAP_PASSWORD} 
    # Input Password    wnd[0]/usr/pwdRSYST-BCODE    ${symvar('SAP_PASSWORD')}  

    Send Vkey    0
    Sleep    2
    
    ${logon_status}    Multiple logon Handling     wnd[1]   wnd[1]/usr/radMULTI_LOGON_OPT2

    IF    '${logon_status}' == "Multiple logon found. Please terminate all the logon & proceed"
        Log To Console    **gbStart**logon_status**splitKeyValue**${logon_status}**gbEnd**
    END
    Sleep   1


Spam Transaction
    Run Transaction     /nspam  
    Sleep    5
    Take Screenshot    01_spam.jpg

Certificate Verification
    Get Maintenance Certificate Text    wnd[0]/sbar/pane[0]
    Sleep    2
    Take Screenshot    02_certficate1.jpg
    CustomSapGuiLibrary.get maintenance certificate text    ${certificate_id}    
    Take Screenshot    03_certificate2.jpg
    

Loading package
    #Clicking Application server to load packages
    Click Element    wnd[0]/mbar/menu[0]/menu[0]/menu[1]
    Sleep    2
    Take Screenshot    04_loading_1.jpg
    #Asks for confirmation to upload
    Click Element    wnd[1]/usr/btnSPOP-OPTION1
    Sleep    2
    Take Screenshot    05_loading_2.jpg
    #Step back to Support package manager screen
    Click Element    wnd[0]/tbar[0]/btn[3]
    Sleep    2
    Take Screenshot    06_loading_3.jpg

Import Spam/Saint update
    Click Element    wnd[0]/mbar/menu[0]/menu[2]
    Take Screenshot    07_SPM1.jpg
    Click Element    wnd[1]/tbar[0]/btn[25]
    Take Screenshot    08_SPM2.jpg
    ${content}    CustomSapGuiLibrary.Run Time Error Existing    ${runtimeerror_id}    ${back_id}    
    Log    The window name is: ${content}
    Take Screenshot    09_runtimeerror.jpg

    Run Transaction     spam  
    Sleep    5
    Take Screenshot    10_spam.jpg  

    # #EPILOGUE HANDLING
    CustomSapGuiLibrary.Epilogue Handling   ${epi_id}   ${spam_id}  ${window_1_id}  ${import_id}
    Take Screenshot    11_SPM3.jpg  
    # #Restart SPAM and read the current information button for Epilogue
    Click Element    wnd[1]/tbar[0]/btn[0]
    Take Screenshot    12_SPM4.jpg
      
    Run Transaction     spam  
    Sleep    5
    Take Screenshot    13_spam5.jpg
    CustomSapGuiLibrary.No Queue Pending    ${no_Queue_id}
    Sleep   5
    
    CustomSapGuiLibrary.Version Print   ${version_id}
    Take Screenshot    14_spam6.jpg

System Logout
    Run Transaction   /nex
    Sleep    5