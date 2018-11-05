@isTest
private class JobAdvCalloutServiceTest{
    
    @IsTest static void test_getToken(){
        //Given
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'getTokenBody' LIMIT 1];
        WebToken token = 
            (WebToken) JSON.deserialize(sr.Body.toString(), WebToken.class);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getTokenBody');
        mock.setStatusCode(HttpConstants.STATUS_CODE_OK);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        insert getCredentials();
        
        // When
        Test.startTest();
        WebToken retrivedToken = JobAdvCalloutService.getToken();       
        Test.stopTest();
        
        //Then
        System.assert(retrivedToken.access_token == token.access_token&
                      retrivedToken.instance_url == token.instance_url&
                      retrivedToken.id == token.id&
                      retrivedToken.token_type == token.token_type&
                      retrivedToken.issued_at == token.issued_at&
                      retrivedToken.signature == token.signature);
    }
    
    @IsTest static void test_getTokenException_InvalidResponse(){
        //Given
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getTokenBodyInvalid');
        mock.setStatusCode(HttpConstants.STATUS_CODE_OK);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        insert getCredentials();
        
        Test.startTest();
        try{
            // When
            WebToken retrivedToken = JobAdvCalloutService.getToken();
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvCalloutService.JobAdvCalloutServiceException);           
        }
        Test.stopTest();
    }
    
    
    
    @IsTest static void test_getRecords(){ 
        //Given
        JobAdvServiceCredentials__c credentials = getCredentials();
        insert credentials;
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'getRecordsBody' LIMIT 1];       
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(credentials.BaseUri__c, 'getTokenBody');
        multimock.setStaticResource('https://www.orga.com/services/apexrest/JobAdv', 'getRecordsBody');       
        multimock.setStatusCode(HttpConstants.STATUS_CODE_OK);
        multimock.setHeader('Content-Type', 'application/json');        
        Test.setMock(HttpCalloutMock.class, multimock);
        
        // When
        Test.startTest();
        HttpResponse response = JobAdvCalloutService.getRecords();       
        Test.stopTest();
        
        //Then        
        System.assertEquals(sr.Body.toString(), response.getBody());        
    }
    
    @IsTest static void test_manipulateRecords(){ 
        //Given
        JobAdvServiceCredentials__c credentials = getCredentials();
        insert credentials;
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'postRecordsBody' LIMIT 1];       
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(credentials.BaseUri__c, 'getTokenBody');
        multimock.setStaticResource('https://www.orga.com/services/apexrest/JobAdv', 'postRecordsBody');       
        multimock.setStatusCode(HttpConstants.STATUS_CODE_OK);
        multimock.setHeader('Content-Type', 'application/json');        
        Test.setMock(HttpCalloutMock.class, multimock);
        
        // When
        Test.startTest();
        HttpResponse response = JobAdvCalloutService.manipulateRecords(sr.Body.toString(),HttpConstants.METHOD_POST);       
        Test.stopTest();
        
        //Then        
        System.assertEquals(sr.Body.toString(), response.getBody()); 
        System.assertEquals(HttpConstants.STATUS_CODE_OK, response.getStatusCode()); 
    }
    
    private static JobAdvServiceCredentials__c getCredentials(){
        return new JobAdvServiceCredentials__c(
            Grant__c ='password', 
            ClientId__c = '12345',
            ClientSecret__c = '12345',
            Username__c ='user',
            securityToken__c='12345',
            Password__c ='123456',
            BaseUri__c='http://www.test.com');
    }
    
}