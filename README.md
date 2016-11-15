# CodePath Group Project - Pulse

Pulse is an app to help managers stay on top of the "pulse" of their team. Users can see a summary view of their teams "pulse" via happiness, engagement, and workload factors. Additional functionality allows users to maintain a schedule of their 1:1s, take notes and photos, access their app information using different devices, keep a history of their data, etc.

Time spent: **X** hours spent in total

## Wireframe

Here's a picture of the initial wireframe:

<img src='http://i.imgur.com/t0MgcN0.jpg' title='Pulse Wireframe' width='' alt='Pulse Wireframe' />
<img src='http://i.imgur.com/YlbxRIO.jpg' title='Pulse Wireframe 2' width='' alt='Pulse Wireframe 2' />

## User Stories

The following functionality is completed:

- [X] Login page

     **required**
     - [X] User must be able to login using their username and password
     - [X] Link to go to sign up page if user does not have an account
     - [] Link to go to a page to reset password 
     - [X] User can skip login and use the app anonymously, locally, without signing up     

     **optional**
     - [] User can login using touch ID

- [] Sign up page

     **required**
     - [X] User must be able to sign up for an account  

     **optional**
     - [] User can sign up using Google or Facebook authentication
     - [] User can add their company to be able to sync up with other users within the company

- [] Reset password page

     **required**
     - [] User must be able to reset their password

- [] Dashboard 
     - [ ] Home page

         **required**
         - [X] Contains a setting button - tapping on it should direct user to settings page 
         - [] Contains a chart showing the history of the team pulse
         - [X] Contains cards which the user can add, remove, move up, and move down
         - [X] Card configuration should be added to Parse and obtainable with future logged in use cases

         **optional**
         - [] Make the dashboard graphics interactive, for example: user can tap the chart pin to see pulse details
         - [] Make the org chart interactive, for example: user can tap a team member to see their details     
         - [] Allow user to see the same information in List view
         - [] Include filters, for example: search by date range
         - [] Contains an org chart showing the pulse with the most recent survey results

     - [] Team module

         **required**
         - [X] User must be able to see a list of everyone in his/her team
         - [] User must be able to see the team members current status (based on last 1:1)
         - [] User must be able to add, edit and delete their team members 
             - [X] User must be able to add and edit their team members
         - [X] Selecting a user should direct user to the employee detail page

         **optional**
         - [] Implement swipe to delete user
         - [] User can customize and edit page (similar to cards in the "today" app), for example: add an Upcoming section, ToDo section, etc.
         - [] Customizable page, for example: add/remove cards
         - [] Set up ToDos due date and get Notifications/reminders when the due date is coming up

- [] Employee detail page

     **required**
     - [] Contains employee's current pulse, next and upcoming 1:1s scheduled, manager's ToDos (this is its own module), and 1:1 history
     - [] Next 1:1 date can be entered in text field
     - [] Clicking on 1:1 date should:
         - [] Open a blank page if the note does not exist
         - [] Open a filled in page if the note exists
     - [] User can edit sections, for example: remove old 1:1 history, complete/remove/add ToDo

     **optional**
     - [] User can schedule next 1:1 using calendar date picker and it will send notifications to both user and employee
     - [] Include filters, for example: search by date range     
     - [X] Tap to call team member     

- [] 1:1 page

     **required**
     - [] If note does not exist:
         - [X] Contains the pulse questions with radio buttons (3 options: no, neutral, yes)
         - [] Contains controls to add sections: Notes, Photos, ToDos 
     - [] If note exists:
         - [] Must be able to edit historical entries
         - [] Contains controls to edit sections: Notes, Photos, ToDos
     - [X] Clicking on Notes should allow user to enter notes or edit old notes
     - [] Clicking on Photos should open photo picker, allow user to take photos/select existing photos, and save the photo in employee's 1:1 data
     - [] Clicking on ToDos should allow user to add/edit/complete ToDos on a separate page
     - [] Adding ToDos and upcoming meeting in 1:1 notes should sync up to the employee's detail page as well as Team's page     

     **optional**
     - [] Ability to add voice memo
     - [] Ability to set up due date and reminder for ToDo
     - [] Calendar integration for due date and meeting schedule
     - [] Ability to set up upcoming 1:1s, for example: frequency         

- [] Settings page 

     **required**
     - [X] Ability to edit own user profile, for example: login and password
     - [X] Contains a logout button - tapping on it should log user out completely and show the login page

     **optional**
     - [] Notifications permissions
     - [] Account integration, for example: Google calendar
     - [] Send tips permissions

# Future Expansions/Improvements

- [] Allowing flexibility in how the 1:1 page is setup (different questions, etc.)
- [] Periodic managerial tips, for example: 
    - [] Reminder to schedule 1:1 if the last one is a week ago and there's no upcoming one scheduled
    - [] Things you can do to improve morale if employee has been unhappy for X number of weeks
- [] Badges for completing ToDo items, scheduling regular 1:1s, etc.
- [] Cache data to use app offline
- [] iPad app
- [] Add more levels within the company, for example: director (above manager) and CEO (above director)

## Video Walkthrough

Here's a walkthrough of implemented user stories:

[User Stories Sprint 1](http://giphy.com/gifs/l3vQXtADvtwnTsdHO?status=200)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Artworks

Icon made by [Retinaicons](http://www.flaticon.com/authors/retinaicons) from [Flaticon]www.flaticon.com 

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright 2016 ABI

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
