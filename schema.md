# CodePath Group Project - Pulse - Schema

This is the schema that currently reflects what's in Heroku/Parse.

## Meetings: contain the one-on-one meeting data. Survey data is separated to allow further expansion (example: no. of surveys)
- _id: "Meetings" (Parse object name)
- objectId: string (default Parse)
- createdAt: date (default Parse)
- updatedAt: date (default Parse)
- personId: string (FK to Person)
- managerId: string (FK to Person)
- surveyId: string (FK to Survey)
- notes: string (Nullable)
- notesPhotoUrlString: string (Nullable)
- meetingDate: date
- meetingPlace: string (Nullable)
- selectedCards: string (Nullable)
- deletedAt: date (Nullable) (stored as String in Parse)

## Survey: store information related to a particular user survey
- _id: "Survey" (Parse object name)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date(default Parse)
- surveyDesc1: string
- surveyValueId1: number
- surveyDesc2: string
- surveyValueId2: number
- surveyDesc3: string
- surveyValueId3: number

## Person: describe the app User (Manager) and Team Members 
- _id: "Person" (Parse object name)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date (default Parse)
- deviceId: string (Nullable) 
- email: string (Nullable)
- firstName: string
- lastName: string
- positionId: string
- phone: string (Nullable)
- managerId: string (FK to Person)
- userId: string (FK to Person)
- photoUrlString: string (Nullable)
- selectedCards: string (Nullable)
- deletedAt: date

## ToDo: store todo data
- _id: "ToDo" (Parse object name)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: Date (default Parse)
- managerId: string (FK to Person)
- personId: string (FK to Person)
- meetingId: string (FK to Meeting)
- text: string
- dueAt: date 
- completedAt: date 
- deletedAt: date

## Dashboard: link the user ID with the chosen cards
- _id: "Dashboard" (Parse object name)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date (default Parse)
- userId: string (FK to _User)
- selectedCards: String (Nullable)

The following tables are most likely going to be stored on the client side since they contain static values.
Current plan is to stored them in a Constants.swift file.
- Benefits: Autocomplete, easier to maintain, etc.

## Card: describe the different cards and which pages they are allowed to be used (Do we need this?)
- _id: "Card" (default Parse)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date(default Parse)
- name: string
- type: string (format TBD) - currently I follow the format of "dashboard-employee"

## Positions: describe the list of potential user positions
- position_id: Int
- description: String

## SurveyValues: store data for the survey scores
- value_id: Int
- value: Int

