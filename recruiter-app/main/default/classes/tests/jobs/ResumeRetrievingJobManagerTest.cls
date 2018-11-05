@isTest
private class ResumeRetrievingJobManagerTest {
    
    @isTest static void test_getPageNumbersCorrectly(){
        //Given
        Integer pageSize = 10;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setBody(String.valueOf(pageSize));
        resumeCallout.response.setStatusCode(200);
        IjobAppservice jobAppService = new JobAppServiceMock();
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        List<Integer> pageNumbers = manager.getPageNumbers('2018-10-31');

        //Then
        System.assertEquals(pageSize, pageNumbers.size());
    }

     @isTest static void test_getPageNumbersInvalidStatusCode(){
        //Given
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setStatusCode(201);
        IjobAppservice jobAppService = new JobAppServiceMock();
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        try{
            List<Integer> pageNumbers = manager.getPageNumbers('2018-10-31');
            System.assert(false,'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf ResumeRetrievingJobManager.ResumeRetrievingJobManagerException);
        }
    }

    @isTest static void test_getPageNumbersInvalidBody(){
        //Given
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setBody(String.valueOf('pageSize'));
        resumeCallout.response.setStatusCode(200);
        IjobAppservice jobAppService = new JobAppServiceMock();
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        try{
            List<Integer> pageNumbers = manager.getPageNumbers('2018-10-31');
            System.assert(false,'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf ResumeRetrievingJobManager.ResumeRetrievingJobManagerException);
        }
    }

    @isTest static void test_runRetrievingCorrectly(){
        //Given
        Integer pageSize = 10;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setBody('[{}]');
        resumeCallout.response.setStatusCode(200);
        IjobAppservice jobAppService = new JobAppServiceMock();
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        try{
            manager.runRetrieving('2018-10-31','1');
            //Then
            System.assert(true);
        }
        catch(Exception exc){
            System.assert(false,'unexpected exception');

        }
    }

    @isTest static void test_runRetrievingInvalidBody(){
        //Given
        Integer pageSize = 10;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setBody('');
        resumeCallout.response.setStatusCode(200);
        IjobAppservice jobAppService = new JobAppServiceMock();
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        try{
            manager.runRetrieving('2018-10-31','1');
            System.assert(false,'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf ResumeRetrievingJobManager.ResumeRetrievingJobManagerException);
        }
    }

     @isTest static void test_runRetrievingInvalidStatusCode(){
        //Given
        Integer pageSize = 10;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setBody('[{}]');
        resumeCallout.response.setStatusCode(201);
        IjobAppservice jobAppService = new JobAppServiceMock();
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        try{
            manager.runRetrieving('2018-10-31','1');
            System.assert(false,'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf ResumeRetrievingJobManager.ResumeRetrievingJobManagerException);
        }
    }

     @isTest static void test_runRetrieving_ResumeServiceError(){
        //Given
        Integer pageSize = 10;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.response.setBody('[{}]');
        resumeCallout.response.setStatusCode(200);
        JobAppServiceMock jobAppService = new JobAppServiceMock();
        jobAppService.testDataSet.put('exc', new JobAppServiceException());
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, jobAppService);

        //When
        try{
            manager.runRetrieving('2018-10-31','1');
            System.assert(false,'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf ResumeRetrievingJobManager.ResumeRetrievingJobManagerException);
        }
    }

    private class ResumeCalloutServiceMock implements IcalloutService{
        public HttpResponse response;

        public ResumeCalloutServiceMock(){
            response = new HttpResponse();
        }

        public HttpResponse getRecords(Map<String,String> params){
            return response;
        }

        public HttpResponse getRecordNumber(Map<String,String> params){
            return response;
        }
    }

    private class JobAppServiceMock implements IjobAppService{
        public Map<String,Object> testDataSet;

        public  JobAppServiceMock(){
            testDataSet = new Map<String,Object>();
        }
        public void updateJobAppByExternalResumeDTO(List<ResumeDTO> resumeDtoList){
            if(testDataSet.containsKey('exc')){
                throw (Exception)testDataSet.get('exc');
            }

        }
    }
}
