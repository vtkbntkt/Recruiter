public class PostJobAdvertisementController {
    public Position__c position;
    private IjobAdvService jobAdvService;  
    
    public PostJobAdvertisementController(ApexPages.StandardController stdController) {
        position = [SELECT Job_Description__c, Education__c, id, Location__c, Salary_Range__c, Skills_Required__c, Name, 
                    Hiring_Manager__r.Name, Hiring_Manager__r.Phone, Hiring_Manager__r.Email, ExternalId__c, Status__c
                    FROM Position__c WHERE id=:stdController.getRecord().id];  
        jobAdvService = new JobAdvServiceImpl();
        
    }
       
    public PageReference postApplicationOnSite(){        
        try{        
            jobAdvService.postJobAdvWithPositionUpdate(position);   
        }
        catch(JobAdvServiceImpl.JobAdvServiceException exc){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage()));
            return null;
        }
        return new PageReference('/'+position.id);
    }
    
    public PageReference updateApplication(){
        try{
           
            jobAdvService.updateJobAdv(position);
        }
        catch(JobAdvServiceImpl.JobAdvServiceException exc){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage()));
            return null;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.UpdateAdvStatusSuccess));
        return null;
    }
    
    public PageReference removeApplicationFromSite(){
        try{
            jobAdvService.removeJobAdv(position);
        }
        catch(JobAdvServiceImpl.JobAdvServiceException exc){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage()));
            return null;
        }
        return new PageReference('/'+position.id);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}