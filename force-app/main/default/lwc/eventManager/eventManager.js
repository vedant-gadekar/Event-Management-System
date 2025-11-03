import { LightningElement, wire } from 'lwc';
import createEvent from '@salesforce/apex/EventController.createEvent';
import getAllEvents from '@salesforce/apex/EventController.getAllEvents';
import deleteEvent from '@salesforce/apex/EventController.deleteEvent';
import getAllClubs from '@salesforce/apex/ClubController.getAllClubs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class EventManager extends LightningElement {
    eventName = '';
    maxParticipants = '';
    selectedClub = '';
    clubOptions = [];
    events = [];
    wiredEvents;

    columns = [
        { label: 'Event Name', fieldName: 'Name', type: 'text' },
        { label: 'Club', fieldName: 'ClubName', type: 'text' },
        { label: 'Registered Participants', fieldName: 'Registered_Participants', type: 'number' },
        { label: 'Max Participants', fieldName: 'MaxParticipants', type: 'number',cellAttribute: { alignment: 'left' } },
        {
            type: 'button',
            typeAttributes: { label: 'Delete', name: 'delete', variant: 'destructive' }
        }
    ];

    // Fetch all events
    @wire(getAllEvents)
    wiredGetEvents(result) {
        console.log('wiredGetEvents', result);
        this.wiredEvents = result;
        if (result.data) {
            this.events = result.data.map(evt => ({
                Id: evt.Id,
                Name: evt.Name,
                ClubName: evt.Club__r?.Name || 'Not Assigned',
                Registered_Participants: evt.Registered_Participants__c !== undefined ? evt.Registered_Participants__c : 0,
                MaxParticipants: evt.Max_Partcipants__c !== undefined ? evt.Max_Partcipants__c : 0
            }));
        } else if (result.error) {
            this.showToast('Error', 'Error loading events', 'error');
        }
    }

    // Fetch all clubs
    @wire(getAllClubs)
    wiredGetClubs({ data, error }) {
        if (data) {
            this.clubOptions = data.map(club => ({
                label: club.Name,
                value: club.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Error loading clubs', 'error');
        }
    }

    handleNameChange(event) {
        this.eventName = event.target.value;
    }

    handleMaxChange(event) {
        this.maxParticipants = event.target.value;
    }

    handleClubChange(event) {
        this.selectedClub = event.detail.value;
    }

    async handleAddEvent() {
        if (!this.eventName || !this.selectedClub || !this.maxParticipants) {
            this.showToast('Validation Error', 'Please fill all fields', 'warning');
            return;
        }

        try {
            await createEvent({
                eventName: this.eventName,
                clubId: this.selectedClub,
                maxParticipants: parseInt(this.maxParticipants, 10)
            });

            this.showToast('Success', 'Event added successfully!', 'success');
            this.eventName = '';
            this.maxParticipants = '';
            this.selectedClub = '';

            await refreshApex(this.wiredEvents);
        } catch (error) {
            console.error('Error creating event:', error);
            this.showToast('Error', error.body?.message || 'Error creating event', 'error');
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'delete') {
            this.deleteEventRecord(row.Id);
        }
    }

    async deleteEventRecord(eventId) {
        try {
            await deleteEvent({ eventId });
            this.showToast('Deleted', 'Event deleted successfully', 'success');
            await refreshApex(this.wiredEvents);
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Error deleting event', 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
