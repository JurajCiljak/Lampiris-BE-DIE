/*
	* @Author: Juraj Ciljak
	* @Created: 25.07.2017
	* @Description: Test class for Schema Class
	* @LastModify: 
*/
@isTest
private class SchemaClassTest {

    static testMethod void SchemaClassTest() {
        Test.startTest();
        String sValue =  SchemaClass.getFields( String.valueof(Account.SObjectType), true);
        Boolean bValue = sValue.contains('LastModifiedById');
        system.assertEquals( true, bValue);
        
        sValue =  SchemaClass.getFields( String.valueof(Account.SObjectType), false);
        bValue = sValue.contains('LastModifiedById');
        system.assertNOTEquals( true, bValue);
        
        TST_UtilityClass.TestUtilityWrapperClass utilityTest = new TST_UtilityClass.TestUtilityWrapperClass();
        utilityTest.MainInit(true);
		
		system.assertEquals( SchemaClass.getObjectTypeFromId( utilityTest.testSupplier.Id ),
			SchemaClass.getObjectName( Account.SObjectType )
		);
        Test.StopTest();
            
    }
}