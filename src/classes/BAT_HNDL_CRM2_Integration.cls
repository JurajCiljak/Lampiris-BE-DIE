/*
    @Author: Juraj Ciljak
    @CreateDate: 13.10.2017
    @LastModify: 
    		26.12.2017 - Juraj
    @Description: Handler class for retrieving data from CRM2 Integration
                  Task: SFDCFR-11 -> https: https://jira.lampiris.be/browse/SFDCBE-11
    @Version: 1.0.1
*/
public with sharing class BAT_HNDL_CRM2_Integration extends BatchManager.BatchHandler{
  
  	/* Properties */
 	public static String ClassName{ 
        get{
            return BAT_HNDL_CRM2_Integration.class.getName();       
        }
    } 
    public SystemLog sysLog {get;set;}
 	public Integration_Credential__c IntegrationCred{get;set;}
 	public Map<String,Map<String,sObject>> MapScopeData{get;set;}
 	public List<BatchData__c> NextExecution{get;set;}
 	public List<BatchData__c> DataExecuted{get;set;}
 	public Map<String,CRM2_Concern_Id__c> CRM2_ConcernIds{get;set;}
 	
 	/* Constructor*/
 	public BAT_HNDL_CRM2_Integration()
    {
        super( ClassName, BatchData__c.sObjectType);          
    } 
    
    /* 
    	method setAttributes responsible for set up default values for class attribute
	 	@crm2_ConcernIds: Collection of Concern Ids from Crm2
	 	@intCred: Custom Setting for WebService credential
	 	@nextExecution: Collection of data executed in next batch if there is some issues
	 	@SystemLog sLog: System Log class
 	*/
    public void setAttributes( Map<String,CRM2_Concern_Id__c> crm2_ConcernIds, Integration_Credential__c intCred, 
    	List<BatchData__c> nextExecution, List<BatchData__c> dataExecuted, SystemLog sLog )
    {
    	if( intCred == null ) intCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
    	this.IntegrationCred = intCred;
    	if( sLog == null ) sLog = new SystemLog(false, false, false,false);
        this.sysLog = sLog;
        if( nextExecution == null ) nextExecution = new List<BatchData__c>();   
        this.NextExecution = nextExecution;
        
        if( dataExecuted == null ) dataExecuted = new List<BatchData__c>();
        this.DataExecuted = dataExecuted;
        
        if( crm2_ConcernIds == null ) crm2_ConcernIds = CustomSettings.getCRM2_ConcernId();
        this.CRM2_ConcernIds = crm2_ConcernIds;
    }
    
    /*
    	function execute responsible for preprocessing data and execute the Webservice 
    	@lsCRM2_Data: Collection of Data sent to CRM2
    	@mapScopeData: Collection of SFDC records 
    	@nextExecution: Collection of data (BatchData) execute for next batch
    	@sysLog: System Log Class
    */
    public override void execute()  
    {
    	String objectType;
    	String jsonData;
    	Id oId = null;
    	String objectId = '';
    	String resJSON = ''; // Do not put null !!!
    	Case cs; 
    	BatchData__c bData ;
    	EmailMessage eml;
    	sObject oData;
    	
    	/* Collections */
    	Map<String,sObject> subObjects = new Map<String,sObject>();
    	Map<String,sObject> ScopeData = new Map<String,sObject>();
    	List<sObject> lsObjects = new List<sObject>();
    	List<String> lsJSON_Resp = new List<String>();
    	// 26.12.2017 - Juraj
    	Set<String> escCases = new Set<String>();	// Ids of Cases which are Escalated
    	
    	/* Custom Classes */
    	AuthCallout authCall;
        CRM2_Data.CRM2_Response crm_Res;
    	CRM2_Data.CRM2_Email cmr2_EmailData;
    	List<CRM2_Data.CRM2_Email> lsCRM2_Data = new List<CRM2_Data.CRM2_Email>();
    	String objXType = '';
    	try{
    		authCall = new AuthCallout();
    		if( this.oDataContainer != null && this.MapScopeData != null  )
    		{
    			objectType = 'null';
    			CRM2_Tree crm2Tree = new CRM2_Tree();
    			crm2Tree.Init(DataExecuted, oDataContainer);
    			
    			 
    			lsCRM2_Data = CRM2_Data.convertSFDCToCRM2_Data(crm2Tree,this.CRM2_ConcernIds ,this.IntegrationCred );
    			
    			
    			
	    		jsonData = JSON.serialize( lsCRM2_Data );
	    		
	    		/* Action base from Response Status Code*/
	    		Integer http_StatusCode = authCall.basicAuthCalloutWithJSON( this.IntegrationCred.EndPoint__c, this.IntegrationCred.UserName__c, 
	    			this.IntegrationCred.Password__c, 'POST', jsonData,lsJSON_Resp,this.sysLog);
	    		
	    		if( lsJSON_Resp != null && lsJSON_Resp.size() > 0 ) resJSON = lsJSON_Resp.get(0);
	    			
				if( http_StatusCode == Constants.HTTP_STATUS_CODE_OK){
					crm_Res = CRM2_Data.deserializeJSON_To_CRM2_Response(resJSON,this.sysLog);
					getNextExecutionFromCRM2_Response( crm_Res,this.MapScopeData, this.NextExecution, this.sysLog );		
			 	} else if( http_StatusCode == Constants.HTTP_STATUS_CODE_NO_CONTENT )
			 	{
			 		/* Do Nothing */	
			 	}
			 	else
			 	{		 		
	        		
	        		getNextExecutionFromSFDC_CRM2( lsCRM2_Data, this.MapScopeData, this.NextExecution, this.sysLog );  	    	
			 	}
    		} 
    		system.debug(LoggingLevel.Error,'this.NextExecution:'+this.NextExecution);
    	}catch(Exception E)
    	{
    		sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_HNDL_CRM2_Integration.ClassName,'execute', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );            
            	
    	}
    }
    
    /*
    	function getNextExecutionFromSFDC_CRM2 responsible for preprocess data for next batch run if there is some error during synchronization
    	@lsCRM2_Data: Collection of Data sent to CRM2
    	@mapScopeData: Collection of SFDC records 
    	@nextExecution: Collection of data (BatchData) execute for next batch
    	@sysLog: System Log Class
    */
    public static void getNextExecutionFromSFDC_CRM2( List< CRM2_Data.CRM2_Email > lsCRM2_Data, Map<String,Map<String,sObject>> mapScopeData,List<BatchData__c> nextExecution, SystemLog sysLog )
    {
    	Id oId;
    	String objectType = '';
    	Map<String,sObject> subGroup ;
    	sObject obj;
    	BatchData__c bd;
    	
    	
    	try{
    		if( sysLog == null ) sysLog = new SystemLog(false, false, false,false);
    		if( mapScopeData == null ) mapScopeData = new Map<String,Map<String,sObject>>();
    		if( nextExecution == null ) nextExecution = new List<BatchData__c>();
    		
    		Map<String,BatchData__c> mapNextExecution =  new Map<String,BatchData__c>(); // To Avoid Duplicity in the list
    		
    		if( lsCRM2_Data != null )
    		{
    			for( CRM2_Data.CRM2_Email crm: lsCRM2_Data )
				{
					oId = null;
					if( !String.isEmpty( crm.Id ) )
	            	{
	            		oId = Id.valueOf( crm.Id );
	            		objectType = SchemaClass.getObjectTypeFromId( oId );
	            		subGroup = mapScopeData.get( objectType );
	            		if( subGroup != null)
	            		{
	            			obj = subGroup.get(crm.Id);	
	            			if( obj != null )
	            			{
	            				bd = (BatchData__c)obj;
	            				bd.T_ExecutingTime__c = system.now().addMinutes( 40 );
	            				mapNextExecution.put(bd.Id,bd);	            				
	            			}
		            	}
	            	}  // END if( !String.isEmpty( crm.Id ) )	
				}  // END for( CRM2_Data.CRM2_Email crm: lsCRM2_Data )
				
				nextExecution.AddAll( mapNextExecution.values() );	 
    		}  // END if( lsCRM2_Data != null )
    	}catch(Exception E)
    	{
    		sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_HNDL_CRM2_Integration.ClassName,'getNextExecutionFromSFDC_CRM2', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );            
            	
    	}	
    }
    
    public static void getNextExecutionFromCRM2_Response( CRM2_Data.CRM2_Response crm_Res,Map<String,Map<String,sObject>> mapScopeData,List<BatchData__c> nextExecution, SystemLog sysLog )
    {
    	Id oId;
    	String objectType = '';
    	Map<String,sObject> subGroup ;
    	sObject obj;
    	BatchData__c bd;
    	
    	
    	try{
    		if( sysLog == null ) sysLog = new SystemLog(false, false, false,false);
    		if( mapScopeData == null ) mapScopeData = new Map<String,Map<String,sObject>>();
    		if( nextExecution == null ) nextExecution = new List<BatchData__c>();
    		 
    		if( crm_Res != null )
    		{
    			sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_HNDL_CRM2_Integration.ClassName,'getNextExecutionFromCRM2_Response', String.valueOf(crm_Res), '?','?',62,ApexPages.severity.ERROR ) , null ,false );                         
	            if( crm_Res.extraInfo != null && crm_Res.extraInfo.size() > 0 )	            	
	            {
		            for( CRM2_Data.CRM2_Response_ExtraInfo exInfo: crm_Res.extraInfo )
		            {
		            	oId = null;
		            	if( !String.isEmpty( exInfo.Id ) )
		            	{
		            		oId = Id.valueOf( exInfo.Id );
		            		objectType = SchemaClass.getObjectTypeFromId( oId );
		            		subGroup = mapScopeData.get( objectType );
		            		if( subGroup != null)
		            		{
		            			obj = subGroup.get(exInfo.Id);	
		            			if( obj != null )
		            			{
		            				bd = (BatchData__c)obj;
		            				bd.T_ExecutingTime__c = system.now().addMinutes( 40 );
		            				nextExecution.Add(bd);
		            			}
		            		}
		            	}	
		            }	
	            }
    		}
    	}catch(Exception E)
    	{
    		sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_HNDL_CRM2_Integration.ClassName,'getNextExecutionFromCRM2_Response', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );            
            	
    	}	
    } 
    
        
}