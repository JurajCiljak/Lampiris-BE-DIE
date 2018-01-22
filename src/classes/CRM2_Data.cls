/*
    @Author: Juraj Ciljak
    @CreateDate: 21.10.2017
    @Description: Handler class for Email Message
                  Task: SFBECASE-60  -> https://jira.lampiris.be/browse/SFBECASE-60   
	@LastModify: 
			26.12.2017 - Juraj : SFBECASE-113 - > https://jira.lampiris.be/browse/SFBECASE-113
    @Version: 1.0.2
*/ 
public with sharing class CRM2_Data {

	 
	public static String getUserCRM2_Name( Id ownerId, sObject owner, String defName ){
		
		String Result = defName;
		Name nm;
		try
		{
			if( owner != null)
			{
				if( SchemaClass.getObjectTypeFromId( ownerId ) == SchemaClass.getObjectName( User.SObjectType ) ) 
				{
							 
					nm = (Name)owner;
					Result = nm.FirstName + '.'+nm.LastName;
				}
			}	// END if( owner != null)
			
			return Result;
		}catch(Exception E)
		{			
			return defName;
		}
	}
	
	public static CRM2_Concern_Id__c getConcernIdFromValues(Map<String,CRM2_Concern_Id__c>  mapCRM2_ConcernIds, 
		String service, String question, String concern)
	{
		CRM2_Concern_Id__c Result;
		if( mapCRM2_ConcernIds != null)
		{
			Result = mapCRM2_ConcernIds.get( CustomSettings.getCRM2_ConcernKey( service,question,concern ));		
		}
		if( Result == null ) Result = new CRM2_Concern_Id__c( Name = '0' );
		return Result;
	}
	
	public static CRM2_Email convertSFDCToCRM2_Data( sObject oData,BatchData__c batchData, Map<String,CRM2_Concern_Id__c>  mapCRM2_ConcernIds,Integration_Credential__c inCred )
	{
		Id oId;
		String ticketType;
		String objectType;
		String userCRM2 = '';
		String description = ''; // Description can not be null CRM2 can not process it 
		Name nm;
		CRM2_Email Result;
		EmailMessage eml;
		Attachment att;
		BatchData__c bd = batchData; 	
		Case cs;
		ContentVersion cv;
		
		/* Custom Settings */
		CRM2_Concern_Id__c crm2CoId;
		
		/* Custom classes*/
		List<CRM2_Document> documents = new List<CRM2_Document>();
        CRM2_Document document ;
		
		if( bd == null ) bd = new BatchData__c();
		if( inCred == null) inCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
		if ( mapCRM2_ConcernIds == null || mapCRM2_ConcernIds.size() <= 0) mapCRM2_ConcernIds = CustomSettings.getCRM2_ConcernId();
        
        if( oData != null )
		{
			Result = new CRM2_Email();
			Result.id = oData.Id;
			objectType = SchemaClass.getObjectTypeFromId( oData.Id )  ;
			ticketType = Constants.CRM2_EMAIL_TICKET_TYPE_INFO; 
			
			if( !String.isEmpty(bd.T_CaseId__c)) 
			{
				cs = bd.T_CaseId__r; // or (Case)oData;
				if( cs == null ) cs = new Case();
			}
			else cs = new Case();
			
			if( objectType == SchemaClass.getObjectName( Attachment.sObjectType ) )
			{
				att = (Attachment)oData;	
				
				Result.reference = cs.C_Account_Reference__r.Name;				
				Result.application = inCred.ApplicationName__c; 
		 		
				Result.user = getUserCRM2_Name( cs.OwnerId, cs.Owner, inCred.ApplicationUser__c );

				document = createCRM2_Document(att, cs);	
				
				/* Empty Fields*/
				Result.ticketType = '';
				Result.description =  '' ;
				Result.concern = '';
				
				if( document != null ) documents.Add(document);
			}else if( objectType == SchemaClass.getObjectName( ContentVersion.sObjectType ) )
			{
				cv = (ContentVersion)oData;	
				
				Result.reference = cs.C_Account_Reference__r.Name;				
				Result.application = inCred.ApplicationName__c; 
		 		
				Result.user = getUserCRM2_Name( cs.OwnerId, cs.Owner, inCred.ApplicationUser__c );

				document = createCRM2_Document(cv, cs);	
				
				/* Empty Fields*/
				Result.ticketType = '';
				Result.description =  '' ;
				Result.concern = '';
				
				if( document != null ) documents.Add(document);
			}else Result = null;
		} 
	
		if( Result != null ) Result.documents = documents;	//  We are sending empty list and attachements will be send in separate batch
		return Result;		
	}
	
	// 08.01.2018 - Juraj
	public static List<CRM2_Email> convertSFDCToCRM2_Data( CRM2_Tree crm2Tree, Map<String,CRM2_Concern_Id__c>  mapCRM2_ConcernIds,Integration_Credential__c inCred )
	{
		List<CRM2_Email> Result;
		
		String ticketType;
		String description = ''; // Description can not be null CRM2 can not process it 
		DateTime lastModifiedDate;
		
		Case cs;
		Case lineCase;
		BatchData__c bd; 	
		
		/* Custom Settings */
		CRM2_Concern_Id__c crm2CoId;
		
		/* Custom classes*/
		CRM2_Tree.CRM2_Tree_Case tree;
		List<CRM2_Email> caseCollection = new List<CRM2_Email>();
		CRM2_Email crm2_DataLine;
		List<CRM2_Tree.CRM2_Tree_Data> dataMessages;
		
		
		if( bd == null ) bd = new BatchData__c();
		if( inCred == null) inCred = CustomSettings.getIntegrationCredential( Constants.CS_CRM2_EMAIL_INTEGRATION );
		if ( mapCRM2_ConcernIds == null || mapCRM2_ConcernIds.size() <= 0) mapCRM2_ConcernIds = CustomSettings.getCRM2_ConcernId();
        
        if( crm2Tree != null )
		{
			Result = new List<CRM2_Email>();
			
    		if( crm2Tree.TreeData != null  && crm2Tree.TreeData.size() > 0)	
    		{
    			for( String key: crm2Tree.TreeData.keySet())
    			{
    				tree = crm2Tree.TreeData.get(key);
					if( tree != null )
    				{
    					bd = tree.BatchData;
    					if( !String.isEmpty(bd.T_CaseId__c) ) cs = bd.T_CaseId__r;
    					else cs = new Case();
    					
    					if( tree.Messages != null && tree.Messages.size() > 0 )
    					{
    						crm2_DataLine = new CRM2_Email();
    						
    						crm2CoId = getConcernIdFromValues( mapCRM2_ConcernIds, cs.C_Service__c, cs.C_Question__c,cs.C_Concern__c );	
    						
    						ticketType = Constants.CRM2_EMAIL_TICKET_TYPE_INFO;	
    						if( !String.isEmpty( bd.T_DescriptionHistory__c)) description = bd.T_DescriptionHistory__c;
    						caseCollection.Clear();
    						
    						dataMessages = tree.Messages;
    						if( dataMessages == null)  dataMessages = new List<CRM2_Tree.CRM2_Tree_Data>();
    						dataMessages.sort();
    						for(CRM2_Tree.CRM2_Tree_Data dat : dataMessages)
    						{
    							if( tree.Status == Constants.CASE_STATUS_ESCALATED)
    							{
    								description += '';
    								if( dat.EmailMessageData != null &&  dat.EmailMessageData.TextBody != null ) 
    									description += Constants.STRING_CRLF + dat.EmailMessageData.TextBody;
								} else
    							{
    								description = ''; lastModifiedDate = null;
    								if( dat.CaseData != null && dat.CaseData.LastModifiedDate != null )
    								{ 
    									lineCase = dat.CaseData;
    									lastModifiedDate = lineCase.LastModifiedDate;
    									if( !String.isEmpty( dat.BatchData.T_DescriptionHistory__c)) description = dat.BatchData.T_DescriptionHistory__c;
    									else description = getCRM2Description( lineCase,lineCase.Owner );	
    								}
									else if(  dat.EmailMessageData != null && dat.EmailMessageData.LastModifiedDate != null) 
									{
										lastModifiedDate = dat.EmailMessageData.LastModifiedDate;
										if( !String.isEmpty(dat.EmailMessageData.ParentId)) 
											lineCase = dat.EmailMessageData.Parent;
										if( lineCase == null ) lineCase = new Case();
										description =  getCRM2Description( lineCase,lineCase.Owner );	
										if( dat.EmailMessageData.TextBody != null ) description += Constants.STRING_CRLF + dat.EmailMessageData.TextBody;
									}
									
									crm2_DataLine = createCRM2_Line( dat.BatchData, lineCase, ticketType, description, lastModifiedDate, inCred, crm2CoId  );
																		
    								if( crm2_DataLine != null ) caseCollection.Add(crm2_DataLine); 
    								
    							}
    						}	// END for(CRM2_Tree.CRM2_Tree_Data dat : tree.Messages)		
    						
    						// If case is escalated only one line to the CRM2 with concatination of TextBody
    						if( tree.Status == Constants.CASE_STATUS_ESCALATED)
    						{
    							ticketType = Constants.CRM2_EMAIL_TICKET_TYPE_TT;	
    							lineCase = cs;
    							caseCollection.Clear();
    							lastModifiedDate = lineCase.LastModifiedDate;
    							crm2_DataLine = createCRM2_Line( bd, lineCase,ticketType, description, lastModifiedDate, inCred, crm2CoId  );
								if( crm2_DataLine != null ) caseCollection.Add(crm2_DataLine); 									
    						}	
    						
    				 		if( caseCollection != null && caseCollection.size() > 0 ) Result.AddAll(caseCollection);
    				 		
    					}	// END  if( tree.Messages != null && tree.Messages.size() > 0 )			
					}	// END if( tree != null )
				}	//  END for( String key: crm2Tree.TreeData.keySet())
    		}	// END  if( crm2Tree.TreeData != null  && crm2Tree.TreeData.size() > 0)	
		}	//  END  if( crm2Tree != null )   		 
		
		return Result;		
	}
	
	public static CRM2_Email createCRM2_Line ( BatchData__c bd, Case cs,String ticketType, String description, 
		DateTime lastModifiedDate, Integration_Credential__c inCred, CRM2_Concern_Id__c crm2CoId  )
	{
		CRM2_Email Result; 
		if( description == null ) description = '';
		List<CRM2_Document> documents = new List<CRM2_Document>();
		if( cs != null && bd != null)
		{
			Result = new CRM2_Email();
			Result.Id = bd.Id;
			if( lastModifiedDate == null ) lastModifiedDate = bd.LastModifiedDate;
			Result.lastModifiedDate = lastModifiedDate.format('yyyy-MM-dd HH:mm:ss');
			Result.reference = cs.C_Account_Reference__r.Name;	
			Result.application = inCred.ApplicationName__c;
			Result.caseNumber = cs.CaseNumber;
			Result.ticketType = ticketType;
			Result.concern = crm2CoId.Name;
			Result.user = getUserCRM2_Name( cs.OwnerId, cs.Owner, inCred.ApplicationUser__c );
			Result.description = EncodingUtil.base64Encode( Blob.ValueOf( description));
			Result.documents = documents;		//  We are sending empty list and attachements will be send in separate batch	
		}
		return Result;	
	}
	
	public static CRM2_Document createCRM2_Document(Attachment att, Case cs) 
    {
        CRM2_Document Result;
        
        if( att != null ) 
        {
        	Result = new CRM2_Document();
        	Result.firstName = '';
       		Result.lastName = '';
       		Result.id = att.Id;
	        if( cs != null )
	        {
	        	if( !String.isEmpty(cs.AccountId))
	        	{
	        		Result.firstName = cs.Account.FirstName;
	        		Result.lastName = cs.Account.LastName;
	        	}	        	
	        }  // END if( cs != null )
        
	        Result.mimeType = att.ContentType; // application/pdf
	        Result.fileName = cs.C_Account_Reference__r.Name+'_'+att.Name;
	        Result.content = String.valueOf(EncodingUtil.base64Encode(att.Body)); 
        }
        return Result;  
    }
    
    public static CRM2_Document createCRM2_Document(ContentVersion cv, Case cs) 
    {
        CRM2_Document Result;
        
        if( cv != null ) 
        {
        	Result = new CRM2_Document();
        	Result.firstName = '';
       		Result.lastName = '';
       		Result.id = cv.Id;
	        if( cs != null )
	        {
	        	if( !String.isEmpty(cs.AccountId))
	        	{
	        		Result.firstName = cs.Account.FirstName;
	        		Result.lastName = cs.Account.LastName;
	        	}	        	
	        }  // END if( cs != null )
        
	        Result.mimeType = getiPortalMineType( cv.FileExtension ); // application/pdf
	        Result.fileName = cs.C_Account_Reference__r.Name+'_'+cv.PathOnClient;
	        Result.content = String.valueOf(EncodingUtil.base64Encode(cv.VersionData)); 
        }
        return Result;  
    }
	
    public static String getCRM2Description( Case cs, sObject obj )
	{
		// Case Number, Case Owner(First Name, Last Name), Case Status, Case Object, Case Description
		String Result = '';
		String ownerName = '';
		Id oId;
		if( cs != null )
		{
			Result = 'Case no.: '+cs.CaseNumber ;
			
			if( obj != null ) 
			{
				oId = obj.Id;
				if( SchemaClass.getObjectTypeFromId( oId ) == SchemaClass.getObjectName( Group.sObjectType ))
				{
					ownerName = String.ValueOf(obj.get('Name'));
					if( !String.isEmpty(ownerName))  Result += ',Owner: '+ownerName;
				} else if( SchemaClass.getObjectTypeFromId( oId ) == SchemaClass.getObjectName( User.sObjectType ))
				{
					ownerName = String.ValueOf(obj.get('Name'));
					if( !String.isEmpty(ownerName))  Result += ',Owner: '+ownerName;					
				} 
			}  // END if( obj != null ) 
			
			if( !String.isEmpty(cs.Status)) Result += ', Status: '+cs.Status;
			if( !String.isEmpty(cs.Subject)) Result +=', Subject: ' + cs.Subject;
			//if( !String.isEmpty(cs.Description)) Result += ',Description: ' + cs.Description;
			
		}  // END if( cs != null )
   		return Result;
    } 
    
    public static CRM2_Data.CRM2_Response deserializeJSON_To_CRM2_Response( String jsonData, SystemLog sysLog)
    {
    	CRM2_Data.CRM2_Response Result;
    	
    	if ( sysLog == null ) sysLog = new SystemLog(false, false, false,false);
    	
    	try{
    		if( !String.isEmpty(jsonData))
    			Result = (CRM2_Data.CRM2_Response)JSON.deserialize(jsonData, CRM2_Data.CRM2_Response.class);
    		return Result;
    	}catch(Exception E)
    	{
    		sysLog.addLogNoThrow( SystemLog.getSystemLog( CRM2_Data.class.getName(),'deserializeJSON_To_CRM2_Response', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );            
            return null;
    	}
    }
    
    
    
    /* Wrapper Class Definition*/
    public class CRM2_Document
    {
    	public String id{get;set;}
		public String firstName{get;set;}
		public String lastName{get;set;}
		public String mimeType{get;set;}
		public String fileName{get;set;}
		public String content{get;set;}
    }
    
    public class CRM2_Email
	{
		public String id{get;set;}
		public String caseNumber{get;set;}
		public String lastModifiedDate{get;set;}
		public String reference{get;set;}
		public String application{get;set;}
		public String user{get;set;}
		public String ticketType{get;set;}
		public String concern{get;set;}
		public String description{get;set;}
		public List<CRM2_Document> documents{get;set;}
		
	}
	
/* MOVE */
	
	public class CRM2_Response
	{
		public String code{get;set;}
		public String message{get;set;}
	  	public List<CRM2_Response_ExtraInfo> extraInfo{get;set;}

	}
	
	public class CRM2_Response_ExtraInfo
	{
		public String id{get;set;}
	} 
	
	public static String getiPortalMineType( String fileExtension )
	{
		String Result = '';
		if( fileExtension == null )  fileExtension = '';
		Result = '/'+fileExtension;

		iPortal_MimeType__c ip_MT = CustomSettings.get_iPortal_MimeType( fileExtension.toLowerCase() );
		if( ip_MT != null && !String.isEmpty(ip_MT.MimeType__c) ) 
		{  
			Result = ip_MT.MimeType__c;
		}
		return Result;
	}
}