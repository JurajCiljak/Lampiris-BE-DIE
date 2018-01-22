/*
    @Author: Juraj Ciljak
    @CreateDate: 10.10.2017
    @LastModify: 
    @Description: Class for store CustomSettings
    @Version: 1.0.1
*/
public with sharing class CustomSettings {
 
  
	public static Integration_Credential__c getIntegrationCredential( String credName )
	{
		Integration_Credential__c Result ;
		Result = Integration_Credential__c.getValues( credName );
		//if ( Result == null ) Result = new Integration_Credential__c();
		return Result;
			 
	}
	 
	public static iPortal_MimeType__c get_iPortal_MimeType( String name )
	{
		iPortal_MimeType__c Result ;
		Result = iPortal_MimeType__c.getValues( name );
		//if ( Result == null ) Result = new Integration_Credential__c();
		return Result;
			
	}
	
	
	public static Map<String,CRM2_Concern_Id__c> getCRM2_ConcernId()
	{
		Map<String,CRM2_Concern_Id__c> Result = new Map<String,CRM2_Concern_Id__c>();	
		String key = '';
		for ( CRM2_Concern_Id__c conId: CRM2_Concern_Id__c.getall().values())
		{
			key = getCRM2_ConcernKey( conId.LMP_Service__c, conId.LMP_Question__c , conId.LMP_Concern__c);
			Result.Put( key ,conId);	
		}
		return Result;
	}
	
	public static String getCRM2_ConcernKey( String lmp_Service, String lmp_Question, String lmp_Concern)
	{
		String Result = '';
		if( lmp_Service != null ) Result = lmp_Service;
		if( lmp_Question != null ) Result += '-' + lmp_Question;
		if( lmp_Concern != null ) Result +=  '-' + lmp_Concern;
		return Result.trim().toLowerCase().unescapeCsv();
			
	}

	public static CPAS_EmailAddress__c getCpasEmailAddress( String name )
	{
		CPAS_EmailAddress__c Result ;
		Result = CPAS_EmailAddress__c.getValues( name );
		return Result;

	}

	   
}