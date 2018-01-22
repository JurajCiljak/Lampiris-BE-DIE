/*
    @Author: Juraj Ciljak
    @CreateDate: 25.10.2017
    @LastModify: 
    @Description: Schedule Batch for CRM2 and SFDC integeration
                  Task: SFDCFR-60 -> https: https://jira.lampiris.be/browse/SFDCBE-60
    @Version: 1.0.1
*/
global class BAT_BatchData_Clean_Up implements Database.Batchable<sObject>,Database.Stateful {

	public static String ClassName{
        get{ 
            return BAT_BatchData_Clean_Up.class.getName();
        }
    } 
    
    public SystemLog sysLog {get;set;}
    
    public BAT_BatchData_Clean_Up()
    {   
    	this.sysLog = new SystemLog(false, false, false,false);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        try{
            
            String SOQL;   
            DateTime endDate = system.now().addMonths( ( -1  ) ); 
            SOQL = getSOQL_ForBATCH();
            
            system.debug(LoggingLevel.ERROR,'endDate:'+endDate);
            system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
            return Database.getQueryLocator(SOQL);
       }catch(Exception E)
       {        
           sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_BatchData_Clean_Up.ClassName,'start', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e , false );            
           return Database.getQueryLocator(' Select Id From ' + BatchData__c.sObjectType.getDescribe().getName() +' Limit 0 '); /* Could not return null !!!!!!! */
       }       
    }
     
 
    global void execute(Database.BatchableContext BC, List<BatchData__c> scope)
    {
         try{
        	if( scope != null && scope.size() > 0 ) delete scope;
            this.sysLog.checkInsertLog();
        
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_BatchData_Clean_Up.ClassName,'execute', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                       
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    	if( sysLog != null ) this.sysLog.checkInsertLog();
            
    }
    
    public static String getSOQL_ForBATCH()
    {
        String Result = ' Select Id ';
        Result += ' From ' + SchemaClass.getObjectName( BatchData__c.sObjectType );//BatchData__c.sObjectType.getDescribe().getName();
        Result += ' Where ( T_CaseId__r.C_Account_Reference__c != null )  ';
                
        if ( Test.IsRunningTest() ) Result += ' LIMIT 10 ';
        else Result += ' AND  ( T_ExecutingTime__c <=:endDate)  ';
        
        return Result;
    }   
}