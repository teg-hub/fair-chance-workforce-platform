# Progress Note Form Specification (Founder-Confirmed)

This specification captures the required fields and dropdown options confirmed via screenshot review.

## Required Inputs
- `note_start_date` (Date)
- `meeting_location` (Dropdown)
- `areas_of_need_codes` (Multi-select chip group)

## Meeting Location Dropdown (Current + Next)
- Office (`office`)
- Garage (`garage`)
- Newberry (`newberry`)
- Community (`community`)
- Phone (`phone`)
- Video (`video`)
- Text (`text`)
- Email (`email`)

## Areas of Need Options
- Clothing (`clothing`)
- Education (`education`)
- Financial (`financial`)
- Food (`food`)
- Housing (`housing`)
- Legal (`legal`)
- Mental Health (`mental_health`)
- Transportation (`transportation`)
- Prefer Not To Share (`prefer_not_to_share`)
- Other (`other`)

## Additional Structured Fields
- `employee_report`
- `coordinator_observations`
- `short_term_goals`
- `long_term_goals`
- `employee_follow_up_actions`
- `coordinator_follow_up_actions`
- `referrals_made`
- `next_meeting_at`
- `next_meeting_location`
- `summary_of_meeting`
- `file_link` (optional upload reference; backed by uploaded document metadata)

## Validation Rules
- `meeting_location` must be one of the listed enum values.
- `areas_of_need_codes` must contain at least one selected value.
- `next_meeting_location` is optional, but if provided must be a valid enum value.
- `next_meeting_at` can be null; when present it must be after `interaction_at`.
