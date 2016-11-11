# CodePath Group Project - Pulse - Schema

Notes: Table with ### next to it are in sync with Heroku

## Meetings: contain the one-on-one meeting data

Option 1 (current):
Meetings
- meeting_id: Int
- person_id: Int
- manager_id: Int
- survey_value_1: Int
- survey_value_2: Int
- survey_value_3: Int
- notes: String (Nullable)
- notes_photo_url_string: String (Nullable)
- meeting_date: Date (stored as String in Parse)
- meeting_place: String (Nullable) - will try to get from user location but only if user allows it, or manual entry?
- selected_cards: String (Nullable)
- created_date: Date (stored as String in Parse)
- updated_date: Date (stored as String in Parse)
- deleted_date: Date (Nullable) (stored as String in Parse)

Option 2: (might be more flexible for future expansion, if we want to allow user to have more than 3 survey items)
### Meetings
- _id: "Meetings"
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

### Survey: store information related to a particular user survey
- _id: "Survey"
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date(default Parse)
- surveyDesc1: string
- surveyValueId1: number
- surveyDesc2: string
- surveyValueId2: number
- surveyDesc3: string
- surveyValueId3: number

### Person: describe the app User (Manager) and Team Members 
- _id: "Person"
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date (default Parse)
- deviceId: string (Nullable) 
- email: string (Nullable)
- firstName: string
- lastName: string
- positionId: string
- phone: string (Nullable)
- managerId: string
- userId: string
- photoUrlString: string (Nullable)
- selectedCards: string (Nullable)
- deletedAt: date

### ToDo: store todo data
- _id: "ToDo"
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: Date (default Parse)
- managerId: string (FK to Person)
- personId: string (FK to Person)
- text: string
- dueAt: date 
- completedAt: date 
- deletedAt: date

### Dashboard: link the user ID with the chosen cards
- _id: "Dashboard"
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date (default Parse)
- userId: string
- selectedCards: String (Nullable)

### Card: describe the different cards and which pages they are allowed to be used (Do we need this?)
- _id: "Card" (default Parse)
- objectId: string (default Parse)
- updatedAt: date (default Parse)
- createdAt: date(default Parse)
- name: string
- type: string (TO BE DISCUSSED) - currently I follow the format of "dashboard-employee"

## Positions: describe the list of potential user positions (Do we need this?)
- position_id: Int
- description: String

## SurveyValues: store data for the survey scores (Do we need this?)
- value_id: Int
- value: Int

Most likely, any static values we need (such as Card, Position, and Survey Values) will be stored on the client side. 
- Benefits: Autocomplete, easier to maintain, etc.
