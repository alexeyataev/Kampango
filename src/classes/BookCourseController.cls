public with sharing class BookCourseController {

    private final ApexPages.StandardController controller;
	private final Booking__c booking;
    public BookCourseControllerModel model { get; set; }

    public BookCourseController(ApexPages.StandardController stdController) {
        
        controller = stdController;
        this.booking = (Booking__c)stdController.getRecord();
        //getSessions();

        model = new BookCourseControllerModel();
        
        if(isValidBooking())
        {
            model.Status = 'Accept';
        }
        else
        {
            model.Status = 'NotAvailable';
        }
    }

    public void next() {

        String newStatus = model.Statuses.get(0);

        for(integer i=0; i< model.Statuses.size()-1; i++)
        {
            if (model.Status == model.Statuses.get(i))
            {
                newStatus = model.Statuses.get(i+1);
                
                if(newStatus == 'DDConfirm' 
                    && !membershipDDScheduleValid()
                    && !courseDdScheduleValid())
                {
                    newStatus = model.Statuses.get(i+2);
                }
            }
        }

        model.Status = newStatus;
    }

    public void back() {

        String newStatus = model.Statuses.get(0);

        for(integer i=model.Statuses.size()-1; i > 0; i--)
        {
            if (model.Status == model.Statuses.get(i))
            {
                newStatus = model.Statuses.get(i-1);
                
                if(newStatus == 'DDConfirm' 
                    && !membershipDDScheduleValid()
                    && !courseDdScheduleValid())
                {
                    newStatus = model.Statuses.get(i-2);
                }
            }
        }

        model.Status = newStatus;
    }

    public void submitBooking()
    {
        booking.Status__c = 'Confirmed';
        controller.save();
        model.Status = 'Complete';
    }

    public void processCardPayment()
    {
        booking.Status__c = 'Confirmed';
        controller.save();
        model.Status = 'CardPayment';
    }

    public Boolean getDisplayNext()
    {
        Set<String> validProcessStatuses = new Set<String>(model.Statuses);
        Boolean displayNext = false;

        if(validProcessStatuses.contains(model.Status))
        {
            if(model.Status == model.Statuses.get(model.Statuses.size() - 1))
            {
                displayNext = false;
            }
            else
            {
                displayNext = true;
            }
        }

        return displayNext;
    }

    public Boolean getDisplayBack()
    {
        Set<String> validProcessStatuses = new Set<String>(model.Statuses);
        Boolean displayBack = false;

        if(validProcessStatuses.contains(model.Status))
        {
            if(model.Status == model.Statuses.get(0))
            {
                displayBack = false;
            }
            else
            {
                displayBack = true;
            }
        }

        return displayBack;
    }

    public DirectDebitModels.DdSchedule getMembershipDdSchedule()
    {
        if(membershipDDScheduleValid())
        {   
            Integer paymentDate = getPaymentDateFromString(booking.Preferred_Payment_Date__c);   
            return DirectDebitUtilities.calculateDdSchedule(getMembershipFee(), getMembershipPaymentMonths(), paymentDate);
        }

        return new DirectDebitModels.DdSchedule();
    }

    public DirectDebitModels.DdSchedule getCourseDdSchedule()
    {
        if(courseDdScheduleValid())
        {   
            Integer paymentDate = getPaymentDateFromString(booking.Preferred_Payment_Date__c);         
            return DirectDebitUtilities.calculateDdSchedule(booking.Course__r.Fee__c, getCourseSchedulePaymentMonths(booking.Course_Payment_Method__c), paymentDate);
        }

        return new DirectDebitModels.DdSchedule();
    }

    public Boolean getHasMembershipDDSchedule()
    {
        return membershipDDScheduleValid();
    }

    public Boolean getHasCourseDdSchedule()
    {
        return courseDdScheduleValid();
    }

    public Boolean getHasCardPayment(){
        return !getMembershipPaymentOptionIsDD() || !getCoursePaymentOptionIsDD();
    }

    public String getCardPaymentTotal()
    {
        Decimal cardPaymentTotal = 0.00;

        if(!membershipDDScheduleValid())
        {  
            cardPaymentTotal += getMembershipFee();
        }

        if(!courseDdScheduleValid())
        {
            cardPaymentTotal += booking.Course__r.Fee__c;
        }

        return '£' + String.valueOf(cardPaymentTotal.setScale(2));
    }

    public Boolean getCoursePaymentOptionIsDd()
    {
        if(booking.Course_Payment_Method__c !=  null
            && booking.Course_Payment_Method__c.contains('Direct Debit'))        
        {
            return true;
        }

        return false;
    }

    public Boolean getMembershipPaymentOptionIsDd()
    {
        if(booking.Membership_Payment_Method__c != null
            && booking.Membership_Payment_Method__c.contains('Direct Debit'))
        {
            return true;
        }

        return false;
    }

    public Decimal getMembershipFee()
    {
        Decimal membershipFeeToPay;

        if(booking.Membership_Choice__c != null && booking.Membership_Choice__c.contains('18-month'))
        {
            membershipFeeToPay = model.eighteenMonthMembershipFee;
        }
        else
        {
            membershipFeeToPay = model.oneYearMembershipFee;
        }
        
        return membershipFeeToPay.setScale(2);
    }

    private Boolean isValidBooking()
    {
        if(booking.Status__c == 'Reserved')
        {
            return true;
        }

        return false;
    }

    private Integer getMembershipPaymentMonths()
    {
        Integer scheduleMonths;

        if(booking.Membership_Choice__c != null && booking.Membership_Choice__c.contains('18-month'))
        {
            scheduleMonths = model.eighteenMonthPayments;
        }
        else
        {
            scheduleMonths = model.oneYearPayments;
        }
        
        return scheduleMonths;
    }

    private Boolean membershipDdScheduleValid()
    {
        if(getMembershipPaymentOptionIsDD()
            && booking.Preferred_Payment_Date__c != null)
        {
            return true;
        }

        return false;
    }

    private Boolean courseDdScheduleValid()
    {
        system.debug(getCoursePaymentOptionIsDd());
        system.debug(booking.Preferred_Payment_Date__c);
        system.debug(booking.Course__r.Fee__c);
        if(getCoursePaymentOptionIsDd()
            && booking.Preferred_Payment_Date__c != null
            && booking.Course__r.Fee__c != null)
        {
            return true;
        }

        return false;
    }

    private static Integer getCourseSchedulePaymentMonths(String coursePaymentMethodPicklistValue)
    {
        Integer monthlyStringIndex = coursePaymentMethodPicklistValue.indexOf('monthly');

        Integer paymentCount = Integer.valueOf(coursePaymentMethodPicklistValue.substring(monthlyStringIndex - 2, monthlyStringIndex-1));

        return paymentCount;
    }

    private static Integer getPaymentDateFromString(String preferredPaymentDate)
    {
        String numberOnly = preferredPaymentDate.replaceAll('[^0-9]', '');
            return Integer.valueOf(numberOnly);
    }
}