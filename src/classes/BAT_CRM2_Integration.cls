/*
    @Author: Juraj Ciljak
    @CreateDate: 13.10.2017
    @LastModify: 
    		27.12.2017 - Juraj - SFBECASE-113
    @Description: Webservice for retrieving data from EL1
                  Task: SFDCFR-11 -> https: https://jira.lampiris.be/browse/SFDCBE-11
                  		SFBECASE-113 - > https://jira.lampiris.be/browse/SFBECASE-113
    @Version: 1.0.1
*/   
global class BAT_CRM2_Integration implements Database.Batchable<sObject>,Database.Stateful , Database.AllowsCallouts{
    
    public Set<String> ParentIds{get;set;}    
    public String RunningVersion{get;set;}
    private DateTime StartTime{get;set;}
    private DateTime FinishTime{get;set;}
    private Integer NumberOfMinutes{get;set;}
    public  Integration_Credential__c IntegrationCred{get;set;}
    public List<BatchData__c> NextExecution{get;set;}
    public SystemLog sysLog {get;set;} 
    public static String ClassName{ 
        get{
            return BAT_CRM2_Integration.class.getName();
        }
    } 
    
    /* Constructor */   
    public BAT_CRM2_Integration(DateTime startTime,DateTime finishTime, Integer numberOfMinutes,String runVersion)
    {
        
        if( startTime == null ) 
        {    
            startTime = Datetime.newInstance(system.now().year(), system.now().month(), system.now().day(),
                                             system.now().hour(),system.now().minute(),0
            );
        } else 
        {
        	startTime = Datetime.newInstance(startTime.year(), startTime.month(), startTime.day(),
                                             startTime.hour(),startTime.minute(),0
            );    
        }
        
        

        this.NumberOfMinutes = numberOfMinutes;
        if( this.NumberOfMinutes == null ) this.NumberOfMinutes = 20; // Default - 20 minutes from now  
        
        this.StartTime = startTime.addMinutes( (-1) * this.NumberOfMinutes);
        
        if ( finishTime == null ) 
        {
            finishTime = this.StartTime.addMinutes(this.NumberOfMinutes);
        } else
        {
        	finishTime = Datetime.newInstance(finishTime.year(), finishTime.month(), finishTime.day(),
                                             finishTime.hour(),finishTime.minute(),0
            );      
        }
        
        this.FinishTime = finishTime;
        
        this.IntegrationCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
        this.NextExecution = new List<BatchData__c>();
         
        if( String.isEmpty(runVersion)) runVersion = SCH_CRM2_Integeration.CRON_SCH_CRM2_INTEGRATION_FIRST_RUN;
        this.RunningVersion = runVersion;
        this.ParentIds = new Set<String>();
        
        
        this.sysLog = new SystemLog(false, false, false,false);
    }
    
    /* 
        method start responsible for starting batch process
        @BC: class for content of the batch
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        try{
            
            String SOQL;   
            DateTime endDate = this.FinishTime; 
            DateTime startDate = this.StartTime;
            SOQL = getSOQL_ForBATCH();
            
            system.debug(LoggingLevel.ERROR,'RunningVersion:'+this.RunningVersion);
            system.debug(LoggingLevel.ERROR,'startDate:'+startDate);
            system.debug(LoggingLevel.ERROR,'endDate:'+endDate);
            system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
            return Database.getQueryLocator(SOQL);
       }catch(Exception E)
       {        
           sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Integration.ClassName,'start', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );            
           return Database.getQueryLocator(' Select Id From ' + BatchData__c.sObjectType.getDescribe().getName() +' Limit 0 '); /* Could not return null !!!!!!! */
       }       
    }
     
     /* 
        method execute responsible for executing the batch and call the WebService in Handler class
        @BC: class for content of the batch
        @scope: Collection of data for processing
    */
    global void execute(Database.BatchableContext BC, List<BatchData__c> scope)
    {
        String objectType;
        Map<String,sObject> mapScope; 
        Set<String> setIds = new Set<String>(); 
        List<sObject> lsData ; 
        Map<String,Object> mapParam ;
        try{
            BAT_HNDL_CRM2_Integration hndl_CRM2 = new BAT_HNDL_CRM2_Integration();
            hndl_CRM2.setAttributes( CustomSettings.getCRM2_ConcernId(), this.IntegrationCred, this.NextExecution, scope , this.sysLog);
            
            mapParam = getQueryParameters();
             
            BatchDataCollection batchDC;
            batchDC = new BatchDataCollection( this.sysLog, mapParam );
            objectType = EmailMessage.sObjectType.getDescribe().getName();
            
            for( BatchData__c bd: scope)
            {
                if( !String.isEmpty(bd.Object_Id__c)) this.ParentIds.Add(bd.Object_Id__c);
            }
             
            batchDC.InitColections( scope ,batchDC.SOQL_Container); 
            mapScope = batchDC.IdContainer.get(objectType);
        
            if( mapScope == null )  mapScope = new Map<String,sObject>();
            setIds.AddAll(mapScope.keySet()); 
             
            hndl_CRM2.MapScopeData = batchDC.IdContainer;
                
            // EmailMessage 
            lsData = batchDC.getSingleDataColection( objectType, setIds); 
          
            //	Cases
            setIds.Clear();
            objectType = Case.sObjectType.getDescribe().getName();
            mapScope = batchDC.IdContainer.get(objectType);
            if( mapScope == null )  mapScope = new Map<String,sObject>();
            setIds.AddAll(mapScope.keySet()); 
            lsData = batchDC.getSingleDataColection( objectType, setIds); 
        
            hndl_CRM2.setBasicAttributes( false,true,false, batchDC.ObjectContainer, this.sysLog);                    
            
            // Handler class for calling WebService
            BatchManager.createHandler(
                BAT_HNDL_CRM2_Integration.class,hndl_CRM2);                               
        
           
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Integration.ClassName,'execute', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                       
        }
    }
    
    /* 
        method finish is executing after the batch is finish
        @BC: class for content of the batch
    */
    global void finish(Database.BatchableContext BC)
    {
          
        if( sysLog == null ) sysLog = new SystemLog(false, false, false,false);
        Set<String> AttIntIds = new Set<String>();
        Boolean contains;
        try{
            ID jobId = BC.getJobId();
            
            if( this.NextExecution != null && this.NextExecution.size() > 0 )
            {
                // If there is some failure data will run in next batch 
                Database.upsert(this.NextExecution, BatchData__c.Fields.External_Id__c);
                
                for( BatchData__c bd : this.NextExecution )
                {   
                    contains = false;
                    contains = this.ParentIds.contains( bd.Object_Id__c );
                    if( contains = false)  AttIntIds.Add( bd.Object_Id__c );
                    
                }
            } else AttIntIds.AddAll( this.ParentIds );
            
            this.sysLog.checkInsertLog();
                      
            Id batchId = database.executeBatch(new BAT_CRM2_Attachment_Integration(AttIntIds,true),1);
             
             
            
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Integration.ClassName,'finish', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );                     
        }
    } 
    
   public Map<String,Object> getQueryParameters()
    {
    	Map<String,Object> Result = new Map<String,Object>();
    	try{
    		Result.Put('startDate',this.StartTime);
    		Result.Put('endDate',this.FinishTime);
    		return Result;
    	}catch( Exception E )	
    	{
    		sysLog.addLogNoThrow( SystemLog.getSystemLog( BAT_CRM2_Integration.ClassName,'getQueryParameters', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                     
        	return new Map<String,Object>();
    	}
    }
    
    public static String getSOQL_ForBATCH()
    {
        String Result = ' Select '+SchemaClass.getFields(BatchData__c.sObjectType.getDescribe().getName(),true);
        Result += ' , T_CaseId__r.Status,T_CaseId__r.CaseNumber, T_CaseId__r.Subject,T_CaseId__r.Description,T_CaseId__r.C_Account_Reference__r.Name, ';
        Result += ' T_CaseId__r.C_Service__c, T_CaseId__r.C_Question__c, T_CaseId__r.C_Concern__c, T_CaseId__r.LastModifiedDate, ';
        Result += ' T_CaseId__r.Owner.Name, T_CaseId__r.OwnerId, T_CaseId__r.AccountId, T_CaseId__r.Owner.Alias, T_CaseId__r.Owner.FirstName, T_CaseId__r.Owner.LastName, ';
        Result += ' T_CaseId__r.Account.FirstName, T_CaseId__r.Account.LastName ';
        Result += ' From ' + SchemaClass.getObjectName( BatchData__c.sObjectType );//BatchData__c.sObjectType.getDescribe().getName();
        Result += ' Where ( T_CaseId__r.C_Account_Reference__c != null ) AND  ';
        Result += ' ( T_ExecutingTime__c >=:startDate AND T_ExecutingTime__c <:endDate) AND ';
        Result += ' ( Process__c =\'BAT_HNDL_CRM2_Integration\')';
        Result += ' Order By ProcessOrder__c ASC, ObjectName__c ';
        if ( Test.IsRunningTest() ) Result += ' LIMIT 10 ';
        return Result;
    }   
}