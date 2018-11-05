@isTest
private class ResumeRetrievingScheduledTest {

     @isTest static void test_executeCorrectly(){
         //Given
         insert getCredentials();
         
         String CRON_EXP = '0 0 0 15 3 ? 2022';
         Test.setMock(HttpCalloutMock.class, new ResumeCalloutStandardMock());
        
        //When
        Test.startTest();
        ResumeRetrievingScheduled scheduledJob = new ResumeRetrievingScheduled();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, scheduledJob);    
        Test.stopTest();

        //Then
        List<AsyncApexJob> jobsScheduled = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('ResumeRetrievingScheduled', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        List<AsyncApexJob> jobsApexBatch = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('ResumeRetrievingBatch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
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

    
    
    










     private static Map<Integer,String> getBodyMap(Integer pageSize, 
                                                  Integer pageNumber, 
                                                  String zipCode, 
                                                  String city, 
                                                  String state, 
                                                  List<String> jobAdvIds){
        Map<Integer,String> resumeDtoJsonMap = new Map<Integer,String>();
        for(Integer i=0; i<pageNumber;i++){
            List<ResumeDTO> resumes = 
            TestDataFactory.getResumesDto(i*pageSize, pageSize, zipCode, city, state, jobAdvIds, null);
            resumeDtoJsonMap.put(i+1,Json.serialize(resumes));
        }
        return resumeDtoJsonMap;
    }

     private class ResumeCalloutServiceMock implements IcalloutService{
        public Map<String,Object> testDataSet;

        public ResumeCalloutServiceMock(){
            testDataSet = new Map<String,Object>();
        }

        public HttpResponse getRecords(Map<String,String> params){
            if(testDataSet.containsKey('getRecordsExc')){
                throw (Exception) testDataSet.get('getRecordsExc');
            }
            Map<Integer,String> bodyMap = (Map<Integer,String>)testDataSet.get('bodyForGetRecords');
            String body = bodyMap.get(Integer.valueOf(params.get('pageNumber')));
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }

        public HttpResponse getRecordNumber(Map<String,String> params){
            if(testDataSet.containsKey('getRecordNumberExc')){
                throw (Exception) testDataSet.get('getRecordNumberExc');
            }
            String recordNum = String.valueOf(testDataSet.get('recordNumber'));
            HttpResponse response = new HttpResponse();
            response.setBody(recordNum);
            response.setStatusCode(200);
            return response;
        }
    }

}
