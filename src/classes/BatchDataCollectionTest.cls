/*
    @Author: Juraj Ciljak
    @CreateDate: 01.11.2017
    @LastModify: 
    @Description: Test Class for BatchDataCollection
                  Task: --------
    @Version: 1.0.1
*/
@isTest
private class BatchDataCollectionTest {

    static testMethod void myBatchDataCollectionTest() {
        Test.startTest();
        TST_UtilityClass.TestUtilityWrapperClass UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.MainInit(true);
		UnitTest.AccountReferenceInit();
		UnitTest.CRM2_IntegrationCredInit(); 
		UnitTest.CaseInit();
		UnitTest.EmailMessageInit(); 
		UnitTest.ContentDocumentInit();
		SystemLog sysLog = new SystemLog( false,false,false,false);
		UnitTest.AttachmentInit();
		
		Map<String,Object> queryParameters = new Map<String,Object>();
		queryParameters.Put('startDate', system.now() - 10000 );
		queryParameters.Put('endDate', system.now() + 100 );
		
		BatchDataCollection bdc = new BatchDataCollection( sysLog,queryParameters );
		 
		String sValule = BatchDataCollection.ClassName;
        Test.stopTest();
        
    }
}