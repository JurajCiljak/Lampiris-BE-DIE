/*
    @Author: Juraj Ciljak
    @CreateDate: 06.10.2017
    @LastModify: 
    @Description: AuthCallout class
                  Task: SFDCFR-11 -> https: https://jira.lampiris.be/browse/SFDCBE-11
    @Version: 1.0.1
*/
public class AuthCallout {
    
    /* Property */
    
    public static String ClassName{
        get{
            return AuthCallout.class.getName();
        }
    }
    
    /* Constructor */
    public AuthCallout(){}
       
    // Implementation
    
    
    /*
        method basicAuthCalloutWithJSON responsible for HTTP call out 
        @ endPoint_URL: Endpoint URL
        @ userName: User Name
        @ password: User password
        @ method: HTTP mothod (POST, GET, ...)
        @ jsonData: JSON Data -> Data Pushed trought REST API call in JSON format
        @ lsJSON_Resp: -> Response trought REST API 
        @ sysLog: Class for system log in case of some error
    
    */
    public Integer basicAuthCalloutWithJSON( String endPoint_URL, String userName, String password, String method, String jsonData, 
        List<String> lsJSON_Resp, SystemLog sysLog)
    {
        
        Integer Result = Constants.HTTP_STATUS_CODE_OK;
        
        if( sysLog == null ) sysLog = new SystemLog(false, false, false, false);
        try
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint_URL);
            if( lsJSON_Resp == null ) lsJSON_Resp = new List<String>();
            // req.setCompressed(true);
            req.setMethod(method);
            req.setTimeout(120000); 
    
            // Specify the required user name and password to access the endpoint
            // As well as the header and header information
           
            Blob headerValue = Blob.valueOf(userName + ':' + password); 
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            
            system.debug(LoggingLevel.Error,'userName:'+userName);
            system.debug(LoggingLevel.Error,'password:'+password);
            system.debug(LoggingLevel.Error,'jsonData:'+jsonData);
         
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
        
            req.setBody(jsonData );
               
            // Create a new http object to send the request object
            // A response object is generated as a result of the request  
       
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Result = res.getStatusCode();
            
            if( res.getStatusCode() != Constants.HTTP_STATUS_CODE_NO_CONTENT )
            {
                sysLog.addLogNoThrow( SystemLog.getSystemLog( AuthCallout.ClassName,'basicAuthCalloutWithJSON', String.valueOf(res), '?','?',62,ApexPages.severity.ERROR ) , null ,false );                                     
                sysLog.addLogNoThrow( SystemLog.getSystemLog( AuthCallout.ClassName,'basicAuthCalloutWithJSON', String.valueOf(res)+'['+jsonData+']', '?','?',62,ApexPages.severity.ERROR ) , null ,false );                         
                sysLog.addLogNoThrow( SystemLog.getSystemLog( AuthCallout.ClassName,'basicAuthCalloutWithJSON', String.valueOf(res.getBody()), '?','?',62,ApexPages.severity.ERROR ) , null ,false );                                   
            }
             
            lsJSON_Resp.Add( res.getBody() );
            
            
            return Result;
        }catch(Exception E)
        {
            sysLog.addLogNoThrow( SystemLog.getSystemLog( AuthCallout.ClassName,'basicAuthCalloutWithJSON', String.valueOf(e), '?','?',e.getLineNumber(),ApexPages.severity.ERROR ) , e ,false );                      
            return Constants.HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR;
        }
   }
}