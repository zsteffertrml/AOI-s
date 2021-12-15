MODULE Core
    
    VAR socketdev clientsocket;
    VAR socketstatus socketstat;
    VAR rawbytes raw_send;
    VAR rawbytes raw_recieve;
    VAR byte tempByte;
    VAR num tempNum;
    
    PROC main()     
        ClearRawBytes raw_send;
        ClearRawBytes raw_recieve; 
        SocketClose clientsocket;
        socketstat := SocketGetStatus(clientsocket);
		
        WHILE NOT(socketstat = SOCKET_CONNECTED) DO
            waittime 1;
            SocketClose clientsocket;
            WaitTime 1;
            connectToServer "127.0.0.1",1024;
            socketstat := SocketGetStatus(clientsocket);  
        ENDWHILE
        
        WHILE (socketstat = SOCKET_CONNECTED) DO     
            sendData;
            recieveData;
        ENDWHILE      
        
    ENDPROC
    
    PROC connectToServer( string IPAddress, num portNo)
	
        VAR num retryNo :=0;
        SocketCreate clientsocket;
        SocketConnect  clientsocket,IPAddress,portNo\Time:=5;
        ErrWrite\I, "connection successful","Connection to PLC good";
        
    ERROR
        IF ERRNO = ERR_SOCK_TIMEOUT THEN
            WaitTime 1;
            Incr retryNo;
            IF retryNo >=3 THEN
                ErrWrite\I, "connection failed","Connection to PLC Failed";   
                retryNo := 0;
                waittime 3;
                ExitCycle;
            ELSE
                RETRY;
            ENDIF
        ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
            WaitTime 3;
            ExitCycle;
        ELSE
            ErrWrite\I, "Unknown Error",NumToStr(errno,1);  
            Stop;
        ENDIF

    ENDPROC
    
    PROC sendData()
        ClearRawBytes raw_send;
                
        ! SYSTEM OUTPUTS (do not edit)
        tempByte:=0;
        IF RO3531_SI_AutoOn                 = 1 THEN BitSet tempByte, 1; ENDIF
        IF RO3531_SI_CycleOn                = 1 THEN BitSet tempByte, 2; ENDIF
        IF RO3531_SI_EmergencyStop          = 1 THEN BitSet tempByte, 3; ENDIF
        IF RO3531_SI_ExecutionError         = 1 THEN BitSet tempByte, 4; ENDIF
        IF RO3531_SI_MotorsOnState          = 1 THEN BitSet tempByte, 5; ENDIF
        IF RO3531_SI_MotionSupervisionOn    = 1 THEN BitSet tempByte, 6; ENDIF
        IF RO3531_SI_MotionSuperVisionTrig  = 1 THEN BitSet tempByte, 7; ENDIF
        IF RO3531_SI_PowerFailError         = 1 THEN BitSet tempByte, 8; ENDIF
        PackRawBytes tempByte,raw_send,(RawBytesLen(raw_send)+1)\Hex1; tempByte:=0;

        IF RO3531_SI_PathReturnRegionError  = 1 THEN BitSet tempByte, 1; ENDIF
        IF RO3531_SI_RunchainOk             = 1 THEN BitSet tempByte, 2; ENDIF
        IF RO3531_SI_TaskExecuting          = 1 THEN BitSet tempByte, 3; ENDIF
        IF RO3531_SI_MotorsOn               = 1 THEN BitSet tempByte, 4; ENDIF
        IF RO3531_SI_AutoSwitchSelection    = 1 THEN BitSet tempByte, 5; ENDIF
        IF RO3531_SI_SafetyChainReady       = 1 THEN BitSet tempByte, 6; ENDIF
        IF RO3531_SI_ProgramError           = 1 THEN BitSet tempByte, 7; ENDIF
        PackRawBytes tempByte,raw_send,(RawBytesLen(raw_send)+1)\Hex1; tempByte:=0;

        IF RO3531_SI_Homed                  = 1 THEN BitSet tempByte, 1; ENDIF
        IF RO3531_SI_HeartBeat              = 1 THEN BitSet tempByte, 2; ENDIF
        IF RO3531_SI_InServicePos           = 1 THEN BitSet tempByte, 3; ENDIF
        IF RO3531_SI_ResumeEnable           = 1 THEN BitSet tempByte, 4; ENDIF
        IF RO3531_SI_AbortEnable            = 1 THEN BitSet tempByte, 5; ENDIF
        IF RO3531_SI_RetryEnable            = 1 THEN BitSet tempByte, 6; ENDIF
        IF RO3531_SI_WorldZonesEnabled      = 1 THEN BitSet tempByte, 7; ENDIF
        PackRawBytes tempByte,raw_send,(RawBytesLen(raw_send)+1)\Hex1; tempByte:=0;

        PackRawBytes GOutput(RO3531_SI_JogStatus),raw_send,(RawBytesLen(raw_send)+1)\IntX:=SINT;
        PackRawBytes GOutput(RO3531_SI_FPSpeedOverride),raw_send,(RawBytesLen(raw_send)+1)\IntX:=SINT;
        PackRawBytes GOutput(RO3531_SI_StepNum),raw_send,(RawBytesLen(raw_send)+1)\IntX:=SINT;
        PackRawBytes GOutput(RO3531_SI_TCP_Speed),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_FaultCode),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_MoveStatus),raw_send,(RawBytesLen(raw_send)+1)\IntX:=SINT;
        
        PackRawBytes GOutput(RO3531_SI_AxisPos1),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_AxisPos2),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_AxisPos3),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_AxisPos4),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_AxisPos5),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        PackRawBytes GOutput(RO3531_SI_AxisPos6),raw_send,(RawBytesLen(raw_send)+1)\IntX:=INT;
        
        ! GENERAL OUTPUTS (project specific)
        tempByte:=0;
        IF RO3531_I_PluckActive             = 1 THEN BitSet tempByte, 1; ENDIF
        IF RO3531_I_PluckDone               = 1 THEN BitSet tempByte, 2; ENDIF
        IF RO3531_I_PlaceActive             = 1 THEN BitSet tempByte, 3; ENDIF
        IF RO3531_I_PlaceDone               = 1 THEN BitSet tempByte, 4; ENDIF
        IF RO3531_I_PS3531                  = 1 THEN BitSet tempByte, 5; ENDIF
        IF RO3531_I_PS3532                  = 1 THEN BitSet tempByte, 6; ENDIF
        IF RO3531_I_PS1401                  = 1 THEN BitSet tempByte, 7; ENDIF
        IF RO3531_I_PE2501                  = 1 THEN BitSet tempByte, 8; ENDIF
        PackRawBytes tempByte,raw_send,(RawBytesLen(raw_send)+1)\Hex1; tempByte:=0;

        IF RO3531_I_CY2502_R                = 1 THEN BitSet tempByte, 1; ENDIF
        IF RO3531_I_SV3531                  = 1 THEN BitSet tempByte, 2; ENDIF
        IF RO3531_I_SV3532                  = 1 THEN BitSet tempByte, 3; ENDIF
        IF RO3531_I_SV3533                  = 1 THEN BitSet tempByte, 4; ENDIF
        IF RO3531_I_SV3534                  = 1 THEN BitSet tempByte, 5; ENDIF
        IF RO3531_I_SV1106                  = 1 THEN BitSet tempByte, 6; ENDIF
        IF RO3531_I_SV1401                  = 1 THEN BitSet tempByte, 7; ENDIF
        IF RO3531_I_SV1402                  = 1 THEN BitSet tempByte, 8; ENDIF
        PackRawBytes tempByte,raw_send,(RawBytesLen(raw_send)+1)\Hex1; tempByte:=0;

        IF RO3531_I_CY2502_EX               = 1 THEN BitSet tempByte, 1; ENDIF
        IF RO3531_I_CY2502_RT               = 1 THEN BitSet tempByte, 2; ENDIF
        IF RO3531_I_CY2701_EX               = 1 THEN BitSet tempByte, 3; ENDIF
        IF RO3531_I_CY2701_RT               = 1 THEN BitSet tempByte, 4; ENDIF
        PackRawBytes tempByte,raw_send,(RawBytesLen(raw_send)+1)\Hex1; tempByte:=0;

        SocketSend clientsocket \RawData:= raw_send;
        
     ERROR
        IF ERRNO = ERR_SOCK_CLOSED THEN
            WaitTime 1;
            ErrWrite\I, "socket closed","Socket closed during sending data";     
        ELSE
            ErrWrite\I, "Unknown Error",NumToStr(errno,1);  
            Stop;
        ENDIF
    
     ENDPROC
     
    PROC recieveData()
        ClearRawBytes raw_recieve;
        
        SocketReceive clientsocket\RawData:=raw_recieve\Time:=3;
        
        ! SYSTEM INPUTS (do not edit)
        UnpackRawBytes raw_recieve,1,tempbyte\Hex1;
        Reset SQ_MotorsOn;          IF BitCheck(tempbyte,1) Set SQ_MotorsOn;
        Reset SQ_MotorsOnStart;     IF BitCheck(tempbyte,2) Set SQ_MotorsOnStart;
        Reset SQ_Start;             IF BitCheck(tempbyte,3) Set SQ_Start;
        Reset SQ_StartAtMain;       IF BitCheck(tempbyte,4) Set SQ_StartAtMain;
        Reset SQ_ResetExecutionErr; IF BitCheck(tempbyte,5) Set SQ_ResetExecutionErr;
        Reset SQ_ResetEmergencyStop;IF BitCheck(tempbyte,6) Set SQ_ResetEmergencyStop;
        Reset SQ_StopAtEndCycle;    IF BitCheck(tempbyte,7) Set SQ_StopAtEndCycle;
        Reset SQ_Stop;              IF BitCheck(tempbyte,8) Set SQ_Stop;
        
        UnpackRawBytes raw_recieve,2,tempbyte\Hex1;
        Reset SQ_QuickStop;         IF BitCheck(tempbyte,1) Set SQ_QuickStop;        
        Reset RO3531_SQ_Energize;   IF BitCheck(tempbyte,3) Set RO3531_SQ_Energize;         
        Reset RO3531_SQ_Home;       IF BitCheck(tempbyte,4) Set RO3531_SQ_Home;             
        Reset RO3531_SQ_FaultAck;   IF BitCheck(tempbyte,5) Set RO3531_SQ_FaultAck;         
        Reset RO3531_SQ_Resume;     IF BitCheck(tempbyte,6) Set RO3531_SQ_Resume;           
        Reset RO3531_SQ_Abort;      IF BitCheck(tempbyte,7) Set RO3531_SQ_Abort;            
        Reset RO3531_SQ_Retry;      IF BitCheck(tempbyte,8) Set RO3531_SQ_Retry;            
                                                                
        UnpackRawBytes raw_recieve,3,tempbyte\Hex1;             
        Reset RO3531_SQ_Service;           IF BitCheck(tempbyte,1) Set RO3531_SQ_Service;          
        Reset RO3531_SQ_DisableWorldZones; IF BitCheck(tempbyte,2) Set RO3531_SQ_DisableWorldZones;
        Reset RO3531_SQ_Simulation_Mode;   IF BitCheck(tempbyte,3) Set RO3531_SQ_Simulation_Mode;   
        Reset RO3531_Manual_JogOpMan;      IF BitCheck(tempbyte,5) Set RO3531_Manual_JogOpMan;  
        
        UnpackRawBytes raw_recieve,4,tempNum\IntX:=SINT;    SetGO RO3531_Q_JogState, tempNum;
        UnpackRawBytes raw_recieve,5,tempNum\IntX:=SINT;    SetGO RO3531_Q_JogStep, tempNum;
        UnpackRawBytes raw_recieve,6,tempNum\IntX:=SINT;    SetGO RO3531_SQ_SpeedOverride, tempNum;
        UnpackRawBytes raw_recieve,7,tempNum\IntX:=SINT;    SetGO RO3531_SQ_A1ControlState, tempNum;
        !UnpackRawBytes raw_recieve,8,RO3531_Q_RecipeIndex\IntX:=SINT;

        ! GENERAL INPUTS (project specific)
        UnpackRawBytes raw_recieve,10,tempbyte\Hex1;             
        Reset RO3531_Q_PluckPermit;             IF BitCheck(tempbyte,2) Set RO3531_Q_PluckPermit;          
        Reset RO3531_Q_PlacePermit;             IF BitCheck(tempbyte,4) Set RO3531_Q_PlacePermit;
        Reset RO3531_Q_CY2502_E;                IF BitCheck(tempbyte,2) Set RO3531_Q_CY2502_E;
        Reset RO3531_Q_CY2502_R;                IF BitCheck(tempbyte,3) Set RO3531_Q_CY2502_R;
        Reset RO3531_Q_CY2701_E;                IF BitCheck(tempbyte,4) Set RO3531_Q_CY2701_E;
        Reset RO3531_Q_CY2701_R;                IF BitCheck(tempbyte,5) Set RO3531_Q_CY2701_R;
        Reset RO3531_Q_SV1106_Force_On ;        IF BitCheck(tempbyte,2) Set RO3531_Q_SV1106_Force_On ;
        Reset RO3531_Q_SV1106_Force_Off;        IF BitCheck(tempbyte,3) Set RO3531_Q_SV1106_Force_Off;
        
        UnpackRawBytes raw_recieve,11,tempbyte\Hex1;             
        Reset RO3531_Q_SV1401_Force_On ;        IF BitCheck(tempbyte,4) Set RO3531_Q_SV1401_Force_On ;
        Reset RO3531_Q_SV1401_Force_Off;        IF BitCheck(tempbyte,5) Set RO3531_Q_SV1401_Force_Off;
        Reset RO3531_Q_SV1402_Force_On ;        IF BitCheck(tempbyte,6) Set RO3531_Q_SV1402_Force_On ;
        Reset RO3531_Q_SV1402_Force_Off;        IF BitCheck(tempbyte,7) Set RO3531_Q_SV1402_Force_Off;
        Reset RO3531_Q_CY2502_Force_EX ;        IF BitCheck(tempbyte,8) Set RO3531_Q_CY2502_Force_EX ;
        Reset RO3531_Q_CY2502_Force_RT ;        IF BitCheck(tempbyte,1) Set RO3531_Q_CY2502_Force_RT ;
        Reset RO3531_Q_CY2502_Force_Off;        IF BitCheck(tempbyte,2) Set RO3531_Q_CY2502_Force_Off;
        Reset RO3531_Q_CY2701_Force_EX ;        IF BitCheck(tempbyte,3) Set RO3531_Q_CY2701_Force_EX ;
        
        UnpackRawBytes raw_recieve,12,tempbyte\Hex1;             
        Reset RO3531_Q_CY2701_Force_RT ;        IF BitCheck(tempbyte,4) Set RO3531_Q_CY2701_Force_RT ;
        Reset RO3531_Q_CY2701_Force_Off;        IF BitCheck(tempbyte,5) Set RO3531_Q_CY2701_Force_Off;

        UnpackRawBytes raw_recieve,13,tempNum\IntX:=INT;    SetGO RO3531_Q_PickheadVacuumBuildTime, tempNum;
        UnpackRawBytes raw_recieve,15,tempNum\IntX:=INT;    SetGO RO3531_Q_PickheadPurgeTime, tempNum;
        UnpackRawBytes raw_recieve,17,tempNum\IntX:=INT;    SetGO RO3531_Q_ErectVacuumBuildTime, tempNum;
        UnpackRawBytes raw_recieve,19,tempNum\IntX:=INT;    SetGO RO3531_Q_ErectVacuumPurgeTime, tempNum;
        UnpackRawBytes raw_recieve,21,tempNum\IntX:=INT;    SetGO RO3531_Q_FrontMinorPloughAngle, tempNum;
        UnpackRawBytes raw_recieve,23,tempNum\IntX:=INT;    SetGO RO3531_Q_RearMinorPloughAngle, tempNum;
        UnpackRawBytes raw_recieve,25,tempNum\IntX:=SINT;   SetGO RO3531_Q_PloughSpeed, tempNum;
        UnpackRawBytes raw_recieve,26,tempNum\IntX:=SINT;   SetGO RO3531_Q_GlueSpeed, tempNum;
        UnpackRawBytes raw_recieve,27,tempNum\IntX:=INT;    SetGO RO3531_Q_Pos1GlueWindowStart, tempNum;
        UnpackRawBytes raw_recieve,29,tempNum\IntX:=INT;    SetGO RO3531_Q_Pos1GlueWindowEnd, tempNum;
        UnpackRawBytes raw_recieve,31,tempNum\IntX:=INT;    SetGO RO3531_Q_Pos2GlueWindowStart, tempNum;
        UnpackRawBytes raw_recieve,33,tempNum\IntX:=INT;    SetGO RO3531_Q_Pos2GlueWindowEnd, tempNum;
        UnpackRawBytes raw_recieve,35,tempNum\IntX:=INT;    SetGO RO3531_Q_GlueCompensation, tempNum;
        UnpackRawBytes raw_recieve,37,tempNum\IntX:=INT;    SetGO RO3531_Q_PluckingXOffset, tempNum;
        UnpackRawBytes raw_recieve,39,tempNum\IntX:=INT;    SetGO RO3531_Q_PluckingYOffset, tempNum;
        UnpackRawBytes raw_recieve,41,tempNum\IntX:=INT;    SetGO RO3531_Q_PluckingZOffset, tempNum;
        UnpackRawBytes raw_recieve,43,tempNum\IntX:=INT;    SetGO RO3531_Q_ErectingXOffset, tempNum;
        UnpackRawBytes raw_recieve,45,tempNum\IntX:=INT;    SetGO RO3531_Q_ErectingYOffset, tempNum;
        UnpackRawBytes raw_recieve,47,tempNum\IntX:=INT;    SetGO RO3531_Q_ErectingZOffset, tempNum;
        UnpackRawBytes raw_recieve,49,tempNum\IntX:=INT;    SetGO RO3531_Q_PloughingXOffset, tempNum;
        UnpackRawBytes raw_recieve,51,tempNum\IntX:=INT;    SetGO RO3531_Q_PloughingYOffset, tempNum;
        UnpackRawBytes raw_recieve,53,tempNum\IntX:=INT;    SetGO RO3531_Q_PloughingZOffset, tempNum;
        UnpackRawBytes raw_recieve,55,tempNum\IntX:=INT;    SetGO RO3531_Q_PlaceXOffset, tempNum;
        UnpackRawBytes raw_recieve,57,tempNum\IntX:=INT;    SetGO RO3531_Q_PlaceYOffset, tempNum;
        UnpackRawBytes raw_recieve,59,tempNum\IntX:=INT;    SetGO RO3531_Q_PlaceZOffset, tempNum;
        UnpackRawBytes raw_recieve,61,tempNum\IntX:=INT;    SetGO RO3531_Q_GlueCompression, tempNum;

        socketstat := SocketGetStatus(clientsocket);
        
        ERROR
        
        IF ERRNO = ERR_SOCK_CLOSED or ERRNO = ERR_SOCK_TIMEOUT THEN
            WaitTime 1;
            ErrWrite\I, "socket error","Timed out waiting for data";     
            ExitCycle;
        ELSE
            ErrWrite\I, "Unknown Error",NumToStr(errno,1);  
            Stop;
        ENDIF
    
     ENDPROC
    
      
ENDMODULE