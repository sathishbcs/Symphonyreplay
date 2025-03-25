*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    CustomSapGuiLibrary.py
Library    PDF.py

*** Variables ***
# ${search_comp}    ST-PI
# ${search_patch}    SAPK-74010INSTPI
${continue_id}    wnd[1]/tbar[0]/btn[0]
${text_id}    wnd[1]/usr/txtMESSTXT1
${no_Queue_id}    wnd[0]/usr/txtPAT100-STAT_LINE2
${interrupt_str1}    Perform Adjustment
${transport_id}    wnd[0]/tbar[1]/btn[19]
${status_line}    wnd[0]/usr/txtPAT100-PATCH_STEP
${startoption_spam_id}    wnd[1]/tbar[0]/btn[27]
${radio_button_id}    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC4/ssubSTART_OPTIONS_SCA:SAPLOCS_UI:0704/radLAY0700-RB4_DIA
${startoptionok_id}    wnd[1]/tbar[0]/btn[0]
${Import_id}    wnd[1]/tbar[0]/btn[25]
${error_button_id}    wnd[0]/tbar[1]/btn[20]
${finish_str}   Confirm queue
# ${status_line}    wnd[0]/usr/sub:SAPLSAINT_UI:0100/txtWA_COMMENT_TEXT-LINE[0,0]
${refresh_id}   wnd[0]/tbar[1]/btn[30]
${button_id}    wnd[0]/mbar/menu[0]/menu[5]
${comp_id}    wnd[1]/usr/tabsQUEUE_CALC/tabpQUEUE_CALC_FC1/ssubQUEUE_CALC_SCA:SAPLOCS_ALV_UI:0306/cntlCONTROL_ALL_COMP/shellcont/shell
${screenshot_directory}     ${OUTPUT_DIR}
# ${comp_id}    wnd[1]/usr/cntlCOMP_ONLY_CONTROL/shellcont/shell
${output_pdf}   ${OUTPUT_DIR}\\output.pdf

*** Keywords *** 
System Logon
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
    Take Screenshot   02_Certificate.jpg
 
Loading package    
    CustomSapGuiLibrary.Click Element    wnd[0]/mbar/menu[0]/menu[0]/menu[1]
    Sleep    2
    Take Screenshot    03_Load_1.jpg
    CustomSapGuiLibrary.Click Element    wnd[1]/usr/btnSPOP-OPTION1
    Sleep    2
    Take Screenshot    04_Load_2.jpg
    CustomSapGuiLibrary.Click Element    wnd[0]/tbar[0]/btn[3]
    Sleep    2
    Take Screenshot    05_Load_3.jpg
 
Display/Define
    CustomSapGuiLibrary.Click Element    wnd[0]/usr/btnPAT100-QUEUE
    Sleep    2
    Take Screenshot    06_Display.jpg

Spam software selection
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[7]
    Sleep    2
    Take Screenshot    07_F01_patch_1.jpg
    CustomSapGuiLibrary.Spam Multiple Patch Version Select    ${comp_id}    ${symvar('search_comp')}    ${symvar('search_patch')}
    # CustomSapGuiLibrary.Spam Multiple Patch Version Select    ${comp_id}    ${search_comp}    ${search_patch}
    Sleep    4
    Take Screenshot    08_F02_patch_2.jpg
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep    2
    Take Screenshot    09_F03_patch_3.jpg
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep    2
    Take Screenshot    10_F04_patch_4.jpg
 
Important SAP note handling
    CustomSapGuiLibrary.Is Imp Notes Existing  wnd[2]  wnd[2]/tbar[0]/btn[0]
    Sleep   2
    # CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[0]
    Take Screenshot    11_SAP_note.jpg
    CustomSapGuiLibrary.Click Element    wnd[1]/usr/btnBUTTON_2
    Sleep   2
    Take Screenshot    12_Modification.jpg  
    
Importing queue from support package
    CustomSapGuiLibrary.Click Element    wnd[0]/mbar/menu[0]/menu[3]
    Sleep   2
    Take Screenshot    13_Imp_que_1.jpg
    CustomSapGuiLibrary.Is Imp Notes Existing  wnd[1]  wnd[1]/tbar[0]/btn[0]
    Sleep   2
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[27] 
    Sleep   2
    Take Screenshot    14_Imp_que_2.jpg
 
Start Options
    CustomSapGuiLibrary.Select Radio Button    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC1/ssubSTART_OPTIONS_SCA:SAPLOCS_UI:0701/radLAY0700-RB1_DIA
    Sleep   2
    Take Screenshot    15_prep_dial.jpg
    CustomSapGuiLibrary.Click Element    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC2
    Sleep   2
    Take Screenshot    16_import_select.jpg
    CustomSapGuiLibrary.Select Radio Button    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC2/ssubSTART_OPTIONS_SCA:SAPLOCS_UI:0702/radLAY0700-RB2_BTCHIM
    Sleep   2
    Take Screenshot    17_import_bkgd.jpg
 
Import Option
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep   1
    Take Screenshot    18_import1.jpg    
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[25]
    Take Screenshot    19_import2.jpg
    Sleep    2
    # CustomSapGuiLibrary.is errors during disassembling existing    wnd[0]   wnd[0]/tbar[1]/btn[20]
    # Sleep    2
    # Take Screenshot    021_ignore.jpg
    CustomSapGuiLibrary.is spam user defined existing    wnd[1]    wnd[1]/tbar[0]/btn[0]        
    Sleep    2
    Take Screenshot    20_User_defined.jpg
 
Confirm Queue
    ${cell_text_1}    CustomSapGuiLibrary.Get Finish Cell Text1    ${finish_str}    ${interrupt_str1}    ${transport_id}    ${button_id}    ${status_line}    ${refresh_id}    ${startoption_spam_id}    ${radio_button_id}    ${startoptionok_id}    ${Import_id}    ${error_button_id}
    Log    ${cell_text_1}
    Sleep   2
    Take Screenshot    21_Confirmed_queue.jpg
    CustomSapGuiLibrary.No Queue Pending    ${no_Queue_id}
    Sleep   2
    Take Screenshot    22_Status_Confirmed_queue1.jpg
    CustomSapGuiLibrary.Click Element   wnd[1]/tbar[0]/btn[27]
    Sleep   2
    Take Screenshot    23_Status_Confirmed_queue2.jpg
 
System Logout
    Run Transaction   /nex
    Sleep    2
    Create Pdf    ${screenshot_directory}   ${output_pdf}    
    Sleep   2