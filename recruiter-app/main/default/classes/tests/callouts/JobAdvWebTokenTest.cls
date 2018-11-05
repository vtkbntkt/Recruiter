@isTest
private class JobAdvWebTokenTest {
    
    
    @isTest static void test_getTokenCorrectly(){
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
        WebToken retrivedToken = new JobAdvWebToken().getToken();       
        Test.stopTest();
        
        //Then
        System.assert(retrivedToken.access_token == token.access_token&
                      retrivedToken.instance_url == token.instance_url&
                      retrivedToken.id == token.id&
                      retrivedToken.token_type == token.token_type&
                      retrivedToken.issued_at == token.issued_at&
                      retrivedToken.signature == token.signature);
    }
     @IsTest static void test_getToken_InvalidResponseBody(){
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
        WebToken retrivedToken = new JobAdvWebToken().getToken();       
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf WebTokenException);           
        }
        Test.stopTest();
    }

     @IsTest static void test_getToken_InvalidStatusCode(){
        //Given
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getTokenBody');
        mock.setStatusCode(HttpConstants.STATUS_CODE_INTERNAL_ERROR);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        insert getCredentials();
        
        Test.startTest();
        try{
            // When
        WebToken retrivedToken = new JobAdvWebToken().getToken();       
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf WebTokenException);           
        }
        Test.stopTest();
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
