/*
	@Author: Juraj Ciljak
	@CreateDate: 04.01.2018
	@LastModify: 
	@Description:  Helper class for Case Hanlder 
			Task: SFBECASE-113 - https://jira.lampiris.be/browse/SFBECASE-113
			Task: SFBECASE-126 - https://jira.lampiris.be/browse/SFBECASE-126
	@Version: 1.0.1
*/

public with sharing class HLPR_CaseService {

    public static String ClassName{
        get{
            return HLPR_CaseService.class.getName();       
        }
    }

    public static void removeAccountlinkToCaseForCpasMail(List <SObject> newList){
		/*
		@newMap: Collection of new changes in case
		 */
		List<Case> caseNewList;
		SystemLog sysLog = new SystemLog(false, false, false, false);
		try {
			caseNewList=newList;
			if (newList != null && newList.size() > 0) {
				for( Case cs: caseNewList ) {
					CPAS_EmailAddress__c cpasEmailAddress = CustomSettings.getCpasEmailAddress(cs.SuppliedEmail);
					if (cpasEmailAddress!=null && !String.isEmpty(cpasEmailAddress.Email_Address__c) ) {//It's a CPAS email, so remove automatic linking of Account to Case
						cs.AccountId=null;
						cs.ContactId=null;
					}

				}
			}
		}catch( Exception E)
			{
			sysLog.addLogNoThrow( SystemLog.getSystemLog( HLPR_CaseService.ClassName,'initAccountCase', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );
		}
	}



	public static void updateCaseAccountReference(Map<Id,sObject> newMap, Map<Id,sObject> oldMap)  
	{
		/* 
	        method finish is executing after the batch is finish
	        @newMap: Collection of new changes in case
	        @oldMap: Collection of old data in case
    	*/
		
		Case csOld;
		List<BatchData__c> Result;
		Map<Id,Case> caseOldMap;
		Map<Id,Case> caseNewMap;
		Set<Id> caseIds = new Set<Id>();
		
		/* Custom Classes*/
        SystemLog sysLog = new SystemLog(false, false, false, false);
        /* System Objects */
        Database.UpsertResult [] upr ;
		try{
			if( newMap != null && newMap.size() > 0)
			{
				caseNewMap = (Map<Id,Case>)newMap;		
				if( oldMap != null ) caseOldMap = (Map<Id,Case>)oldMap;
				else caseOldMap = caseNewMap;
				
				for( Case cs: caseNewMap.values() )
				{ 
					csOld = caseOldMap.get(cs.Id);
					
					if( csOld == null ) csOld = cs; // nothing changed
					
					if( !String.isEmpty(cs.C_Account_Reference__c) && String.isEmpty(csOld.C_Account_Reference__c) )  
						// Need Id only from cases where Account reference was null
					{
						caseIds.Add(cs.Id);
					}	
				}	//	END for( Case cs: caseNewMap.values() )	
				
				Result = getBatchDataBaseOnAccountReferenceUpdate( caseIds );
				if( Result != null && Result.size() > 0 ) upr = Database.upsert(Result, BatchData__c.Fields.External_Id__c);
        		SystemLog.checkUpsertResult(Case.sObjectType.getDescribe().getName(), upr, Result, sysLog );
            	sysLog.checkInsertLog();
			}
			
		}catch( Exception E)
		{
			sysLog.addLogNoThrow( SystemLog.getSystemLog( HLPR_CaseService.ClassName,'updateCaseAccountReference', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );		
			sysLog.checkInsertLog();	          
		}
	}  
	
	public static List<BatchData__c> getBatchDataBaseOnAccountReferenceUpdate( Set<Id> caseIds  )
	{
		List<BatchData__c> Result = new List<BatchData__c> ();
		List<BatchData__c> lsData; 
	    SystemLog sysLog = new SystemLog(false, false, false, false);
       
		try
		{
			system.debug(LoggingLevel.Error,'caseIds:'+caseIds);
			if ( caseIds != null && caseIds.size() > 0  )
			{
				lsData = [ Select Id,T_ExecutingTime__c,External_Id__c From BatchData__c 
					Where T_CaseId__c IN:caseIds LIMIT 10000
				]; // Everything what were not pushed before because lack of Account reference on case 
			}
			
			if( lsData != null && lsData.size() >0 )
			{
				for(BatchData__c bd:lsData)
				{
					bd.T_ExecutingTime__c = system.now();
					Result.Add(bd);	
				}
			}
			return Result;	
		}catch(Exception E)
		{			
			sysLog.addLogNoThrow( SystemLog.getSystemLog( HLPR_CaseService.ClassName,'getBatchDataBaseOnAccountReferenceUpdate', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );			  
        	return null;
		}
	}
	
	public static void checkStatusData( List <SObject> soLst, Map<Id,sObject> oldMap, Map<Id,sObject> newMap )
    {         
    	/* 
	        checkStatusData responsible for populating timestamp based on changing status
	        @soLst:  Collection of casses processed in trigger
	        @newMap: Map Collection of new changes in case
	        @oldMap: Map Collection of old data in case
    	*/   
       
       
        /* sObject Data */
        Case oldCase;
        sObject sObj;
        List<Case> lsCase = new List<Case>();       
        Map<Id,Case> oldCases = new Map<Id,Case>();
        
        /* Custom Classes*/
        SystemLog sysLog = new SystemLog(false, false, false, false);
       
        if( oldMap != null ) oldCases = (Map<Id,Case>)oldMap;
        if( soLst != null ) lsCase = (List<Case>)soLst; 

        try
        {
        	
        	
        	for( Case cs: lsCase){
        		oldCase = oldCases.get(cs.Id);
        		if( oldCase == null ) oldCase = new Case();
        		
        		if( cs.Status != oldCase.Status){
        			if( cs.Status == Constants.CASE_STATUS_WORKING )	
        			{
        				cs.T_Status_Changed_To_Working__c  = system.now();		
        			} else if( cs.Status == Constants.CASE_STATUS_ESCALATED )
        			{
        				cs.T_Status_Changed_To_Escalated__c = system.now();	
        				
        			} else if( cs.Status == Constants.CASE_STATUS_RE_OPENED )
        			{
        				cs.T_Status_Changed_To_Re_opened__c	 = system.now();	 
        			} else if( cs.Status == Constants.CASE_STATUS_ON_HOLD_CUSTOMER )
        			{
        				cs.T_Status_Changed_To_OnHold_Customer__c = system.now();
        					
        			} else if( cs.Status == Constants.CASE_STATUS_ON_HOLD_SUPPORT )
        			{
        				cs.T_Status_Changed_To_OnHold_Support__c = system.now();	
        				
        			}  
        			 	
        		}	// END if( cs.Status != old.Status)
        	}
        	
        	sysLog.checkInsertLog();
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( HNDL_Case.ClassName,'checkStatusData', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );			  
        } 
    }
}