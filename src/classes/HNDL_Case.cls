/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
			26.12.2017 - Juraj :
    @Description: Handler class for Case
                  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60 
                  Task: SFBECASE-126 - https://jira.lampiris.be/browse/SFBECASE-126  
    @Version: 1.0.1
*/
 
public with sharing class HNDL_Case extends TriggerManager.TriggerHandler {

    public static String ClassName{
        get{
            return HNDL_Case.class.getName();       
        }
    }
    public HNDL_Case()
    {
        super( ClassName, Case.sObjectType);    
        
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
    
    public override void bulkBefore(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap)
    {

    	if ( Trigger.isUpdate)
        {
       		bulkBeforeUpdate(soLst, oldMap, newMap);                   
        } else if( Trigger.isInsert ){
			// 06.01.2018 - Mohamed
			bulkBeforeInsert(soLst,oldMap, newMap);

			bulkBeforeUpdate(soLst, oldMap, newMap);

        }

     }
    
    
    public override void bulkAfter(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap)
    {
        	if ( Trigger.isUndelete ){
	        	bulkAfterUpdate(soLst, oldMap, newMap);            
	        } else if ( Trigger.isUpdate)
	        {
	            bulkAfterUpdate(soLst, oldMap, newMap);      
	        } else if (Trigger.isInsert){
	            
	            bulkAfterInsert(soLst, oldMap, newMap);
	        }

             
     }

	public static void bulkBeforeInsert(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
		HLPR_CaseService.removeAccountlinkToCaseForCpasMail(soLst);

	}

    public static void bulkBeforeUpdate(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){      
        HLPR_CaseService.checkStatusData( soLst, oldMap, newMap );
    }   
    
     
    public static void bulkAfterInsert(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){      
        createBatchData( soLst, oldMap, newMap );
    }   
    
    public static void bulkAfterUpdate(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
        /* Update Existing BatchData if Account Reference was null */
        HLPR_CaseService.updateCaseAccountReference(newMap, oldMap);  
          
        createBatchData( soLst, oldMap, newMap );
    }
    
    //public static void bulkAfterUndelete(List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap){ /* Dont need to be executed */    } 
    
	

    public static void createBatchData( List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap )
    {         
        String description = '';
        /* sObject Data */
        Case oldCase;
        User us;
        Group gp;
        sObject sObj;
        List<User> lsUsers ;
        List<BatchData__c> lsBatchData = new List<BatchData__c>();
        List<Case> lsCase = new List<Case>();       
        Map<Id,sObject> userData;
        Map<Id,Case> oldCases = new Map<Id,Case>();
        
        /* System Objects */
        Database.UpsertResult [] upr ;
        
        /* Custom Classes*/
        SystemLog sysLog = new SystemLog(false, false, false, false);
       
        if( oldMap != null ) oldCases = (Map<Id,Case>)oldMap;
        if( soLst != null ) lsCase = (List<Case>)soLst; 

        try
        {
        	userData = getUserInfoFromCase( lsCase,oldCases, sysLog );
        	
        	for( Case cs: lsCase){
        		oldCase = oldCases.get(cs.Id);
        		if( oldCase == null ) oldCase = new Case(
        		//	LMP_TF_Count_Inbound_Emails__c = cs.LMP_TF_Count_Inbound_Emails__c,
        		//	LMP_TF_Count_Outbound_Emails__c = cs.LMP_TF_Count_Outbound_Emails__c
        		);
        	
        		if( cs.Status != oldCase.Status && 
        			cs.T_Count_Inbound_Emails__c == oldCase.T_Count_Inbound_Emails__c  && 
        			cs.T_Count_Outbound_Emails__c == oldCase.T_Count_Outbound_Emails__c
        		)
        		{ 
        			sObj = userData.get(cs.OwnerId);
        			system.debug(LoggingLevel.ERROR,'cs:'+cs);
        			description = CRM2_Data.getCRM2Description( cs,sObj );
        			lsBatchData.Add(
		            	new BatchData__c(
	              			External_Id__c = EncodingUtil.base64Encode(Blob.ValueOf(cs.Id+'/'+cs.OwnerId+'/'+cs.Status)),
		              		Object_Id__c = cs.Id,
			            	ObjectStatus__c = cs.Status, // 26.12.2017
			            	Parent_Id__c = cs.ParentId, // In this case should be case
			             	Process__c = BAT_HNDL_CRM2_Integration.ClassName,
			           	 	ObjectName__c = Case.sObjectType.getDescribe().getName(),
			              	T_CaseId__c = cs.Id,
			              	T_ExecutingTime__c = system.now(),
			              	T_DescriptionHistory__c = description         
            			)           
      				);
				}
        	}
        	
        	if( lsBatchData != null && lsBatchData.size() > 0 ) upr = Database.upsert(lsBatchData, BatchData__c.Fields.External_Id__c);
        	SystemLog.checkUpsertResult(Case.sObjectType.getDescribe().getName(), upr, lsBatchData, sysLog );
            sysLog.checkInsertLog();
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_Case.ClassName,'createBatchData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );			  
        } 
    }
    
	public static Map<Id,sObject> getUserInfoFromCase( List<Case> lsCase, Map<Id,Case> oldCases ,SystemLog sysLog )
	{
		Map<Id,sObject> Result = new Map<Id,sObject>(); 
		Set<String> setUserIds = new Set<String>();
		Case oldCase;
		if( oldCases == null ) oldCases = new Map<Id,Case>();
		try{
			if( sysLog == null) sysLog = new SystemLog(false, false, false, false);	
			if( lsCase == null ) lsCase = new List<Case>();
			String SOQL = ' Select Id,FirstName, LastName,Name From '+SchemaClass.getObjectName(User.sObjectType)+' Where Id IN:setUserIds';
			for( Case cs: lsCase )
			{
				oldCase = oldCases.get(cs.Id);
        		if( oldCase == null ) oldCase = new Case();
        	
        		if( cs.Status != oldCase.Status && 
        			cs.T_Count_Inbound_Emails__c == oldCase.T_Count_Inbound_Emails__c  && 
        			cs.T_Count_Outbound_Emails__c == oldCase.T_Count_Outbound_Emails__c
        		)
				{
					setUserIds.Add( cs.OwnerId );	
				}							
			}
			system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
			system.debug(LoggingLevel.ERROR,'setUserIds:'+setUserIds);
			
			if( setUserIds != null && setUserIds.size() > 0 ) Result.putAll( (List<User>)Database.query(SOQL));
			
			SOQL = ' Select Id,Name  From '+SchemaClass.getObjectName(Group.sObjectType)+' Where Id IN:setUserIds';
			system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
			system.debug(LoggingLevel.ERROR,'setUserIds:'+setUserIds);
			
			if( setUserIds != null && setUserIds.size() > 0 ) Result.putAll( (List<Group>)Database.query(SOQL));
			
			
			return Result;
		}catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_Case.ClassName,'getUserInfoFromCase', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );			  
        	return new Map<Id,User>();
        } 
		
	}
         


}