/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
    @Description: Helper calss designe out of scope as data container for batch processes
                  Task: --------
                  // TO DO - Better Comments 
    @Version: 1.0.1
*/
public with sharing class BatchDataCollection {

	 public static String ClassName{
        get{
            return BatchDataCollection.class.getName();
        }
    } 
    
    public Map<String,List<sObject>> ObjectContainer{get;set;}  
    public Map<String,Map<String,sObject>> IdContainer{get;set;}
    public Map<String,String> SOQL_Container{get;set;}
    public List<BatchData__c> BatchData {get;set;}
    public SystemLog SysLog {get;set;}
    public Map<String,Object> MapParam{get;set;}
    
    public BatchDataCollection( SystemLog sysLog, Map<String,Object> mapParam)
    {
        this.ObjectContainer = new Map<String,List<sObject>>();
        this.IdContainer = new Map<String,Map<String,sObject>> ();
        this.SOQL_Container = new Map<String,String>();
        this.SOQL_Container.Put( Attachment.sObjectType.getDescribe().getName(), SOQL_AttachementFromParent());
        this.SOQL_Container.Put( EmailMessage.sObjectType.getDescribe().getName(), SOQL_EmailMessage());
        this.SOQL_Container.Put( Case.sObjectType.getDescribe().getName(), SOQL_Case());
        this.SOQL_Container.Put( ContentVersion.sObjectType.getDescribe().getName(), SOQL_ContetnVersion());
        if( mapParam == null )  mapParam = new Map<String,Object>();
        this.MapParam = mapParam;
        
        if( sysLog == null )  sysLog = new SystemLog(false, false, false,false);
        this.SysLog = sysLog;
    }
    
    public void InitColections( List<BatchData__c> batchData,Map<String,String> soql_Container)
    {
        if( batchData != null ) this.BatchData = batchData;
        if( soql_Container != null ) this.SOQL_Container = soql_Container;
        String objectName;
        Map<String,sObject> mapContainer;
    
        for( BatchData__c bd:  this.BatchData )
        {
            if (!String.isEmpty(bd.Object_Id__c))
            {
                objectName = bd.ObjectName__c;
                if( String.isEmpty(objectName) && !String.isEmpty(bd.Object_Id__c)) 
                {
                    objectName = Id.valueOf(bd.Object_Id__c).getSObjectType().getDescribe().getName();
                }
                mapContainer = IdContainer.get(objectName);
                if( mapContainer == null ) mapContainer = new Map<String,sObject>();
                if( objectName == EmailMessage.sObjectType.getDescribe().getName() || 
                	objectName == Case.sObjectType.getDescribe().getName() ||
                	objectName == Attachment.sObjectType.getDescribe().getName() ||
                	objectName == ContentVersion.sObjectType.getDescribe().getName()
                ) 
                	mapContainer.put(bd.Object_Id__c,bd);
                else mapContainer.put(bd.Parent_Id__c,bd);
                IdContainer.put(objectName,mapContainer);
            }       
        }
    }
    
    public List<sObject> getSingleDataColection( String objectType,Set<String> setIds )
    {
        //Set<String> setIds = new Set<String>();       
        String SOQL ;
        DateTime startDate ;
        DateTime endDate;
        Object obj;
        List<sObject> Result = new List<sObject>();
        List<sObject> existData;
        Map<String,sObject> mapIds;
      
        try
        {           
            obj = this.MapParam.get('startDate');
            if( obj != null && (obj instanceof DateTime) )  startDate = DateTime.ValueOf(obj);
            
            obj = this.MapParam.get('endDate');
            if( obj != null && (obj instanceof DateTime) )  endDate = DateTime.ValueOf(obj);
            
            SOQL = this.SOQL_Container.get(objectType);   
            mapIds = IdContainer.get(objectType);
            if( mapIds != null ) setIds.AddAll( mapIds.keySet()); 
            
            system.debug(LoggingLevel.ERROR,'setIds:'+setIds);
            system.debug(LoggingLevel.ERROR,'SOQL:'+SOQL);
            system.debug(LoggingLevel.ERROR,'endDate:'+endDate);
            system.debug(LoggingLevel.ERROR,'startDate:'+startDate);
            
            if( !String.isEmpty(SOQL))  Result = Database.query(SOQL);  
            existData = ObjectContainer.get(objectType);
            if( existData == null ) existData = new List<sObject>();
            existData.AddAll(Result);
            ObjectContainer.put(objectType,existData); 
            return Result;
        }catch(Exception E)
        {        
            sysLog.addLogNoThrow( SystemLog.getSystemLog( BatchDataCollection.ClassName,'start', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,true );            
            return new List<sObject>();
        }       
    }
    
    public static String SOQL_AttachementFromParent()
    {
        String Result = ' Select '+SchemaClass.getFields(Attachment.sObjectType.getDescribe().getName(), true) ;
        Result += ' From ' + Attachment.sObjectType.getDescribe().getName();
        Result += ' Where ( Id IN:setIds) ';          
        return Result;
    }
    
    public static String SOQL_ContetnVersion()
    {
        String Result = ' Select '+SchemaClass.getFields(ContentVersion.sObjectType.getDescribe().getName(), true) ;
        Result += ' From ' + ContentVersion.sObjectType.getDescribe().getName();
        Result += ' Where ( Id IN:setIds) ';          
        return Result;
    }
    
    public static String SOQL_EmailMessage()
    {
        String Result = ' Select Parent.Account.C_External_Person_Key__c, ParentId, TextBody, Subject,';  
        Result += ' Parent.C_Service__c, Parent.C_Question__c, Parent.C_Concern__c, Parent.Owner.Name, Parent.OwnerId, Parent.Owner.Alias, ';
        Result += ' Parent.Owner.FirstName, Parent.Owner.LastName, LastModifiedDate, Parent.LastModifiedDate, ';
        Result += ' Parent.Status, Parent.CaseNumber, Parent.Subject, Parent.Description, Parent.C_Account_Reference__r.Name ';       
        Result += ' From  '+EmailMessage.sObjectType.getDescribe().getName()+' Where Id In:setIds  ';
        return Result;
    } 
    
    public static String SOQL_Case()
    { 
        String Result = ' Select Id, Status,CaseNumber, Subject, Description, C_Account_Reference__r.Name,';  
        Result += ' Owner.FirstName, Owner.LastName, LastModifiedDate, ';
        Result += ' C_Service__c, C_Question__c, C_Concern__c,Owner.Name, OwnerId,Owner.Alias ';
     //   Result += ' ( Select  Id, TextBody, Subject From  EmailMessages Where LastModifiedDate >=:startDate AND LastModifiedDate <:endDate )';
        Result += ' From  '+Case.sObjectType.getDescribe().getName()+' Where Id In:setIds  ';
        return Result;
    }
   
}