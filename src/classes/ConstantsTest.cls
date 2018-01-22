/*
    @Author: Juraj Ciljak
    @CreateDate: 07.11.2017
    @LastModify: 
    @Description: Test Class for Constants                  
    @Version: 1.0.1
*/
@isTest
private class ConstantsTest {

    static testMethod void ConstantsTest() {
        // TO DO: implement unit test
        Test.startTest();
        String sValue =  Constants.CS_CRM2_EMAIL_INTEGRATION;
		sValue =  Constants.CS_CRM2_DOCUMENT_INTEGRATION;
		sValue =  Constants.CRM2_EMAIL_TICKET_TYPE_TT;
		sValue =  Constants.CRM2_EMAIL_TICKET_TYPE_INFO;
		sValue =  Constants.CRM2_EMAIL_OPERATION_CREATE;
		sValue =  Constants.CASE_STATUS_ESCALATED;
		sValue =  Constants.CASE_STATUS_RE_OPENED;
		sValue =  Constants.CASE_STATUS_WORKING;
		sValue =  Constants.CASE_STATUS_ON_HOLD_CUSTOMER;
		sValue =  Constants.CASE_STATUS_ON_HOLD_SUPPORT;
		sValue =  Constants.CASE_STATUS_CLOSED;
		sValue =  Constants.CASE_ORIGIN_EMAIL;
		sValue =  Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ENERGY;
		sValue =  Constants.ACCOUNT_REFERENCE_REFERENCE_TYPE_ISOL;
		Integer iValue =  Constants.HTTP_STATUS_CODE_METHOD_NOT_ALLOWED;
		iValue =  Constants.HTTP_STATUS_CODE_OK;
		iValue =  Constants.HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR; 
		iValue =  Constants.HTTP_STATUS_CODE_NO_CONTENT;
		sValue =  Constants.HTTP_FUNCTION_ERROR ;
		sValue =  Constants.EL1_MISSING_ARGUMENT;
		sValue =  Constants.EL1_FIELD_NOT_SPECIFIED;
		sValue =  Constants.EL1_SAVING_ERROR;
		sValue =  Constants.EL1_DML_ERROR;
		sValue =  Constants.EL1_INTERNAL_SERVER_ERROR;
		sValue =  Constants.HTTP_EL1_METHOD_NOT_ALLOWED;
 	
		sValue =  Constants.CRM2_INTEGRATION_TEST_APPLICATION_NAME;
		sValue =  Constants.CRM2_INTEGRATION_TEST_APPLICATION_USER ;
		sValue =  Constants.CRM2_INTEGRATION_TEST_ENDPOINT;
		sValue =  Constants.CRM2_INTEGRATION_TEST_PASSWORD;
		sValue =  Constants.CRM2_INTEGRATION_TEST_USER_NAME ;
        Test.stopTest();
        
    }
}