/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Handler class for Attachment
                  Task:  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/
public with sharing class HNDL_Attachment extends TriggerManager.TriggerHandler{
   
	public static String ClassName{
        get{
            return HNDL_Attachment.class.getName();       
        }
    }
    
    public HNDL_Attachment()
    {
        super( ClassName, Attachment.sObjectType);    
        
    }   
    
    /* Implementation */ 
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
    
    
    public override void bulkAfter(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap)
    {
        
        if ( Trigger.isUpdate)
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
		function createBatchData responsible for creating BatchData__c object for processing in batch
		@soLst: Collection of sObject(Attachements)
		@oldMap: Map Collection of old values
		@newMap: Map Collection of new values
	*/
    public static void createBatchData( List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap )
    {         
        /* sObject Data */
        EmailMessage eml;
        List<BatchData__c> lsBatchData = new List<BatchData__c>();
        List<Attachment> lsAtt = new List<Attachment>();   
        Map<Id,EmailMessage> mapEml = new  Map<Id,EmailMessage>();    
       
        if( soLst != null ) lsAtt = (List<Attachment>)soLst;
        
        /* System Objects */
        Database.UpsertResult [] upr ;
        
        /* Custom Classes*/
        SystemLog sysLog = new SystemLog(false, false, false, false);
       
        try
        {
        	mapEml =  getEmailMessageFromAttachement( lsAtt, sysLog );
        	for( Attachment att: lsAtt){
        		
        		if( SchemaClass.getObjectTypeFromId( att.ParentId ) == SchemaClass.getObjectName(EmailMessage.sObjectType) )
        		{
        			eml = mapEml.get( att.ParentId );
        			if( eml == null ) eml = new EmailMessage();
        			lsBatchData.Add(
		            	new BatchData__c(
	              			External_Id__c = att.Id,
		              		Object_Id__c = att.Id,
			            	Parent_Id__c = att.ParentId, // In this case should be case
			             	Process__c = BAT_HNDL_CRM2_Attachment_Integration.ClassName, 
			           	 	ObjectName__c = Attachment.sObjectType.getDescribe().getName(),
			              	T_CaseId__c = eml.ParentId,
			              	T_ExecutingTime__c = system.now(),
			              	T_DescriptionHistory__c = ''         
            			)           
      				);
				}	// END if( SchemaClass.getObjectTypeFromId( att.ParentId ) == SchemaClass.getObjectName(EmailMessage.sObjectType) )
        	}	//END  for( Attachment att: lsAtt){
        	
        	if( lsBatchData != null && lsBatchData.size() > 0 ) upr = Database.upsert(lsBatchData, BatchData__c.Fields.External_Id__c);
        	SystemLog.checkUpsertResult(Attachment.sObjectType.getDescribe().getName(), upr, lsBatchData, sysLog );
            sysLog.checkInsertLog();
            
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_Attachment.ClassName,'createBatchData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );			  
        } 
    }
    
    /*
		function getEmailMessageFromAttachement responsible for getting Parent records from Attachement
		@lsAtt: Collection of Attachements
		@sysLog: Custom class for system logs
	*/
	public static Map<Id,EmailMessage> getEmailMessageFromAttachement( List<Attachment> lsAtt, SystemLog sysLog )
	{
		Map<Id,EmailMessage> Result = new Map<Id,EmailMessage>();
		Set<String> setParentIds = new Set<String>();
		try{
			if( sysLog == null) sysLog = new SystemLog(false, false, false, false);	
			if( lsAtt == null ) lsAtt = new List<Attachment>();
			String SOQL = ' Select Id,ParentId From '+SchemaClass.getObjectName(EmailMessage.sObjectType)+' Where Id IN:setParentIds';
			
			for( Attachment att: lsAtt )
			{
				system.debug(LoggingLevel.ERROR,'att.ParentId:'+att.ParentId);
				if( SchemaClass.getObjectTypeFromId( att.ParentId ) == SchemaClass.getObjectName(EmailMessage.sObjectType)  ) 
					setParentIds.Add( att.ParentId );								
			}
			
			system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
			system.debug(LoggingLevel.ERROR,'setParentIds:'+setParentIds);
			
			if( setParentIds != null && setParentIds.size() > 0 ) Result.putAll( (List<EmailMessage>)Database.query(SOQL));
			return Result;
		}catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_Attachment.ClassName,'getEmailMessageFromAttachement', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );			  
        	return new Map<Id,EmailMessage>();
        } 
		
	}   
    
}