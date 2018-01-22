/*
    @Author: Juraj Ciljak
    @CreateDate: 17.10.2017
    @LastModify: 
    @Description:   Registration Hendler class for OpenId Connect with Keycloak
                    Task: https://jira.lampiris.be/browse/SFBECASE-5
    @Version: 1.0.1
*/

global class AutocreatedRegHandlerKeycloak implements Auth.RegistrationHandler {
    
    class RegHandlerException extends Exception {}
    public static final String MSG_ERRRO_NO_ACCESS = 'You do not have access!!!. Please contact your administrator.';
    public static final String MSG_ERROR_MULPTIPLE_USERS = 'Multiple users with this email address:';

    global boolean canCreateUser(Auth.UserData data) {
        //TODO: Check whether we want to allow login of a user with this data
        if( !String.isEmpty(data.email) )
        {
            return true;
        } else return false;
    }
    
    
    global User createUser(Id portalId, Auth.UserData data){
        system.debug(LoggingLevel.Error,'AutocreatedRegHandlerKeycloak -> createUser:'+data);
        User u;
        if( canCreateUser(data)) {
            //Returning null or throwing an exception fails the SSO flow
            //return null;
            List<User> lsUsers = [ Select Id From  User Where email =:data.email];
            if( lsUsers.size() == 1)
            {
                u = lsUsers.get(0);              
                return u;
            } else if( lsUsers.size() > 1) 
            {
                throw new RegHandlerException(MSG_ERROR_MULPTIPLE_USERS +data.email+'!!!. Please contact your administrator.');
                return null;
            } else if( lsUsers.size() == 0)
            {
                throw new RegHandlerException( MSG_ERRRO_NO_ACCESS );
                return null;
            }           
            
        } else
        {
            throw new RegHandlerException( MSG_ERRRO_NO_ACCESS  );
            return null;
        }
        return null;
       
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User u = new User(id=userId);
        system.debug(LoggingLevel.Error,'AutocreatedRegHandlerKeycloak -> Update:'+data);
        // No flow for update 
    }
    
    global User createSFDCUser(Auth.UserData data)
    {
         //The user is authorized, so create Salesforce user
        // This is not yet implemented in Sprint 1
        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        //TODO: Customize the username. Also check that the username doesn't already exist and
        //possibly ensure there are enough org licenses to create a user. Must be 80 characters
        //or less.
        u.username = data.username ;
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.username;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        return u;
    }
}