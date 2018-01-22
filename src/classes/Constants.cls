/*
    @Author: Juraj Ciljak
    @CreateDate: 10.10.2017
    @LastModify: 
    @Description: Class for store Constants
    @Version: 1.0.1
*/
public without sharing class Constants {

	/* Custom Settings */
	public static final String  CS_CRM2_EMAIL_INTEGRATION = 'CRM2 Email Integration';
	public static final String  CS_CRM2_DOCUMENT_INTEGRATION = 'CRM2 Document Integration';
	  
	
	
	/* CRM2 EMAIL Constatnts TICKE TYPE,... */
	public static final String CRM2_EMAIL_TICKET_TYPE_TT = 'TT';
 	public static final String CRM2_EMAIL_TICKET_TYPE_INFO = 'INFO';
 	public static final String CRM2_EMAIL_OPERATION_CREATE = 'Create';
 	
 	/* Case Status */
 	public static final String CASE_STATUS_ESCALATED = 'Escalated';
  	public static final String CASE_STATUS_RE_OPENED = 'Re-Opened';
 	public static final String CASE_STATUS_WORKING = 'Working';
 	public static final String CASE_STATUS_ON_HOLD_CUSTOMER = 'On Hold - Awaiting Customer';
 	public static final String CASE_STATUS_ON_HOLD_SUPPORT = 'On Hold - Awaiting Support';
 	public static final String CASE_STATUS_CLOSED = 'Closed';
 	 
 	public static final String CASE_ORIGIN_EMAIL = 'Email';
 	
 	/* Account Reference */
 	public static final String ACCOUNT_REFERENCE_REFERENCE_TYPE_ENERGY = 'Energy';
 	public static final String ACCOUNT_REFERENCE_REFERENCE_TYPE_ISOL = 'ISOL';
 	
 	
 	public static final Integer HTTP_STATUS_CODE_METHOD_NOT_ALLOWED = 405;
 	public static final Integer HTTP_STATUS_CODE_OK = 200;
 	public static final Integer HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR = 500; 
 	public static final Integer HTTP_STATUS_CODE_NO_CONTENT = 204;
 	public static final String  HTTP_FUNCTION_ERROR = 'Internal Server Error';
 	
 	public static final String EL1_MISSING_ARGUMENT = 'MISSING_ARGUMENT';
 	public static final String EL1_FIELD_NOT_SPECIFIED = 'not specified';
 	public static final String EL1_SAVING_ERROR = 'Saving Error';
 	public static final String EL1_DML_ERROR = 'DML_ERROR';
 	public static final String EL1_INTERNAL_SERVER_ERROR = 'INTERNAL_SERRVER_ERROR';
 	
 	public static final String HTTP_EL1_METHOD_NOT_ALLOWED = 'This function is not available yet!!!';
 		
 	
 	public static string CRM2_INTEGRATION_TEST_APPLICATION_NAME = 'SFDCtoCRM2';
	public static string CRM2_INTEGRATION_TEST_APPLICATION_USER = 'SFDCtoCRM2';
	
	/* USING ONLY FOR TESTING */ 
	public static string CRM2_INTEGRATION_TEST_ENDPOINT = 'https://bae-silver-api.lampiris.be/v1/case';
	public static string CRM2_INTEGRATION_TEST_PASSWORD = 'ohtooTachii4iyae';
 	public static string CRM2_INTEGRATION_TEST_USER_NAME = 'devuser';
 	
 	public static Integer MAX_LENGHT_OF_TEXTAREA_FIELD = 95000; 
 	
 	public static String STRING_CRLF = '\r\n';
}