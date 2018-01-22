/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Handler class for Case
                  Task:  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
    @Version: 1.0.1
*/

public with sharing class HNDL_ContentDocumentLink extends TriggerManager.TriggerHandler {

    public static String ClassName{
        get{
            return HNDL_ContentDocumentLink.class.getName();       
        }
    }
    
    public HNDL_ContentDocumentLink()
    {
        super( ClassName, ContentDocumentLink.sObjectType);    
        
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
    
    
    public override void bulkAfter(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap)
    {
        
	        if (Trigger.isInsert){
	            
	            bulkAfterInsert(soLst, oldMap, newMap);                   
	        }  
                
     }
     
    public static void bulkAfterInsert(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){      
        createBatchData( soLst, oldMap, newMap );    
    }   
    
   
   
    public static void createBatchData( List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap )
    {         
    
        /* sObject Data */
        Id caseId;
        Id contVersionId;
        EmailMessage eml;
        sObject sObj;
        List<User> lsUsers ;
        List<BatchData__c> lsBatchData = new List<BatchData__c>();
        List<Case> lsCase = new List<Case>();     
        List<ContentDocumentLink> lsCDLink = new List<ContentDocumentLink>();   
        Map<String,Map<Id,sObject>> parentData;
        Map<Id,sObject> mapEmlMessage = new Map<Id,sObject>();
		Map<Id,sObject> mapContentVersion = new Map<Id,sObject>();
		
        /* System Objects */
        Database.UpsertResult [] upr ;
        
        /* Custom Classes*/
        SystemLog sysLog = new SystemLog(false, false, false, false);
       
		if( soLst != null ) lsCDLink = (List<ContentDocumentLink>)soLst; 

        try
        {
        	parentData = getParentData( soLst, sysLog );
        	mapEmlMessage = parentData.get(SchemaClass.getObjectName(EmailMessage.sObjectType)); 
        	if( mapEmlMessage == null )  mapEmlMessage = new Map<Id,sObject>();
        	mapContentVersion = parentData.get(SchemaClass.getObjectName(ContentVersion.sObjectType)); 
        	if( mapContentVersion == null )  mapContentVersion = new Map<Id,sObject>();
        	
        	for( ContentDocumentLink cdLink: lsCDLink){
    			
    			/* Only for Email Message */
				if( SchemaClass.getObjectName( EmailMessage.sObjectType ) == SchemaClass.getObjectTypeFromId(cdLink.LinkedEntityId) )
				{
	    			sObj = mapEmlMessage.get(cdLink.LinkedEntityId);	
	    			caseId = null;
	    			if( sObj != null )
	    			{
	    				eml = (EmailMessage)sObj;
	    				if( !String.isEmpty(eml.ParentId)) caseId = eml.ParentId;
	    			}
	    			
	    			sObj = null;
	    			sObj = mapContentVersion.get( cdLink.ContentDocumentId );
	    			if( sObj != null ) contVersionId = sObj.Id;
	    			 
	    			lsBatchData.Add(
		            	new BatchData__c(
	              			External_Id__c = cdLink.Id,
		              		Object_Id__c = contVersionId,
			            	Parent_Id__c = cdLink.LinkedEntityId, // In this case should be case
			             	Process__c =  BAT_HNDL_CRM2_Attachment_Integration.ClassName,
			           	 	ObjectName__c = ContentVersion.sObjectType.getDescribe().getName(),
			              	T_CaseId__c = caseId,
			              	T_ExecutingTime__c = system.now(),
			              	T_DescriptionHistory__c = ''//description         
	        			)           
	  				);
				}
        	}
        	
        	if( lsBatchData != null && lsBatchData.size() > 0 ) upr = Database.upsert(lsBatchData, BatchData__c.Fields.External_Id__c);
        	SystemLog.checkUpsertResult(ContentVersion.sObjectType.getDescribe().getName(), upr, lsBatchData, sysLog );
            sysLog.checkInsertLog();
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_ContentDocumentLink.ClassName,'createBatchData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );			  
        } 
    } 
   
    
	public static Map<String,Map<Id,sObject>> getParentData( List<ContentDocumentLink> lsConDocLink,SystemLog sysLog )
	{
		Map<String,Map<Id,sObject>> Result = new Map<String,Map<Id,sObject>>(); 
		Set<String> setContDocId = new Set<String>();
		Set<String> setLinkEntId = new Set<String>();
		List<ContentVersion> lsContVersion = new List<ContentVersion>();
		List<EmailMessage> lsEmailMsg = new List<EmailMessage>();
		Map<Id,sObject> mapEmlMessage = new Map<Id,sObject>();
		Map<Id,sObject> mapContentVersion = new Map<Id,sObject>();
		try{
			
			if( sysLog == null) sysLog = new SystemLog(false, false, false, false);	
			String SOQL = ' Select IsLatest, Id, CreatedDate, ContentDocumentId '; 
			SOQL +=' From '+SchemaClass.getObjectName(ContentVersion.sObjectType)+' Where ContentDocumentId IN:setContDocId';
			for( ContentDocumentLink cdLink: lsConDocLink )
			{
				/* Only for Email Message */
				if( SchemaClass.getObjectName( EmailMessage.sObjectType ) == SchemaClass.getObjectTypeFromId(cdLink.LinkedEntityId) )
				{
					setContDocId.Add( cdLink.ContentDocumentId );
					setLinkEntId.Add( cdLink.LinkedEntityId);		
				}						
			}
			system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
			system.debug(LoggingLevel.ERROR,'setContDocId:'+setContDocId);
			
			if( setContDocId != null && setContDocId.size() > 0 ) lsContVersion = Database.query(SOQL);
			
			for(ContentVersion cv:lsContVersion )
			{
				mapContentVersion.put( cv.ContentDocumentId,cv );	
			}
			
			SOQL = ' Select Id,ParentId  From '+SchemaClass.getObjectName(EmailMessage.sObjectType)+' Where Id IN:setLinkEntId';
			system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
			system.debug(LoggingLevel.ERROR,'setLinkEntId:'+setLinkEntId);
			
			if( setLinkEntId != null && setLinkEntId.size() > 0 ) mapEmlMessage.putAll( (List<EmailMessage>)Database.query(SOQL));
			
			Result.put(SchemaClass.getObjectName(EmailMessage.sObjectType),mapEmlMessage);
			Result.put(SchemaClass.getObjectName(ContentVersion.sObjectType),mapContentVersion);
			return Result;
		}catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_ContentDocumentLink.ClassName,'getParentData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );			  
        	return new Map<String,Map<Id,sObject>>();
        } 
		
	}
}