global class ResumeCalloutStandardMock implements HttpCalloutMock {
     
     global HTTPResponse respond(HTTPRequest req) {
         HTTPResponse response = new HTTPResponse();
         response.setStatusCode(200);
         String endPoint = req.getEndpoint();
         System.debug('***Endpoint: '+endPoint);
         if(endPoint.contains('pageNumber')){
             response.setBody('[{}]');
         }
         else if(endPoint.contains('createdDate')){
             response.setBody('0');
         }
         else{
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'getTokenBody' LIMIT 1];
            response.setBody(sr.Body.toString());
         }
         return response;
     }
}





    
