/*
    @ Author: Juraj Ciljak
    @ Description: Test class stored helper function for generate records in Unit Test
    @ CreatedDate: 24.07.2017
    @ LastModify:
    @ Notes:  
    @ Version: 1.0.1
*/
@isTest
public class TST_UtilityClass {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    }
    
    
	public static Profile getProfileByName(String profileName) {
	  	Profile Result  = [Select Id from Profile where Name = :profileName];
	  	return Result;
	}
	
	public static User createTestUser(Profile pf) {
		return TST_UtilityClass.createTestUser(pf, 'testuser@test123456789.com');
  	}
  
  	public static User createTestUser(Profile pf, String userName) {
    	Blob blobKey = crypto.generateAesKey(192);
		String key = EncodingUtil.base64encode(blobKey);
    	User Result = new User();
        Result.FirstName = 'Test';
        Result.LastName = 'User';
        Result.Email = 'testuser@test123456789.com'; 
        Result.CompanyName = 'test.com';
        Result.Title = 'Test User';
        Result.Username = key+'_'+userName;
        Result.Alias = 'testuser';
        Result.CommunityNickname = key.substring(25)+'_Test User';
        Result.TimeZoneSidKey = 'Europe/Amsterdam';
        Result.LocaleSidKey = 'nl_NL';
        Result.EmailEncodingKey = 'ISO-8859-1';
        Result.ProfileId = pf.Id;
		Result.LanguageLocaleKey = 'nl_NL';
     	return Result;
  	}
    
    public static Account_Reference__c createTestAccountReference( Account acc )
    {
    	Account_Reference__c Result = new Account_Reference__c(
    		C_Account_Name__c = acc.Id,
    		C_ExternalId__c	= 'EL1234567',
    		C_External_Person_Key__c = 'EL1234567',
    		C_Reference_Type__c = Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ENERGY
    	);
    	return Result;
    }
    
    public static Case createTestCase( Account_Reference__c accRef,User usr)
    {
    	Id userId = UserInfo.getUserId();
    	if( usr != null && !String.isEmpty(usr.Id)) userId = usr.Id;
    	Blob blobKey = crypto.generateAesKey(192);
		String key = EncodingUtil.base64encode(blobKey); 
    	Case Result = new Case(
    		AccountId = accRef.C_Account_Name__c,
    		C_Account_Reference__c	= accRef.Id,
    		Status = Constants.CASE_STATUS_WORKING,
	 		Origin = Constants.CASE_ORIGIN_EMAIL,
	 		OwnerId = userId,
	 		C_Service__c = 'Corporate Clients',
			C_Question__c = 'Corporate Clients',
			C_Concern__c = 'General Inquiry',
			T_Case_Number__c = String.valueOf(system.now())+''+key
    	);
    	system.debug(LoggingLevel.Error,'Case:'+Result);
    	return Result;
    }
    
    public static Account createTestAccount(String accName,String phone, Account parentAcc) {
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Account').getRecordTypeId();       
        Account Result = new Account(
        	RecordTypeID = recordTypeId ,
        	Name = accName,
        	Phone = phone
		);
        if (parentAcc != null) Result.ParentId = parentAcc.Id;
        return Result;
    }
  	
  	
    public static ContentVersion createTestContentVersion( EmailMessage eml )
    {
   		ContentVersion Result = new ContentVersion( 
			title = 'Test title',
			VersionData = blob.valueof('New Bitmap Image.bmp'),
         	//EmailMessageId = eml.id
         	PathOnClient ='/Header_Picture1.jpg'
   
    	 
		);
    	return Result;
    }
    
  	public static BatchData__c createTestBatchDataFromCase( Case cs ){
  		 
  		BatchData__c Result = new BatchData__c(
  			T_CaseId__c = cs.Id,
  			Object_Id__c = cs.Id,
  			External_Id__c = cs.Id,
  			T_ExecutingTime__c = system.now(),
  			ObjectName__c = SchemaClass.getObjectName( Case.SObjectType)
  		
  		);
  		return Result;			
  	}
  	  	
  	public static BatchData__c createTestBatchDataFromEmailMessage( EmailMessage eml ){
  		 
  		BatchData__c Result = new BatchData__c(
  			T_CaseId__c = eml.ParentId,
  			Object_Id__c = eml.Id,
  			External_Id__c = eml.Id,
  			Parent_Id__c = eml.ParentId,
  			T_ExecutingTime__c = system.now(),
  			ObjectName__c = SchemaClass.getObjectName( EmailMessage.SObjectType),
  			Process__c = 'BAT_HNDL_CRM2_Integration'//BAT_HNDL_CRM2_Integration.ClassName 
  		
  		);
  		return Result;			
  	}
  	
  	public static BatchData__c createTestBatchDataFromAttachment( Attachment att, EmailMessage eml )
	{
  		 
  		BatchData__c Result = new BatchData__c(
  			T_CaseId__c = eml.ParentId,
  			Object_Id__c = att.Id,
  			External_Id__c = att.Id,
  			Parent_Id__c = eml.ParentId,
  			T_ExecutingTime__c = system.now(),
  			ObjectName__c = SchemaClass.getObjectName( Attachment.SObjectType)
  		);
  		return Result;			
  	}

  	public static Attachment createTestAttachemnt( Id parentId )
  	{
  		Attachment Result = new Attachment(  	
	    	Name = 'Unit Test Attachment',
	    	body = Blob.valueOf('Unit Test Attachment Body'),
	        parentId = parentId
  		);
        return Result;
  	}
  	
  	
  	
  	public static ContentDocumentLink createTestContentDocumentLink( Id contDocumentId, Id entityId )
  	{
  	 	ContentDocumentLink Result = new ContentDocumentLink(
	        ShareType = 'V',
	        LinkedEntityId = entityId, 
	        ContentDocumentId = contDocumentId,
	        Visibility = 'AllUsers'
  		);
  		return Result;
  	}
  	
  	
	public static Account createTestPersonAccount(String firstName, String lastName, String phone, String email) {  
		String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account Result = new Account(
          RecordTypeID = recordTypeId ,
          FirstName = firstName,
          LastName = lastName,
          PersonEmail = email,
          PersonMailingStreet='test@asUgo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonMobilePhone = phone,
          Phone = phone
		  
        ); 
    	return Result;     
	}
	
	public static EmailMessage testEmailMessage( Case cs, String subjectName )
	{
		EmailMessage Result = new EmailMessage(
			ParentId = cs.Id,
			Subject = subjectName,
			FromAddress = UserInfo.getUserEmail()
		);
		
		return Result;
	}
	

	
 /*   public static Contact createTestContact(String contactName, Account acco)
    {
    	Contact Result = new Contact();
        Result.LastName = contactName;
        Result.Email = 'myEmail@asUgo.com';
        Result.AccountId = acco.Id;
        
        return Result;
        
    }
    */
   /* public static Lead createTestLead(String firstName, String lastName, String email,String mobile)
    {
    	Lead Result = new Lead(
        	LastName = lastName,
        	FirstName = firstName,
        	Email = email,
        	MobilePhone = mobile,
        	Phone = mobile,
        	PostalCode = '1001'
        );
        return Result;        
    }
    */
    
    public static Map<Id,Account> getAccountsByIds(Set<String> setIds)
    {
    	Map<Id,Account> Result = new Map<Id,Account>([select Id,Name From Account where Id IN:setIds]);
    	
    	return Result;    
    }
    
 
    
    public class TestUtilityWrapperClass{
    	public Account testSupplier {get;set;}
    	public Account_Reference__c testAccountReference{get;set;}
	    public Account testClient   {get;set;}
	    public Account testBilling   {get;set;}
	    public Account testEndCustomer {get;set;}
	    public Account testPersonAccount {get;set;}
	    public Contact testContact{get;set;}
    	public List<Account> lsAccount {get;set;}
    	public Profile testProfil{get;set;}
    	public User testUser{get;set;}
    	public Lead testLead{get;set;}
    	public Case testCase{get;set;}
    	public BatchData__c testBatchData{get;set;}
    	public EmailMessage testEmailMessage{get;set;}
    	public Attachment testAttachment{get;set;}
    	public ContentVersion testContentVersion{get;set;}
    	public ContentDocumentLink testContentDocumentLink{get;set;}
	  //  public Campaign testCampaign{get;set;}
	  //  public CampaignMember testCampignMember{get;set;}
	    
	       
    	public TestUtilityWrapperClass()
    	{
    		this.lsAccount = new List<Account>();
    	}
    	
    	public void updateAccount(Map<Id,Account> mapData)
    	{
    		List<Account> Result = new List<Account>();
    		Account Acc ;
    		if( mapData != null & mapData.size() > 0)
    		{
    			for(Id sKey:  mapData.keySet())
	   	 		{
	   	 			Acc = mapData.get(sKey);
	   	 			
	   	 			Result.Add(acc);
	   	 		}
	   	 		update Result;
    		}	
    	}
    	
    	
    	
    	public void UserInit()
    	{
    		this.testProfil = TST_UtilityClass.getProfileByName('System Administrator');  	
    		this.testUser = TST_UtilityClass.createTestUser(this.testProfil);
	    	insert this.testUser;
    	}
    	
    	public void MainInit(Boolean initUser)
    	{ 
    		lsAccount.Clear();
    		if( initUser == true ) UserInit();
	    	
	    	
	        this.testSupplier = TST_UtilityClass.createTestAccount('Account 1','0474123456',null); 
	    	this.testClient   = TST_UtilityClass.createTestAccount('Account 2','0474123457',null);
	    	this.testBilling  = TST_UtilityClass.createTestAccount('Account 3','0474123458',null);
	    	this.testEndCustomer = TST_UtilityClass.createTestAccount('End Customer 1','0474123459',null);
	    	this.testPersonAccount = TST_UtilityClass.createTestPersonAccount('Person Account','1','0474123452','personaccount.1@lampiris.fr');
	    	this.lsAccount.add(this.testEndCustomer);
	    	this.lsAccount.add(this.testSupplier);
	    	this.lsAccount.add(this.testClient);
	    	this.lsAccount.add(this.testBilling);
	    	this.lsAccount.add(this.testPersonAccount);
	    	system.debug(LoggingLevel.Error,'Accounts: '+lsAccount);
	   	 	insert this.lsAccount;	        	
    	}
    	
    	public void AccountReferenceInit()
    	{
    		this.testAccountReference = TST_UtilityClass.createTestAccountReference(this.testPersonAccount);
    		insert this.testAccountReference;
        
    	}
    	
    	public void CaseInit()
    	{
    		this.testCase = TST_UtilityClass.createTestCase( this.testAccountReference, this.testUser );
	    	Database.upsert( this.testCase, Case.Fields.T_Case_Number__c);
        
    	}
    	
    	public void EmailMessageInit()
    	{
    		this.testEmailMessage = TST_UtilityClass.testEmailMessage( this.testCase,' Test Email' );
    		insert this.testEmailMessage;
    	}
    	
    	public void AttachmentInit()
    	{
    		this.testAttachment = TST_UtilityClass.createTestAttachemnt( this.testEmailMessage.Id );
    		insert this.testAttachment;
    	}
    	
    	public void BatchDataInit()
    	{
    		this.testBatchData = createTestBatchDataFromCase( this.testCase );
    		insert this.testBatchData;
    	}
    	
    	public void CRM2_IntegrationCredInit() 
    	{
    		Integration_Credential__c IntegrationCred = new Integration_Credential__c( 
    			Name = Constants.CS_CRM2_EMAIL_INTEGRATION,
    			ApplicationName__c = Constants.CRM2_INTEGRATION_TEST_APPLICATION_NAME,
				ApplicationUser__c = Constants.CRM2_INTEGRATION_TEST_APPLICATION_USER,
				EndPoint__c = Constants.CRM2_INTEGRATION_TEST_ENDPOINT,
				Password__c = Constants.CRM2_INTEGRATION_TEST_PASSWORD,
				UserName__c = Constants.CRM2_INTEGRATION_TEST_USER_NAME
			);  
   			insert IntegrationCred;
    	}

		/* 08.01.2018 - Mohamed */
		public void CPAS_EmailAddressInit()
		{
			CPAS_EmailAddress__c cpasEmailAddress = new CPAS_EmailAddress__c(
					Name = 'tst@tst.com',
					Email_Address__c='tst@tst.com'
			);
			insert cpasEmailAddress;
		}
		
    	
    	public void ContentDocumentInit()
    	{
    		this.testContentVersion = TST_UtilityClass.createTestContentVersion( this.testEmailMessage );			
			insert this.testContentVersion;
			
			
			this.testContentVersion = [SELECT id, title, VersionData, PathOnClient,ContentDocumentId 
				FROM ContentVersion where Id = :this.testContentVersion.Id];
				
			this.testContentDocumentLink = TST_UtilityClass.createTestContentDocumentLink( this.testContentVersion.ContentDocumentId, this.testEmailMessage.Id );
			
        	insert this.testContentDocumentLink;
			
			
    		
    	}
    	
    /*	public void ContactInit()
	    {
	    	this.testContact = TST_UtilityClass.createTestContact(':)', this.testClient);
	        	        
	        insert this.testContact;
	        
	    } */  	
    }
    
    
}