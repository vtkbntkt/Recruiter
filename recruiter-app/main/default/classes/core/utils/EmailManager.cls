public class EmailManager {
    public static Boolean sendMail(EmailAddress addresses, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
        mail.setToAddresses(addresses.to);
        mail.setCcAddresses(addresses.cc);
        mail.setCcAddresses(addresses.bcc);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { mail });       
        return inspectResults(results);
        
    }
    
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }       
        return sendResult;
    }
    
    public class EmailAddress {       
        public List<String> to {get;set;}
        public List<String> cc{get;set;}
        public List<String> bcc{get;set;}      
        public EmailAddress(){
            to = new List<String>();
            cc = new List<String>();
            bcc = new List<String>();
        }       
    }
}