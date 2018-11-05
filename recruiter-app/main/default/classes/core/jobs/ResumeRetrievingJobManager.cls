public class ResumeRetrievingJobManager {
    private IcalloutService resumeCallout;
    private IjobAppservice jobAppService;
    
    public ResumeRetrievingJobManager(IcalloutService resumeCallout, IjobAppservice jobAppService) {
        this.resumeCallout = resumeCallout;
        this.jobAppService = jobAppService;
    }

    public List<Integer> getPageNumbers(String createdDate){
        Map<String,String> params = new Map<String,String>();
        List<Integer> recordNumber = new List<Integer>();
        params.put('createdDate',createdDate);
        HttpResponse response = resumeCallout.getRecordNumber(params);
        if(response.getStatusCode()==200){
            String responseBody = response.getBody();
            try{
                Integer recordNumberInt = Integer.valueOf(responseBody);
                recordNumber = Utils.integer2integerList(1,recordNumberInt);
            }
            catch(TypeException exc){
                throw new ResumeRetrievingJobManagerException(exc.getMessage()+'\n Retrieved data:'+response.getBody(), exc);
            }
        }
        else{
            throw new ResumeRetrievingJobManagerException(response.getBody());
        }
        return recordNumber;
    }

    public void runRetrieving(String createdDate, String pageNumber){
        Map<String,String> params = new Map<String,String>();
        params.put('createdDate',createdDate);
        params.put('pageNumber',pageNumber);
        HttpResponse response = resumeCallout.getRecords(params);
        if(response.getStatusCode()==200){
            try{
                List<ResumeDTO> resumes = (List<ResumeDTO>)JSON.deserializeStrict(response.getBody(), List<ResumeDTO>.class);
                jobAppService.updateJobAppByExternalResumeDTO(resumes);
            }
            catch(JsonException exc){
                throw new ResumeRetrievingJobManagerException(exc.getMessage(), exc);
            } 
            catch(JobAppServiceException exc){
                throw new ResumeRetrievingJobManagerException(exc.getMessage(), exc);
            }   
        }
        else{
            throw new ResumeRetrievingJobManagerException(response.getBody());
        }     
    }
    public class ResumeRetrievingJobManagerException extends Exception{}
}
