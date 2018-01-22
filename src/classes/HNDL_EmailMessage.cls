/*
    @Author: Juraj Ciljak
    @CreateDate: 24.07.2017
    @LastModify: 
    @Description: Handler class for Email Message
                  Task: Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60
                  Task: SFBECASE-115  -> https://jira.lampiris.be/browse/SFBECASE-115
    @Version: 1.0.1
*/
public with sharing class HNDL_EmailMessage extends TriggerManager.TriggerHandler {

    public static String ClassName{
        get{
            return HNDL_EmailMessage.class.getName();       
        }
    }
    public HNDL_EmailMessage()
    {
        super( ClassName, EmailMessage.sObjectType);    
        
    }   
     
    public static void setFirstRun( Boolean setfirstRun)
	{
		firstRun = setFirstRun;		
	}
    private static boolean firstRun = true;
	
	public static boolean isFirstRun() {
        return firstRun;
    }

    public static void setFirstRunFalse(){
        firstRun = false;
    }

    // 12.01.2018 - Mohamed
    public override void bulkBefore(List<SObject> lst, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        if (Trigger.isInsert){
            bulkBeforeInsert(lst, oldMap, newMap);
        }
    }

    // 12.01.2018 - Mohamed
    public static void bulkBeforeInsert(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
        HLPR_DuplicateEmailMessage.checkAndFixDuplicateEmails(soLst,oldMap,newMap);
    }

    public override void bulkAfter(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap)
    {
        
        if ( Trigger.isUndelete ){
            //bulkAfterUndelete(soLst, oldMap, newMap); /* Not allowed for Campaign member object*/      
        } else if ( Trigger.isUpdate)
        {
             bulkAfterUpdate(soLst, oldMap, newMap);      
        } else if (Trigger.isInsert){
            
            bulkAfterInsert(soLst, oldMap, newMap);                   
        }          
     }
     
    public static void bulkAfterInsert(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){      
        createBatchData( soLst, oldMap, newMap );    
    }   
    
    public static void bulkAfterUpdate(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
        createBatchData( soLst, oldMap, newMap );
    }
    
    //public static void bulkAfterUndelete(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){ /* Dont need to be executed */    } 
    
	/*
		function createBatchData responsible for Creating BatchData for batch process. This class is called from trigger
		@soLst: Collection of EmailMessage
		@oldMap: Map collection of old value 
		@newMap: Map collection of new value
	*/
    public static void createBatchData( List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap )
    {         
        List<BatchData__c> lsBatchData = new List<BatchData__c>();
        SystemLog sysLog = new SystemLog(false, false, false, false);
        List<EmailMessage> lsEml = new List<EmailMessage>();
        if( soLst != null ) lsEml = (List<EmailMessage>)soLst;
        Database.UpsertResult [] upr ;
        try
        {
        	for( EmailMessage eml: lsEml){
        		lsBatchData.Add(
		            new BatchData__c( 
		              External_Id__c = eml.Id,
		              Object_Id__c = eml.Id,
		              Parent_Id__c = eml.ParentId, // In this case should be case
		              Process__c = BAT_HNDL_CRM2_Integration.ClassName,
		              ObjectName__c = EmailMessage.sObjectType.getDescribe().getName(),
		              T_CaseId__c = eml.ParentId,
		              T_ExecutingTime__c = system.now()               
            		)
            
          		);
        	}
        	
        	if( lsBatchData != null && lsBatchData.size() > 0 ) upr = Database.upsert(lsBatchData, BatchData__c.Fields.External_Id__c);
        	SystemLog.checkUpsertResult(EmailMessage.sObjectType.getDescribe().getName(), upr, lsBatchData, sysLog );
            sysLog.checkInsertLog();
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_EmailMessage.ClassName,'createBatchData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );			  
        } 
    }
    
   
         
}