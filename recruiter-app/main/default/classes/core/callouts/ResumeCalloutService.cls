public class ResumeCalloutService implements IcalloutService {
    private static final String ORG_TARGET = 'services/apexrest/Resume';
    private IwebToken webToken;

    public ResumeCalloutService(IwebToken webToken){
        this.webToken = webToken;
    }

    public HttpResponse getRecords(Map<String,String> params){
        HttpRequest request = new HttpRequest();
        String paramsString = prepareParamsAsString(params);
        WebToken token = webToken.getToken();
        request.setEndpoint(token.instance_url+'/'+ORG_TARGET+'?'+paramsString);
        request.setMethod(HttpConstants.METHOD_GET);
        request.setHeader('Authorization', token.token_type+' '+ token.access_token);
        request.setHeader('Content-Type', 'application/json'); 
        HttpResponse response = new Http().send(request);
        return response;
    }

    public HttpResponse getRecordNumber(Map<String,String> params){
         HttpRequest request = new HttpRequest();
        String paramsString = prepareParamsAsString(params);
        WebToken token = webToken.getToken();
        request.setEndpoint(token.instance_url+'/'+ORG_TARGET+'?'+paramsString);
        request.setMethod(HttpConstants.METHOD_GET);
        request.setHeader('Authorization', token.token_type+' '+ token.access_token);
        request.setHeader('Content-Type', 'application/json'); 
        HttpResponse response = new Http().send(request);
        return response;
    }

    private String prepareParamsAsString(Map<String,String> params){
        String paramsAsString = '';
        for(String key:params.keySet()){
            paramsAsString+=key+'='+params.get(key)+'&';
        }
        paramsAsString.removeEnd('&');
        return paramsAsString;
    }
}
