# CodePathGroupProject - Pulse

Pulse is an app to help manager stay on top of the "pulse" of their team.

Time spent: **X** hours spent in total

## User Stories

The following functionality is completed:

- [] Login page

     **required**
     - [] User must be able to login using their username and password
     - [] Link to go to sign up page if user does not have an account
     - [] Link to go to a page to reset password 

     **optional**
     - [] User can skip login and use the app anonymously, locally, without signing up
     - [] User can login using touch ID

- [] Sign up page

     **required**
     - [] User must be able to sign up for an account  

     **optional**
     - [] User can sign up using Google authentication

- [] Reset password page

     **required**
     - [] User must be able to reset their password

- [] Home page (dashboard)

     **required**
     - [] Contains a setting button - tapping on it should direct user to settings page 
     - [] Contains a logout button - tapping on it should log user out completely and show the login page
     - [] Contains controls (tab bar) at the bottom to allow user to switch between Home, Team, ToDo pages
     - [] Contains a chart showing the history of company pulse
     - [] Contains an org chart showing the pulse at the moment

     **optional**
     - [] Make the dashboard graphics interactive, for example: user can tap the chart pin to see pulse details
     - [] Allow user to see the same information in List view

- [] Team page

     **required**
     - [] User must be able to see a list of everyone in his/her team and their current status (based on last 1:1)
     - [] User must be able to add, edit and delete their team members 
     - [] Selecting a user should direct user to the employee detail page

     **optional**
     - [] Implement swipe to delete user
     - [] User can customizer and edit page (similar to cards in the "today" app), for example: add an Upcoming section, ToDo section, etc.

- [] Employee detail page

     **required**
     - [] Contains employee current pulse, next and upcoming 1:1s scheduled, manager's ToDos, and 1:1 history
     - [] User can schedule next 1:1 using calendar date picker and it will send notifications to both user and employee (optionals?)
     - [] Clicking on 1:1 date should:
         - [] Open a blank page if the note does not exist
         - [] Open a filled in page if the note exists
     - [] User can edit sections, for example: remove old 1:1 history, complete/remove/add ToDo

     **optional**
     - [] 

- [] 1:1 page

     **required**
     - [] If note does not exist:
         - [] Contains the pulse questions with radio buttons
         - [] Contains controls to add sections: Notes, Photos, ToDos 
     - [] If note exists:
         - [] Must be able to edit historical entries
         - [] Contains controls to edit sections: Notes, Photos, ToDos
     - [] Ability to set up upcoming 1:1s 
     - [] Clicking on Notes should allow user to enter notes or edit old notes
     - [] Clicking on Photos should open photo picker, allow user to take photos/select existing photos, and save the photo in employee's 1:1 data
     - [] Clicking on ToDos should allow user to add/edit/complete ToDos (SEPARATE PAGE?)

     **optional**
     - [] Ability to add voice memo
     - [] Ability to set up due date and reminder for ToDo
     - [] Calendar integration for due date and meeting schedule

- [] Settings page (TBD)

     **required**
     - []

     **optional**
     - []     

- [] Admin page (TBD)

     **required**
     - [] 

     **optional**
     - []     

- [] Other features/notes (TO BE DISCUSSED):
    
     **required/optional**
     - [] Periodic managerial tips, for example: 
         - [] Reminder to schedule 1:1 if the last one is a week ago and there's no upcoming one scheduled
         - [] Things you can do to improve morale if employee has been unhappy for X number of weeks
     - [] Set up ToDos due date and get Notifications/reminders when the due date is coming up
     - [] Adding ToDos and upcoming meeting in 1:1 notes should sync up to the employee's detail page as well as Team's page
     - [] Badges for completing ToDo items
     - [] Google calendar integrations for upcoming 1:1 and ToDo due dates
     - [] Cache data to use app offline
     - [] iPad app
     - [] Tap to call team member
     - [] Make pulse public to company and notes private to user


# Future Expansions/Improvements

- Allowing flexibility in how the 1:1 page is setup (different questions, etc.)

## Video Walkthrough

Here's a walkthrough of implemented user stories:

[User stories]()

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Artworks

## Notes

Describe any challenges encountered while building the app.


## License

    Copyright 2016 AleBiancaIta

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
