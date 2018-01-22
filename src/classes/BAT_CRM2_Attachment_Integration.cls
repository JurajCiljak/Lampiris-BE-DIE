/*
    @Author: Juraj Ciljak
    @CreateDate: 23.10.2017
    @LastModify: 
    @Description: Webservice for retrieving data from EL1
                  Task: Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60  
    @Version: 1.0.1
*/
global class BAT_CRM2_Attachment_Integration implements Database.Batchable<sObject>,Database.Stateful , Database.AllowsCallouts{

	public Boolean IsParentSet{get;set;}
	public Set<String> ParentIds{get;set;}
    public SystemLog sysLog {get;set;}
    public List<BatchData__c> NextExecution{get;set;}
    public  Integration_Credential__c IntegrationCred{get;set;}
	public static String ClassName{
        get{
            return BAT_CRM2_Attachment_Integration.class.getName();
        }
    }  
    
    public BAT_CRM2_Attachment_Integration(Set<String> parentIds, Boolean isParentSet)
    {
    	if( ParentIds == null ) parentIds = new Set<String>();
    	this.ParentIds = parentIds;
    	this.sysLog = new SystemLog(false, false, false,false);
        this.NextExecution = new List<BatchData__c>();	
        this.IntegrationCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
        if( isParentSet == null) isParentSet = true;
        this.IsParentSet = isParentSet;
    }  

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	try{
            
            String SOQL;   
           	SOQL = getSOQL_ForBATCH( this.IsParentSet );
            system.debug(LoggingLevel.ERROR,'ParentIds:'+this.ParentIds);
            system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
            return Database.getQueryLocator(SOQL);
       }catch(Exception E)
       {        
           sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Attachment_Integration.ClassName,'start', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );            
           return Database.getQueryLocator(' Select Id From ' + BatchData__c.sObjectType.getDescribe().getName() +' Limit 0 '); /* Could not return null !!!!!!! */
       } 	
    
    }
    
    global void execute(Database.BatchableContext BC, List<BatchData__c> scope)
    {
    	BatchDataCollection batchDC;
    	String objectType = ''; 
    	Map<String,sObject> mapScope; 
        Set<String> setIds = new Set<String>(); 
        List<sObject> lsData ; 
    	try{	
    		
    		 
    		BAT_HNDL_CRM2_Attachment_Integration hndl_CRM2 = new BAT_HNDL_CRM2_Attachment_Integration();
            hndl_CRM2.setAttributes(/* CustomSettings.getCRM2_ConcernId()*/ null, this.IntegrationCred, this.NextExecution, this.sysLog);
           
           
            
			batchDC = new BatchDataCollection( this.sysLog , null);
			objectType = Attachment.sObjectType.getDescribe().getName();
			batchDC.InitColections( scope ,batchDC.SOQL_Container); 
			mapScope = batchDC.IdContainer.get(objectType);
			
			
			system.debug(LoggingLevel.Error,'batchDC.IdContainer:'+batchDC.IdContainer );
			system.debug(LoggingLevel.Error,'batchDC.MapScopeData:'+batchDC.IdContainer );
			
			
			if( mapScope == null )  mapScope = new Map<String,sObject>();
			setIds.AddAll(mapScope.keySet()); 
			
			hndl_CRM2.MapScopeData = batchDC.IdContainer;
                
            /* Attachment */
            lsData = batchDC.getSingleDataColection( objectType, setIds); 
            system.debug(LoggingLevel.Error,'lsData :'+lsData.size()+'/'+lsData );
            
            
            /* Content Version */
            setIds.Clear();
            objectType = ContentVersion.sObjectType.getDescribe().getName();
            mapScope = batchDC.IdContainer.get(objectType);
            if( mapScope == null )  mapScope = new Map<String,sObject>();
			setIds.AddAll(mapScope.keySet()); 
			lsData = batchDC.getSingleDataColection( objectType, setIds); 
            
            
            
            hndl_CRM2.setBasicAttributes( false,true,false, batchDC.ObjectContainer, this.sysLog);                    
            BatchManager.createHandler(
                BAT_HNDL_CRM2_Attachment_Integration.class,hndl_CRM2);  
		
    	}catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Attachment_Integration.ClassName,'finish', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                     
        	
    	}
    }
    
    global void finish(Database.BatchableContext BC)
    {
    	SystemLog sysLog = new SystemLog(false, false, false,false);
        Set<String> AttIntIds = new Set<String>();
        Boolean contains;
        try{
            ID jobId = BC.getJobId();
            
            if( this.NextExecution != null && this.NextExecution.size() > 0 )
            {
            	//Database.upsert(this.NextExecution, BatchData__c.Fields.External_Id__c);
            	
            	for( BatchData__c bd : this.NextExecution )
            	{	
            		AttIntIds.Add( bd.Object_Id__c );
            		
            	}
            } else AttIntIds.Clear();
            this.sysLog.checkInsertLog();
            
            system.debug(LoggingLevel.Error,'AttIntIds:'+AttIntIds);
            system.debug(LoggingLevel.Error,'this.ParentIds:'+this.ParentIds);
            system.debug(LoggingLevel.Error,'this.NextExecution:'+this.NextExecution);
             
            
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Attachment_Integration.ClassName,'finish', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );                     
        }
    } 
    
    public static String getSOQL_ForBATCH( Boolean isParentSet )
    {
        String Result = ' Select '+SchemaClass.getFields(BatchData__c.sObjectType.getDescribe().getName(),true);
        Result += ' , T_CaseId__r.Status, T_CaseId__r.CaseNumber, T_CaseId__r.Subject, T_CaseId__r.Description,T_CaseId__r.C_Account_Reference__r.Name, ';
        Result += ' T_CaseId__r.C_Service__c, T_CaseId__r.C_Question__c, T_CaseId__r.C_Concern__c, ';
        Result += ' T_CaseId__r.Owner.FirstName, T_CaseId__r.Owner.LastName, T_CaseId__r.OwnerId, T_CaseId__r.AccountId, ';
        Result += ' T_CaseId__r.Account.FirstName, T_CaseId__r.Account.LastName ';
        Result += ' From ' + SchemaClass.getObjectName( BatchData__c.sObjectType );//BatchData__c.sObjectType.getDescribe().getName();
        if( isParentSet == true )
        	Result += ' Where ( Parent_Id__c IN :ParentIds ) AND  ';
        else Result += ' Where ( Object_Id__c IN :ParentIds ) AND  ';
        Result += ' ( Process__c =\''+BAT_HNDL_CRM2_Attachment_Integration.ClassName+'\')';
        Result += ' Order By ObjectName__c ';
        if ( Test.IsRunningTest() ) Result += ' LIMIT 10 ';
        return Result;
    }   
    
}