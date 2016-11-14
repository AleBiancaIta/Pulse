# CodePath Group Project - Pulse - Schema

This is the schema that currently reflects what's in Heroku/Parse.

## User: Parse created table, set aside for User authentication
 - _id: "_User"
 - objectId: string
 - updatedAt: date
 - createdAt: date
 - username: string
 - email: string
 - emailVerified: boolean
 - authData: object
 - person: *Person (pointer to Person)

## Session: Parse created table, set aside to track current open sessions
 - _id: "_Session"
 - objectId: string
 - updatedAt: date
 - createdAt: date
 - restricted: boolean
 - user: *_User (pointer to User Object)
 - installationId: string
 - sessionToken: string
 - expiresAt: date
 - createdWith: object

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
- notesPhotoUrl: URL (Nullable)
- meetingDate: date
- meetingPlace: string (Nullable)
- selectedCards: string (Nullable)
- deletedAt: date (Nullable)

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
- deviceId: string (Nullable) -> might not need this for anonymous login after all
- email: string (Nullable)
- firstName: string
- lastName: string
- positionId: string
- phone: string (Nullable)
- managerId: string (Nullable) (FK to Person) -> if the Person is an Individual Contributor, this field will be populated; otherwise, it's null
- userId: string (Nullable) (FK to _User) -> if the Person is also the user of the app (i.e. manager), this field will store the userId of the current app user
- photoUrlString: string (Nullable)
- selectedCards: string (Nullable)
- deletedAt: date (Nullable)

## ToDo: store todo data
- _id: "ToDo" (Parse object name)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date (default Parse)
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

These tables are not included in Heroku schema as we most likely will set it up on the client side.

## Positions: describe the list of potential user positions
- positionId: Int
- description: String

## SurveyValues: store data for the survey scores
- valueId: Int
- value: Int

