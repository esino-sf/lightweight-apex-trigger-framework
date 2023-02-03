/**
 * Description:
 *
 * Base class aiding in the implementation of a Domain Model around SObject collections
 *
 * Domain (software engineering). “a set of common requirements, terminology, and functionality
 * for any software program constructed to solve a problem in that field”,
 * http://en.wikipedia.org/wiki/Domain_(software_engineering)
 *
 * Domain Model, “An object model of the domain that incorporates both behavior and data.”,
 * “At its worst business logic can be very complex. Rules and logic describe many different "
 * "cases and slants of behavior, and it's this complexity that objects were designed to work with...”
 * Martin Fowler, EAA Patterns
 * http://martinfowler.com/eaaCatalog/domainModel.html
 *
 * Inspiration: Apex Enterprise Patterns
 * https://github.com/apex-enterprise-patterns/fflib-apex-common
 *
 **/
public virtual with sharing class SObjectDomain {

    /**
     * Provides access to the data represented by this domain class
     **/
    public List<SObject> records {
        get; private set;
    }

    /**
     * Provides access to Trigger.oldMap and allowing it to be mocked in unit-tests
     **/
    @TestVisible
    protected Map<Id, SObject> existingRecords {
        get {
            if (existingRecords == null) {
                existingRecords = Trigger.oldMap;
            }
            return existingRecords;
        }
        private set;
    }

    public Schema.DescribeSObjectResult sObjectDescribe {get; private set;}

    /**
     * Constructs the domain class with the data on which to apply the behaviour implemented within
     *
     * @param sObjectList A concrete list (e.g. List<Account> vs List<SObject>) of records
     **/
    public SObjectDomain(List<SObject> sObjectList) {
        this.records = sObjectList.clone();
        this.sObjectDescribe = sObjectList.getSObjectType().getDescribe();
    }

    /**
     * Override this to apply defaults to the records, this is called by the handleBeforeInsert method
     **/
    public virtual void onApplyDefaults() {}

    /**
     * Override this to apply validation to be performed during insert, called by the handleAfterInsert method
     **/
    public virtual void onValidate() {}

    /**
     * Override this to apply validation to be performed during update, called by the handleAfterUpdate method
     **/
    public virtual void onValidate(Map<Id,SObject> existingRecords)	{}

    /**
     * Override this to perform processing during the before insert phase, this is called by the handleBeforeInsert method
     **/
    public virtual void onBeforeInsert() {}

    /**
     * Override this to perform processing during the before update phase, this is called by the handleBeforeUpdate method
     **/
    public virtual void onBeforeUpdate(Map<Id,SObject> existingRecords) {}

    /**
     * Override this to perform processing during the before delete phase, this is called by the handleBeforeDelete method
     **/
    public virtual void onBeforeDelete() {}

    /**
     * Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
     **/
    public virtual void onAfterInsert() {}

    /**
     * Override this to perform processing during the after update phase, this is called by the handleAfterUpdate method
     **/
    public virtual void onAfterUpdate(Map<Id,SObject> existingRecords) {}

    /**
     * Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
     **/
    public virtual void onAfterDelete() {}

    /**
     * Override this to perform processing during the after undelete phase, this is called by the handleAfterDelete method
     **/
    public virtual void onAfterUndelete() {}

    /**
     * Base handler for the Apex Trigger event Before Insert, calls the onApplyDefaults method, followed by onBeforeInsert
     **/
    public virtual void handleBeforeInsert() {
        onApplyDefaults();
        onBeforeInsert();
    }

    /**
     * Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
     **/
    public virtual void handleBeforeUpdate(Map<Id,SObject> existingRecords) {
        onBeforeUpdate(existingRecords);
    }

    /**
     * Base handler for the Apex Trigger event Before Delete, calls the onBeforeDelete method
     **/
    public virtual void handleBeforeDelete() {
        onBeforeDelete();
    }

    /**
     * Base handler for the Apex Trigger event After Insert, checks object security and calls the onValidate and onAfterInsert methods
     *
     * @throws DomainException if the current user context is not able to create records
     **/
    public virtual void handleAfterInsert() {
        if(!sObjectDescribe.isCreateable()) {
            throw new DomainException('Permission to create an ' + sObjectDescribe.getName() + ' denied.');
        }
        onValidate();
        onAfterInsert();
    }

    /**
     * Base handler for the Apex Trigger event After Update, checks object security and calls the onValidate, onValidate(Map<Id,SObject>) and onAfterUpdate methods
     *
     * @throws DomainException if the current user context is not able to update records
     **/
    public virtual void handleAfterUpdate(Map<Id,SObject> existingRecords) {
        if(!sObjectDescribe.isUpdateable()) {
            throw new DomainException('Permission to update an ' + sObjectDescribe.getName() + ' denied.');
        }
        onValidate(existingRecords);
        onAfterUpdate(existingRecords);
    }

    /**
     * Base handler for the Apex Trigger event After Delete, checks object security and calls the onAfterDelete method
     *
     * @throws DomainException if the current user context is not able to delete records
     **/
    public virtual void handleAfterDelete() {
        if(!sObjectDescribe.isDeletable()) {
            throw new DomainException('Permission to delete an ' + sObjectDescribe.getName() + ' denied.');
        }
        onAfterDelete();
    }

    /**
     * Base handler for the Apex Trigger event After Undelete, checks object security and calls the onAfterUndelete method
     *
     * @throws DomainException if the current user context is not able to delete records
     **/
    public virtual void handleAfterUndelete() {
        if(!sObjectDescribe.isUndeletable()) {
            throw new DomainException('Permission to undelete an ' + sObjectDescribe.getName() + ' denied.');
        }
        onAfterUndelete();
    }

    /**
     * Interface used to aid the triggerHandler in constructing instances of Domain classes
     **/
    public interface IConstructable {
        SObjectDomain construct(List<SObject> sObjectList);
    }

    /**
     * Method constructs the given Domain class with the current Trigger context
     * before calling the applicable override methods such as beforeInsert, beforeUpdate etc.
     **/
    public static void triggerHandler(Type domainClass) {
        // Process the runtime Apex Trigger context
        triggerHandler(domainClass,
            Trigger.isBefore,
            Trigger.isAfter,
            Trigger.isInsert,
            Trigger.isUpdate,
            Trigger.isDelete,
            Trigger.isUnDelete,
            Trigger.new,
            Trigger.oldMap);
    }

    /**
     * Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
     **/
    private static void triggerHandler(Type domainClass,
                                        Boolean isBefore,
                                        Boolean isAfter,
                                        Boolean isInsert,
                                        Boolean isUpdate,
                                        Boolean isDelete,
                                        Boolean isUndelete,
                                        List<SObject> newRecords,
                                        Map<Id, SObject> oldRecordsMap) {
        SObjectDomain domainObject;

        // Construct the domain class constructor class
        String domainClassName = domainClass.getName();
        Type constructableClass = domainClassName.endsWith('Constructor') ? Type.forName(domainClassName) : Type.forName(domainClassName+'.Constructor');
        IConstructable domainConstructor = (IConstructable) constructableClass.newInstance();

        // Construct the domain class with the approprite record set
        if(isInsert) { domainObject = domainConstructor.construct(newRecords); }
        else if(isUpdate) { domainObject = domainConstructor.construct(newRecords); }
        else if(isDelete) { domainObject = domainConstructor.construct(oldRecordsMap.values()); }
        else if(isUndelete) { domainObject = domainConstructor.construct(newRecords); }

        // Invoke the applicable handler
        if(isBefore) {
            if(isInsert) { domainObject.handleBeforeInsert(); }
            else if(isUpdate) { domainObject.handleBeforeUpdate(oldRecordsMap); }
            else if(isDelete) { domainObject.handleBeforeDelete(); }
        }
        else {
            if(isInsert) { domainObject.handleAfterInsert(); }
            else if(isUpdate) { domainObject.handleAfterUpdate(oldRecordsMap); }
            else if(isDelete) { domainObject.handleAfterDelete(); }
            else if(isUndelete) { domainObject.handleAfterUndelete(); }
        }
    }

    /**
     * General exception class for the domain layer
     **/
    public class DomainException extends Exception {}
}