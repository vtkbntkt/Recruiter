global class ResumeRetrievingScheduled implements Schedulable {

    global void execute(SchedulableContext ctx) {
        ResumeRetrievingJobManager resumeManager = new ResumeRetrievingJobManager(new ResumeCalloutService(new JobAdvWebToken()), 
                                                                                  new JobAppServiceImpl(new FileServiceImpl())); 
        String currentDate = Datetime.now().addDays(-1).format('yyyy-MM-dd');
        ResumeRetrievingBatch batch = new ResumeRetrievingBatch(resumeManager, currentDate);
        Id batchId = Database.executeBatch(batch,1);
    }
}
