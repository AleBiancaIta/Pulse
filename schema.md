# CodePath Group Project - Pulse - Schema

## Card: describe the different cards and which pages they are allowed to be used
- card_id: Int
- name: String
- page_type: String (TO BE DISCUSSED)

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
Meetings
- meeting_id: Int
- person_id: Int
- manager_id: Int
- survey_id: Int (foreign key to Survey table - see below)
- notes: String (Nullable)
- notes_photo_url_string: String (Nullable)
- meeting_date: Date
- meeting_place: String (Nullable)
- selected_cards: String (Nullable)
- created_date: Date (stored as String in Parse)
- updated_date: Date (stored as String in Parse)
- deleted_date: Date (Nullable) (stored as String in Parse)

Survey
- survey_id: Int
- survey_desc_1: String
- survey_value_id_1: Int
- survey_desc_2: String
- survey_value_id_2: Int
- survey_desc_3: String
- survey_value_id_3: Int

## Person: describe the app User (Manager) and Team Members 
- person_id: Int
- device_id: String (Nullable) - I.C. won't have this
- email: String (Nullable)  - I.C. might not have this
- password: String (Nullable)  - I.C. won't have this
- first_name: String
- last_name: String
- position_id: Int
- phone: String (Nullable)
- manager_id: Int
- is_user: Bool
- is_anonymous: Bool
- photo_url_string: String (Nullable)
- selected_cards: String (Nullable)
- created_at: Date (stored as String in Parse)
- updated_at: Date (stored as String in Parse)
- deleted_at: Date (stored as String in Parse)

## Positions: describe the list of potential user positions
- position_id: Int
- description: String

## SurveyValues: store data for the survey scores
- value_id: Int
- value: Int

## ToDo: store todo data
- todo_id: Int
- manager_id: Int
- person_id: Int
- text: String
- is_completed: Bool
- due_at: Date (stored as String in Parse)
- completed_at: Date (stored as String in Parse)
- created_at: Date (stored as String in Parse)
- updated_at: Date (stored as String in Parse)
- deleted_at: Date (stored as String in Parse)

## Dashboard: link the user ID with the chosen cards
- user_id: Int
- selected_cards: String (Nullable)