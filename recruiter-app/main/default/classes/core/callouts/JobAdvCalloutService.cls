public class JobAdvCalloutService { 
    private static final String ORG_TARGET = 'services/apexrest/JobAdv';
    
    public static HttpResponse getRecords(){
        HttpRequest request = prepareRequest(HttpConstants.METHOD_GET, null); 
        HttpResponse response = new Http().send(request);
        return response;
    }
    
    public static HttpResponse manipulateRecords(String recordsJson, String method){      
        HttpRequest request = prepareRequest(method, recordsJson); 
        HttpResponse response = new Http().send(request);
        return response;       
    }
    
    private static HttpRequest prepareRequest(String method, String body){
        WebToken token = getToken();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(token.instance_url+'/'+ORG_TARGET);
        request.setMethod(method);
        request.setHeader('Authorization', token.token_type+' '+ token.access_token);
        request.setHeader('Content-Type', 'application/json');
        if (body!=null){
            request.setBody(body);
        } 
        return request;
    }
    
    public static WebToken getToken(){
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
        WebToken token = new Webtoken();       
        try{
            token = (WebToken) JSON.deserialize(response.getBody(), WebToken.class);
        }
        catch(JsonException exc){
            throw new JobAdvCalloutServiceException(exc.getMessage(),exc);
        }      
        return token;       
    }
    public class JobAdvCalloutServiceException extends Exception{}
}