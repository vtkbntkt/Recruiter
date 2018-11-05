@isTest
private class ResumeCalloutServiceTest {
     @IsTest static void test_getRecords(){ 
        //Given
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('resumes_body');
        mock.setStatusCode(HttpConstants.STATUS_CODE_OK);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Map<String,String> params = new Map<String,String>();
        params.put('createdDate','2018-10-31');
        
        // When
        Test.startTest();
        HttpResponse response = new ResumeCalloutService(new WebTokenMock()).getRecords(params);       
        Test.stopTest();
        
        //Then   
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'resumes_body' LIMIT 1];     
        System.assertEquals(sr.Body.toString(), response.getBody());        
    }

    @IsTest static void test_getRecordNumber(){ 
        //Given
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('resume_number_body');
        mock.setStatusCode(HttpConstants.STATUS_CODE_OK);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Map<String,String> params = new Map<String,String>();
        params.put('createdDate','2018-10-31');
        
        // When
        Test.startTest();
        HttpResponse response = new ResumeCalloutService(new WebTokenMock()).getRecordNumber(params);       
        Test.stopTest();
        
        //Then   
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'resume_number_body' LIMIT 1];     
        System.assertEquals(sr.Body.toString(), response.getBody());        
    }

     private class WebTokenMock implements IwebToken{

         public WebToken getToken(){
             WebToken token = new WebToken();
             token.access_token = 'value';
             token.id = 'value';
             token.instance_url ='value';
             token.issued_at = 'value';
             token.signature = 'value';
             token.token_type = 'value';
             return token;
         }
     }
}
