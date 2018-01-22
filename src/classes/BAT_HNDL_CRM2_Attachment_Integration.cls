/*
    @Author: Juraj Ciljak
    @CreateDate: 13.10.2017
    @LastModify: 
    @Description: Webservice for retrieving data from EL1
                  Task: SFDCFR-11 -> https: https://jira.lampiris.be/browse/SFDCBE-11
    @Version: 1.0.1
*/
public with sharing class BAT_HNDL_CRM2_Attachment_Integration extends BatchManager.BatchHandler{
	
    public static String ClassName{
        get{
            return BAT_HNDL_CRM2_Attachment_Integration.class.getName();       
        }
    }
    
    public SystemLog sysLog {get;set;}
 	public Integration_Credential__c IntegrationCred{get;set;}
 	public Map<String,Map<String,sObject>> MapScopeData{get;set;}
 	public List<BatchData__c> NextExecution{get;set;}
 	public Map<String,CRM2_Concern_Id__c> CRM2_ConcernIds{get;set;}
 	public BAT_HNDL_CRM2_Attachment_Integration()
    {
        super( ClassName, Attachment.sObjectType);          
    } 
    
    public void setAttributes( Map<String,CRM2_Concern_Id__c> crm2_ConcernIds, Integration_Credential__c intCred, 
    	List<BatchData__c> nextExecution, SystemLog sLog )
    {
    	if( intCred == null ) intCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
    	this.IntegrationCred = intCred;
    	if( sLog == null ) sLog = new SystemLog(false, false, false,false);
        this.sysLog = sLog;
        if( nextExecution == null ) nextExecution = new List<BatchData__c>();   
        this.NextExecution = nextExecution;
        
        if( crm2_ConcernIds == null ) crm2_ConcernIds = CustomSettings.getCRM2_ConcernId();
        this.CRM2_ConcernIds = crm2_ConcernIds;
    }
    
    public override void execute() 
    {
    	AuthCallout authCall;
       	Id oId = null;
    	String objectId = '';
    	BatchData__c bData ;
    	EmailMessage eml;
    	Case cs;
    	sObject oData;
    	String objectType;
    	String jsonData;
    	List<String> lsJSON_Resp = new List<String>();
    	String resJSON = ''; // Do not put null !!!
    	Map<String,sObject> subObjects = new Map<String,sObject>();
    	Map<String,sObject> ScopeData = new Map<String,sObject>();
    	List<sObject> lsObjects = new List<sObject>();
    	
    	/* Custom Classes */
    	CRM2_Data.CRM2_Response crm_Res;
    	CRM2_Data.CRM2_Email cmr2_EmailData;
    	List<CRM2_Data.CRM2_Email> lsCRM2_Data = new List<CRM2_Data.CRM2_Email>();
    	
    	try{
    		authCall = new AuthCallout();
    		
    		if( this.oDataContainer != null && this.MapScopeData != null  )
    		{
    			for(String objType: this.MapScopeData.keySet() )
    			{
    				ScopeData = this.MapScopeData.get(objType);
    				if( ScopeData == null ) ScopeData = new Map<String,sObject>();
    				for( sObject obj:ScopeData.values())
    				{
    					cmr2_EmailData = null;
    					oId = obj.Id; 
	    				objectType = ''; objectId = '';
	    				bData = null; oData = null;
	    				if( !String.isEmpty(oId)) objectType = oId.getSObjectType().getDescribe().getName();	
	    				
	    				if( objectType == BatchData__c.sObjectType.getDescribe().getName())
	    				{
	    					 bData = (BatchData__c)obj;
	    					 objectId = bData.Object_Id__c;
	    					 oId = null;
	    					 objectType = '';
	    					 if( !String.isEmpty(objectId) ) 
	    					 {
	    					 	oId = Id.ValueOf(objectId);
	    					 	objectType = oId.getSObjectType().getDescribe().getName();
	    					 }
	    					 subObjects.Clear();
	    					 lsObjects = oDataContainer.get(objectType);
	    					 if( lsObjects != null )
			    			 	subObjects.putAll(lsObjects); 
			    			 	
		    			   	 if( subObjects != null && !String.isEmpty(objectId) )
			    			 {
			    			 	oData = subObjects.get(objectId);
			    			 	if( oData != null ) cmr2_EmailData = CRM2_Data.convertSFDCToCRM2_Data( oData, bData ,  
			    			 		this.CRM2_ConcernIds ,this.IntegrationCred 
		    			 		);
		    			 		
			    			 	if( cmr2_EmailData != null ) lsCRM2_Data.Add(cmr2_EmailData);
			    			 	
			    			 }	//  END  if( subObjects != null && !String.isEmpty(objectId) )			    			 
	    				}	//  END if( objectType == BatchData__c.sObjectType.getDescribe().getName())
    				}	//  END for( sObject obj:ScopeData.values())
    			}	//  END for(String objType: this.MapScopeData.keySet() ) 			
    		}	//  END if( this.oDataContainer != null && this.MapScopeData != null  )
    		
    		jsonData = JSON.serialize(  lsCRM2_Data );
    		
		 	Integer http_StatusCode = authCall.basicAuthCalloutWithJSON( this.IntegrationCred.EndPoint__c, this.IntegrationCred.UserName__c, 
    			this.IntegrationCred.Password__c, 'POST', jsonData,lsJSON_Resp,this.sysLog);
    			
    		if(lsJSON_Resp != null && lsJSON_Resp.size() > 0) resJSON = lsJSON_Resp.get(0);	
    			
    		if( http_StatusCode == Constants.HTTP_STATUS_CODE_OK){
				crm_Res = CRM2_Data.deserializeJSON_To_CRM2_Response(resJSON,this.sysLog);
				BAT_HNDL_CRM2_Integration.getNextExecutionFromCRM2_Response( crm_Res,this.MapScopeData, this.NextExecution, this.sysLog );
    	 	} else if( http_StatusCode == Constants.HTTP_STATUS_CODE_NO_CONTENT )
		 	{
		 		/* Do Nothing */	
		 	}
		 	else
		 	{		 		
        		BAT_HNDL_CRM2_Integration.getNextExecutionFromSFDC_CRM2( lsCRM2_Data, this.MapScopeData, this.NextExecution, this.sysLog );  	    	
		 	}	
    	}catch(Exception E)
    	{
    		sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_HNDL_CRM2_Attachment_Integration.ClassName,'execute', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );            
            	
    	}
    }
}