*** Settings ***
Library    Process
Library    CustomSapGuiLibrary.py
Library    OperatingSystem
Library    String
Library    PDF.py


*** Variables ***

# System Variables
${interrupt_str1}    Installation interrupted to process the modification adjustment
${interrupt_str2}    The Add-on installation terminated during phase RUN_SPAU_?
${finish_str}    The Add-on was successfully imported with the displayed queue
${continue_id}    wnd[0]/usr/btnBUTTON_NEXT
${startoption_id}    wnd[1]/tbar[0]/btn[27]
${radio_button_id}    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC4/ssubSTART_OPTIONS_SCA:SAPLOCS_UI:0704/radLAY0700-RB4_DIA
${startoptionok_id}    wnd[1]/tbar[0]/btn[0]
${Import_id}    wnd[1]/tbar[0]/btn[25]
${error_button_id}    wnd[0]/tbar[1]/btn[20]
${button_id}    wnd[0]/usr/btnBUTTON_NEXT
${status_line}    wnd[0]/usr/sub:SAPLSAINT_UI:0100/txtWA_COMMENT_TEXT-LINE[0,0]
${refresh_id}    wnd[0]/tbar[1]/btn[30]
${certificate_id}    wnd[0]/sbar/pane[0]
${screenshot_directory}     ${OUTPUT_DIR}
${output_pdf}   ${OUTPUT_DIR}\\output.pdf
${addon}    ST-A/PI
${Patch}    K-01VC3INSSA    
 
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
 
Saint Transation Code
    CustomSapGuiLibrary.Run Transaction     Saint  
    Sleep    2
    CustomSapGuiLibrary.Take Screenshot    02_saintfrontpage.jpg
    Sleep    1
    CustomSapGuiLibrary.get maintenance certificate text    ${certificate_id}    
    CustomSapGuiLibrary.Take Screenshot    03_certificate.jpg
    Sleep   5
    Click Element    wnd[0]/mbar/menu[0]/menu[0]/menu[1]
    Sleep    3
    CustomSapGuiLibrary.Click Element    wnd[1]/usr/btnBUTTON_1
    Sleep    3  
    CustomSapGuiLibrary.Click Element    wnd[0]/tbar[0]/btn[3]
    Sleep    10
    CustomSapGuiLibrary.Take Screenshot    04_Saint1.jpg
   
    CustomSapGuiLibrary.Click Element    wnd[0]/usr/btnBUTTON_NEXT
    Sleep    2    
    CustomSapGuiLibrary.Take Screenshot    05_saint2.jpg

Get Cell Text From SAP Table
    ${foundRow}    CustomSapGuiLibrary.search and select addon rows    ${symvar('addOn')}  
    Log    Found text in row: ${foundRow}  
    Sleep    2
    CustomSapGuiLibrary.Select Table Row    wnd[0]/usr/subLIST_AREA:SAPLSAINT_UI:0104/tblSAPLSAINT_UIADDON_TO_INSTALL    ${foundRow}
    Sleep    2
    Take Screenshot    008_select_addon.jpg
    Click Element    wnd[0]/usr/btnBUTTON_NEXT
    Sleep    2
    Take Screenshot    009_continue_to_start_calculation_package.jpg
 
Patch selection for the Addon
    Saint Select    wnd[0]/usr/subLIST_AREA:SAPLSAINT_UI:0300/tabsQUEUE_COMP/tabpQUEUE_COMP_FC2/ssubQUEUE_COMP_SCA:SAPLSAINT_UI:0303/cmbGV_01_PATCH_REQ    ${symvar('Patch')}            
    Sleep    2
    Take Screenshot    010_select_support_Package.jpg  
    Click Element    wnd[0]/usr/btnBUTTON_NEXT
    Sleep    2
    Take Screenshot    011_continue to add modification adjustment transport.jpg
    Click Element    wnd[0]/usr/btnBUTTON_NEXT
    Sleep    2
    Take Screenshot    012_Add modification adjustment transport and continue.jpg
    Click Element    wnd[1]/usr/btnBUTTON_2
    Sleep    2
    Take Screenshot    013_start options.jpg
Important SAP note handling
    ${content}    CustomSapGuiLibrary.Is Imp Notes Existing    wnd[1]    wnd[1]/tbar[0]/btn[0]
    Log    The window name is: ${content}
    # Click Element     wnd[1]/tbar[0]/btn[0] 
    Sleep    2
    Take Screenshot    014_SAPhandling.jpg
 
Start Options 
    Click Element    wnd[1]/tbar[0]/btn[27] 
    Sleep    2
    Take Screenshot    015_start options_prep.jpg
    CustomSapGuiLibrary.Select Radio Button    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC1/ssubSTART_OPTIONS_SCA:SAPLOCS_UI:0701/radLAY0700-RB1_DIA
    Sleep   2
    Take Screenshot    016_prepration_dialog.jpg
    CustomSapGuiLibrary.Click Element    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC2
    Sleep   2
    Take Screenshot    017_select_import_1.jpg
    CustomSapGuiLibrary.Select Radio Button    wnd[1]/usr/tabsSTART_OPTIONS/tabpSTART_FC2/ssubSTART_OPTIONS_SCA:SAPLOCS_UI:0702/radLAY0700-RB2_BTCHIM
    Sleep   2
    Take Screenshot    018_import_bkgd.jpg
 
Import Option
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep   1
    Take Screenshot    019_start options selected.jpg    
    CustomSapGuiLibrary.Click Element    wnd[1]/tbar[0]/btn[25]
    Take Screenshot    020_import2.jpg
    Sleep    3
    CustomSapGuiLibrary.is saint Installation status     wnd[1]    wnd[1]/tbar[0]/btn[0]
    Sleep    2
    CustomSapGuiLibrary.is errors during disassembling existing    wnd[0]   wnd[0]/tbar[1]/btn[20]
    Sleep    2
    Take Screenshot    021_ignore.jpg
    CustomSapGuiLibrary.is saint user defined existing    wnd[1]    wnd[1]/tbar[0]/btn[0]        
    Sleep    2
    Take Screenshot    022_User_defined.jpg
 
Process Until Finish Button Visible  
    ${cell_text_2}    CustomSapGuiLibrary.Get Finish Cell Text    ${finish_str}    ${interrupt_str1}    ${interrupt_str2}    ${button_id}    ${status_line}    ${refresh_id}    ${continue_id}    ${startoption_id}    ${radio_button_id}    ${startoptionok_id}    ${Import_id}    ${error_button_id}
    Log    ${cell_text_2}
    Sleep    2
    Click Element    wnd[1]/tbar[0]/btn[27]
    Take Screenshot    023_Addon_import2.jpg    
 
System Logout
    Run Transaction   /nex
    Sleep    2   
    Create Pdf    ${screenshot_directory}   ${output_pdf}    
    Sleep   2