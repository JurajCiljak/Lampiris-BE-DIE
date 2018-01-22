/*
    @ Author: Juraj Ciljak
    @ Description: Class for display message on the page and log to the Custom Object
    @ CreatedDate: 27.09.2017
    @ LastModify: 
    @ Notes:  
    @ Version: 1.0.1 
*/
public without sharing class SystemLog { 
    
    public static String ClassName{
        get{
            return SystemLog.class.getName();  
        } 
    }
    public Boolean PageAlert {get;set;}
    public Boolean ShowOnlyPageMessage{get;set;}
    public Boolean InsertLog{get;set;}
    public Boolean ThrowError{get;set;}
    
    public List< SystemLog__c > Logs{get;set;}
    
    public SystemLog(Boolean pageAlert, Boolean showOnlyPageMessage, Boolean insertLog, Boolean throwError)
    {
        this.Logs = new List< SystemLog__c >(); 
        this.PageAlert = PageAlert;
        this.InsertLog = insertLog;
        this.ThrowError = throwError;
        this.ShowOnlyPageMessage = showOnlyPageMessage;
    }
    
    public void addLog( SystemLog__c sysLog, Exception error )
    {
        SystemLog__c addSysLog = SystemLog.SystemLogMessage( sysLog, error, this.PageAlert, this.ShowOnlyPageMessage, false, this.ThrowError );
        if( addSysLog != null ) Logs.Add( addSysLog );
    }
    
    public void addLogNoThrow( SystemLog__c sysLog, Exception error, Boolean checkInsert )
    {
        SystemLog__c addSysLog = SystemLog.SystemLogMessage( sysLog, error, this.PageAlert, this.ShowOnlyPageMessage, false, false );
        if( addSysLog != null ) Logs.Add( addSysLog );
        system.debug(LoggingLevel.Error,'sysLog:'+sysLog);
        if( checkInsert ) this.checkInsertLog(); 
    }
    
    public void checkInsertLog()
    {
        //system.debug(LoggingLevel.Error,'ERROR->>>>>:'+this.InsertLog);   
        if( this.Logs != null ) upsert this.Logs;
        
    }
    
    public static SystemLog__c SystemLogMessage (  SystemLog__c sysLog, Exception E,
        Boolean pageAlert, Boolean showOnlyPageMessage, Boolean insertLog, Boolean throwError)
    {
        
        /*
            sysLog - Wrapper class for holding information for log Apex ObjectName, Apex Method which rise the log etc,..
            Exception - Eception class from try..catch block
            pageAlert - True - display mesage on VF page if you include <apex:pageMessages id="theMessages" escape="false" /> on your vf page
                      - False - do not display message on VF page
            insertLog - True insert log to the custom object "SOQL_Query__c". 
                      - False dont insert log to the custom object  
            throwError - True throw exception
                       - False dont threw exception
                       
            NOTE: By SFDC Limitation we are not able to do DML operation(insert,...) in the constructor.
                  Even if the function is with future annotation or calling throw we are not able insert record 
        */
        
        //ErrorException errE ;   
        String pageMessage = '';
        String systemMessage = '';
        String objectMessage = '';
        Integer errLine = null;
        String errTypeName = '';
        String errStackTraceString = '';
        String exceptMessage = '';
        /* ApexPages.severity: CONFIRM, ERROR,FATAL,INFO,WARNING */
        /* Logginglevel: ERROR, WARN, INFO, DEBUG, FINE, FINER, FINEST*/
        /*
            pageAlert - Ture if code is run from Visualfoece page then also displayed on VF page
        */
        
        Logginglevel logLevel = Logginglevel.INFO;
        //if( sysLog == null ) sysLog = new SystemLog.getSystemLog(  '?','?', '?','?','?','?',0,ApexPages.severity.INFO);
        
        if( E != null )
        {
            errLine = E.getLineNumber();    
            errTypeName = E.getTypeName();
            errStackTraceString = E.getStackTraceString();
            exceptMessage = E.getMessage();
        } else { exceptMessage = 'UNKNOWN Exception: '; 
            if( sysLog != null ) exceptMessage += sysLog.Message__c;
        }
        
        objectMessage = (errTypeName + ' '+errStackTraceString +' '+ exceptMessage).trim();  
        
        
        systemMessage = 'APEX object "'+sysLog.ObjectName__c+'", method "'+sysLog.MethodName__c;
        systemMessage +=' " throw log: '+objectMessage+' '+sysLog.Message__c;
        system.debug(logLevel,systemMessage);
        system.debug(logLevel,'ERROR:[' + E + ' ]'); 
        pageMessage = 'APEX object "<b>'+sysLog.ObjectName__c+'</b>", method "<b>'+sysLog.MethodName__c+'</b> throw log please contact your Admin.';
        ApexPages.severity secerityLog = ApexPages.severity.INFO;   
        
        if(sysLog.SeverityLevel__c == String.valueOf(ApexPages.severity.INFO))
        {
            logLevel = Logginglevel.INFO;
        } else if(sysLog.SeverityLevel__c == String.valueOf(ApexPages.severity.CONFIRM))
        {
            logLevel = Logginglevel.DEBUG;
            secerityLog = ApexPages.severity.CONFIRM;
        } else if(sysLog.SeverityLevel__c == String.valueOf(ApexPages.severity.ERROR))
        {
            logLevel = Logginglevel.ERROR;  
            secerityLog = ApexPages.severity.ERROR;
        }else if(sysLog.SeverityLevel__c == String.ValueOf(ApexPages.severity.FATAL))
        { 
            logLevel = Logginglevel.FINE;       
            secerityLog = ApexPages.severity.FATAL;
        }else if(sysLog.SeverityLevel__c == String.valueOf(ApexPages.severity.WARNING))
        {
            logLevel = Logginglevel.WARN;       
            secerityLog = ApexPages.severity.WARNING;
        }
        
        if( showOnlyPageMessage )
        {
            pageMessage = sysLog.Message__c;
            
        }
        
        if( pageAlert && ApexPages.currentPage()!=null )
        {
            ApexPages.addmessage(new ApexPages.message(secerityLog, pageMessage)); 
                
        }
           
            
        //Throw error if the parent method is in try catch block        
        try
        {   
            if( throwError && !showOnlyPageMessage )
            {
                throw new ErrorException(errTypeName,objectMessage);
            } else
            { 
                if( insertLog && !showOnlyPageMessage && !throwError)
                {
                    insert sysLog;
                }       
            }
         
        }finally
        {

            
        }
        return  sysLog;  
    }
    
    public static String getLogMessageFromSaveError( Database.SaveResult sv )
    {
        String Result = null;
        if( sv != null )
        {
            Result = ' ERROR:['+sv.getErrors()+'], ';
            for(Database.Error err : sv.getErrors()) {
                Result += ' STATUS:['+err.getStatusCode()+'], ';
                Result += ' MESSAGE:['+err.getMessage()+'], ';
                Result += ' FIELD:['+err.getFields()+'], ';
                Result += ' ID:['+sv.getId()+'] ';  
            }   
        }
        return Result;  
    } 
    
    public static String getLogMessageFromSaveError( Database.UpsertResult sv )
    {
        String Result = null;
        if( sv != null )
        {
            Result = ' ERROR:['+sv.getErrors()+'], ';
            for(Database.Error err : sv.getErrors()) {
                Result += ' STATUS:['+err.getStatusCode()+'], ';
                Result += ' MESSAGE:['+err.getMessage()+'], ';
                Result += ' FIELD:['+err.getFields()+'], ';
                Result += ' ID:['+sv.getId()+'] ';  
            }   
        }
        return Result;  
    } 
    
    public static SystemLog__c getSystemLog(  String objectName, String methodName, String Message,
        String recordId,String recordName,Integer errorLine, ApexPages.Severity sLevel)
    {
        if( !String.isEmpty(Message) && Message.length() > Constants.MAX_LENGHT_OF_TEXTAREA_FIELD)
        	Message = Message.substring(0, Constants.MAX_LENGHT_OF_TEXTAREA_FIELD );  
        system.debug(LoggingLevel.Error,'Message length :'+Message.length());
        SystemLog__c Result = new SystemLog__c( 
            ObjectName__c = objectName,
            MethodName__c = methodName, 
            Message__c = Message, 
            RecordId__c = recordId,
            ErrorLine__c = errorLine,
            SeverityLevel__c = String.valueOf(sLevel),
            AssignedTo__c = UserInfo.getUserId(), 
        	LogDateTime__c = system.now()
            	
         ); 
         return Result;
    }  
    
    
    public static void checkUpsertResult( String objectType, Database.UpsertResult [] upr, List<sObject> lsData, SystemLog sysLog )
    {
    	Database.UpsertResult sv;
    	Account accNotSave;
    //	LMP_Account_Reference__c accRefNotSave;
    	if( upr != null && sysLog != null && lsData != null)
    	{
    		for(Integer i=0;i<upr.size();i++){
			   if (!upr.get(i).isSuccess() || Test.isRunningTest() ){
			        // DML operation failed
			        sv = upr.get(i);
			        if( objectType == Account.sObjectType.getDescribe().getName())
			        {
			        	accNotSave = (Account)lsData.get(i);//failed record from the list
			        	//checkSavedData( accNotSave , sv, mapRequest,mapAccEl1,sysLog);
			        }/* else if( objectType == LMP_Account_Reference__c.sObjectType.getDescribe().getName() )
			        {
			        	//accRefNotSave = (LMP_Account_Reference__c)lsData.get(i);//failed record from the list
			        	//checkSavedData( accRefNotSave , sv, mapRequest,mapAccEl1,sysLog);	
			        }*/
			   }  // END if (!upr.get(i).isSuccess())
			
			} // END for( Database.UpsertResult sv: upr )    
    	}   
    }  
}