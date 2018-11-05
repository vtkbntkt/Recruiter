public class JobAdvWebToken implements IwebToken {
    public static final Integer STATUS_CODE_OK = 200;

    public WebToken getToken(){
        JobAdvServiceCredentials__c settings = JobAdvServiceCredentials__c.getInstance();
        HttpRequest request = new HttpRequest();
        request.setMethod(HttpConstants.METHOD_POST);
        request.setEndpoint(settings.BaseUri__c);
        request.setBody('grant_type='+settings.Grant__c 
                        + '&client_id='+settings.ClientId__c 
                        + '&client_secret='+settings.ClientSecret__c 
                        + '&username='+settings.Username__c 
                        + '&password='+settings.Password__c + settings.SecurityToken__c); 
        HttpResponse response= new Http().send(request);
        if(response.getStatusCode()!=STATUS_CODE_OK){
            throw new WebTokenException(response.getBody());
        }       
        WebToken token = new Webtoken();       
        try{
            token = (WebToken) JSON.deserialize(response.getBody(), WebToken.class);
        }
        catch(JsonException exc){
            throw new WebTokenException(exc.getMessage(),exc);
        }      
        return token;       
    }
}
