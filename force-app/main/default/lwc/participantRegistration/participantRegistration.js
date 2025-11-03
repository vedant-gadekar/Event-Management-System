import { LightningElement, wire, track } from 'lwc';
import createParticipant from '@salesforce/apex/ParticipantController.createParticipant';
import createRegistration from '@salesforce/apex/RegistrationController.createRegistration';
import getAllRegistrations from '@salesforce/apex/RegistrationController.getAllRegistrations';
import deleteRegistration from '@salesforce/apex/RegistrationController.deleteRegistration';
import getAllEvents from '@salesforce/apex/EventController.getAllEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ParticipantRegistration extends LightningElement {
    participantName = '';
    participantEmail = '';
    selectedEvent = '';
    teamMembersCount = 1;
    eventOptions = [];
    registrations = [];
    wiredRegistrations;

    columns = [
        { label: 'Team Name', fieldName: 'Name', type: 'text' },
        { label: 'Event', fieldName: 'EventName', type: 'text' },
        { label: 'Participant', fieldName: 'ParticipantName', type: 'text' },
        { label: 'Email', fieldName: 'ParticipantEmail', type: 'email' },
        { label: 'Team Members', fieldName: 'Team_Members_Count__c', type: 'number' },
        {
            type: 'button',
            typeAttributes: { label: 'Delete', name: 'delete', variant: 'destructive' }
        }
    ];


    @wire(getAllEvents)
    wiredGetEvents({ data, error }) {
        if (data) {
            this.eventOptions = data.map(evt => ({
                label: evt.Name,
                value: evt.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Error loading events', 'error');
        }
    }

    @wire(getAllRegistrations)
    wiredGetRegistrations(result) {
        this.wiredRegistrations = result;
        if (result.data) {
            this.registrations = result.data.map(reg => ({
                Id: reg.Id,
                Name: reg.Name,
                ParticipantName: reg.Participant__r?.Name,
                ParticipantEmail: reg.Participant__r?.Email__c,
                EventName: reg.Event__r?.Name,
                Team_Members_Count__c: reg.Participant__r?.Team_Members_Count__c
        }));


        } else if (result.error) {
            this.showToast('Error', 'Error loading registrations', 'error');
        }
    }

    handleParticipantChange(event) {
        this.participantName = event.target.value;
    }
    handleEmailChange(event) {
        this.participantEmail = event.target.value;
    }

    handleEventChange(event) {
        this.selectedEvent = event.detail.value;
    }
    handleTeamCountChange(event) {
        this.teamMembersCount = event.target.value;
    }

    async handleRegister() {
        if (!this.participantName || !this.selectedEvent) {
            this.showToast('Validation Error', 'Please enter participant name and select an event', 'warning');
            return;
        }

        try {
            const participantId = await createParticipant({ 
                participantName: this.participantName ,
                email:this.participantEmail,
                teamMemberCount: parseInt(this.teamMembersCount)
            });

            await createRegistration({
                registrationName: 'Pending Team Name...',
                participantId: participantId,
                eventId: this.selectedEvent
            });
            
            console.log('Participant being sent:', this.participantName,this.participantEmail);


            this.showToast('Success', 'Registered successfully!', 'success');
            this.participantName = '';
            this.participantEmail = '';
            this.selectedEvent = '';
            this.teamMembersCount = 1;


            setTimeout(async () => {
                await refreshApex(this.wiredRegistrations);
            }, 2000); // 5-second delay

        } catch (error) {
            console.error('Error registering participant:', error);
            this.showToast('Error', error.body?.message || 'Error during registration', 'error');
        }
    }


    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            try {
                await deleteRegistration({ registrationId: row.Id });
                this.showToast('Deleted', 'Registration deleted successfully!', 'success');
                await refreshApex(this.wiredRegistrations);
            } catch (error) {
                console.error('Error deleting registration:', error);
                this.showToast('Error', error.body?.message || 'Error deleting registration', 'error');
            }
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
