global class ResumeRetrievingBatch implements Database.Batchable<Integer>,   Database.AllowsCallouts{
    private ResumeRetrievingJobManager resumeManager;
    private String createdDate;
    private List<String> errors;
    

    public ResumeRetrievingBatch(ResumeRetrievingJobManager resumeManager, String createdDate){
        this.resumeManager = resumeManager;
        this.createdDate = createdDate;
        errors = new List<String>();
    }

    global Iterable<Integer> start(Database.BatchableContext context) {
        List<Integer> pageNumbers = new List<Integer>();
        try{
            pageNumbers = resumeManager.getPageNumbers(createdDate);
        }
        catch(ResumeRetrievingJobManager.ResumeRetrievingJobManagerException exc){
             errors.add(exc.getMessage()+'\n'+'createdadte: '+createdDate+'\n'+'during start');
        }
        return pageNumbers;
    }
    
    global void execute(Database.BatchableContext context, List<Integer> scope){
        try{
            resumeManager.runRetrieving(createdDate,String.valueOf(scope.get(0)));
        }
        catch(ResumeRetrievingJobManager.ResumeRetrievingJobManagerException exc){
            errors.add(exc.getMessage()+'\n'+'createdadte: '+createdDate+'\n'+'page namber: '+scope.get(0));
        }
    }      
    

    global void finish(Database.BatchableContext context){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
        FROM AsyncApexJob WHERE Id = :context.getJobId()];
        String jobResultsMsg = job+String.join(errors, '\n');
        EmailManager.EmailAddress addresses = new EmailManager.EmailAddress();
        addresses.to.add('aleksej.gudkov@gmail.com');
        EmailManager.sendMail(addresses, 'Resume retrieving report', jobResultsMsg);     
    }
}



