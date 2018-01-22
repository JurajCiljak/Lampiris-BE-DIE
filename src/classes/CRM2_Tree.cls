/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @LastModify: 
			08.01.2018 - Juraj : SFBECASE-113 - > https://jira.lampiris.be/browse/SFBECASE-113
    @Description: Handler class for 
    @Version: 1.0.1
*/ 
public with sharing class CRM2_Tree{
		
	public Map<String,CRM2_Tree_Case> TreeData{get;set;} // Key is Case Number
	
	public CRM2_Tree()
	{
		this.TreeData = new Map<String,CRM2_Tree_Case>();		
	}
	
	public void Init( List<BatchData__c> batchData ,Map<String,List<sObject>>  oDataContainer)
	{	
		Id oId;
		String objectType;
		String objectId = '';
		String caseNumebr = '';
		Case cs;
		sObject oData;
		CRM2_Tree_Case treeCS;			
		List<sObject> lsObjects = new List<sObject>();
		/* Collections */
		Map<String,sObject> subObjects = new Map<String,sObject>();
		this.TreeData.Clear();
		if( oDataContainer == null ) oDataContainer = new Map<String,List<sObject>> ();
		
		if( batchData != null )
		{
			for( BatchData__c bd: batchData )
			{
				system.debug(LoggingLevel.Error,'bd:'+bd);
				cs = bd.T_CaseId__r;
				if( cs == null )  cs = new Case();
				treeCS = TreeData.get(cs.CaseNumber);
				
				oId = null;
				objectType = 'null';
				objectId = bd.Object_Id__c;
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
    			}
    			
    	
    			
				if ( treeCS == null ) treeCS = new  CRM2_Tree_Case( bd, oData );
				else treeCS.AddData( bd, oData );
				TreeData.put(cs.CaseNumber,treeCS);
			}
		}
	}
		 

	
	
	public class CRM2_Tree_Case implements Comparable{
		public BatchData__c BatchData {get;set;}
		public Case CaseData{get;set;}	
		public DateTime CompareTimeIndex{get;set;}	
		public List<CRM2_Tree_Data> Messages {get;set;}
		 
		public String Status{
			get{ 
				String Result = '';
				if( BatchData != null)
				{
					if ( !String.isEmpty(BatchData.ObjectStatus__c) ) 
						Result = BatchData.ObjectStatus__c;
					else if( !String.isEmpty(BatchData.T_CaseId__c) ) 
						Result = BatchData.T_CaseId__r.Status;
				}
				return Result; 
			}
		
		}
		
		public CRM2_Tree_Case( BatchData__c batchData, sObject oData)
		{
			this.BatchData = batchData;
			this.CaseData = null;
			this.Messages = new List<CRM2_Tree_Data>();
			CRM2_Tree_Data crm2TreeData;
			addData( batchData, oData);
		} 
		 
		public void addData( BatchData__c batchData, sObject oData)
		{
			Case cs = null; 
			EmailMessage eml;
			CRM2_Tree_Data crm2TreeData;
			if( oData != null)
			{
				if( !String.isEmpty( batchData.T_CaseId__c )) cs = batchData.T_CaseId__r;
				if( SchemaClass.getObjectTypeFromId( oData.Id ) == SchemaClass.getObjectName( Case.sObjectType ) )
				{
					cs =  (Case)oData;	
					crm2TreeData = new  CRM2_Tree_Data( batchData, this.CaseData, null );
				} else if( SchemaClass.getObjectTypeFromId( oData.Id ) == SchemaClass.getObjectName( EmailMessage.sObjectType ) )
				{
					eml =  (EmailMessage)oData;	
					cs = eml.Parent;
					crm2TreeData = new  CRM2_Tree_Data( batchData, null, eml );
									
				}
				
				if( this.CaseData == null || batchData.ObjectStatus__c == Constants.CASE_STATUS_ESCALATED ){
					this.CaseData = cs;	
					this.CompareTimeIndex = cs.LastModifiedDate;
				}
				
				Messages.Add( crm2TreeData );	
			}
		}  
		 
		public Integer compareTo(Object compareTo) {
	        CRM2_Tree_Data compareToData = (CRM2_Tree_Data)compareTo;
	        if ( this.CompareTimeIndex == compareToData.CompareTimeIndex) return 0;
	        if ( this.CompareTimeIndex > compareToData.CompareTimeIndex) return 1;
	        return -1;        
    	} 
	} 
	
	public class CRM2_Tree_Data implements Comparable{
		public BatchData__c BatchData {get;set;}
		public EmailMessage EmailMessageData{get;set;}	
		public Case CaseData{get;set;}	
		public DateTime CompareTimeIndex{get;set;}
		
		public CRM2_Tree_Data( BatchData__c batchData, Case caseData, EmailMessage messageData ){
			this.BatchData = batchData;
			this.EmailMessageData = messageData;	
			this.CaseData = caseData;
			
			if( this.BatchData != null)
			{
				this.CompareTimeIndex = this.BatchData.LastModifiedDate;		
			} else if( this.CaseData != null )
			{
				this.CompareTimeIndex = this.CaseData.LastModifiedDate;	
			}
			else if( this.EmailMessageData != null)
			{
				this.CompareTimeIndex = this.EmailMessageData.LastModifiedDate;		
			}
			
		}
		
		
		public Integer compareTo(Object compareTo) {
	        CRM2_Tree_Data compareToData = (CRM2_Tree_Data)compareTo;
	        if ( this.CompareTimeIndex == compareToData.CompareTimeIndex) return 0;
	        if ( this.CompareTimeIndex < compareToData.CompareTimeIndex) return 1;
	        return -1;        
    	} 
	
	}
}