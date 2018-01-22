/*
    @Author: Juraj Ciljak
    @CreateDate: 09.07.2017
    @LastModify: 
    @Description:   Test Class for Registration Hendler class of OpenId Connect with Keycloak
                    Task:  
    @Version: 1.0.1
*/
@isTest
private class AutocreatedRegHandlerKeycloakTest {

    
    static testMethod void testCreateAndUpdateUser() {
        AutocreatedRegHandlerKeycloak handler = new AutocreatedRegHandlerKeycloak();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong@example.org', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US'});
        
        User u = handler.createSFDCUser( sampleData);
        User u1 = u;
        String errorMessage;
        boolean errTrue = false;
        Auth.UserData sampleData1 = sampleData ;
        System.assertEquals('testuserlong@example.org', u.userName);
        System.assertEquals('testuser@example.org', u.email);
        System.assertEquals('testLast', u.lastName);
        System.assertEquals('testFirst', u.firstName);
        System.assertEquals('testuser', u.alias);
        insert(u);
        String uid = u.id;
        
        handler.createUser(null, sampleData );
        
        sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
            'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{});
        
        handler.updateUser(uid, null, sampleData);
        
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
        try
        {
            handler.createUser(null, sampleData );
        }catch(Exception E)
        {
            errorMessage = e.getMessage(); 
        }
        if( errorMessage.contains( AutocreatedRegHandlerKeycloak.MSG_ERRRO_NO_ACCESS ))  errTrue = true;
        system.assertEquals(errTrue , true);        
        errTrue = false;
        
        u1.Id = null;
        u1.lastName = 'Test2';  
        u.userName = 'testuserlong2@example.org';     
        insert(u1);
        try
        {
            handler.createUser(null, sampleData1 );
        }catch(Exception E)
        {
            errorMessage = e.getMessage();
        }
        
        
        if( errorMessage.contains( AutocreatedRegHandlerKeycloak.MSG_ERROR_MULPTIPLE_USERS ))  errTrue = true;
        system.assertEquals(errTrue , true);        
        errTrue = false;
        
        sampleData1.email = '';
        try
        {
            handler.createUser(null, sampleData1 );
        }catch(Exception E)
        {
            errorMessage = e.getMessage();
        }
        if( errorMessage.contains( AutocreatedRegHandlerKeycloak.MSG_ERRRO_NO_ACCESS ))  errTrue = true;
        system.assertEquals(errTrue , true);        
        errTrue = false;
    }
}