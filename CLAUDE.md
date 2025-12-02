# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Start development server
rails server

# Database commands
rails db:create
rails db:migrate
rails db:schema:load

# Asset compilation
rails assets:precompile

# Console
rails console

# Run tests
rails test
rails test test/models/user_test.rb          # single test file
rails test test/models/user_test.rb:42       # single test at line

# Linting (RuboCop configured with max line length 120)
rubocop
rubocop -a                                    # auto-fix
```

## Environment Variables

Required in `.env`:
- `CLOUDINARY_URL` - Image storage
- `OPENAI_API_KEY` or `GOOGLE_AI_STUDIO` - LLM for topic generation
- `RUBYLLM_DEBUG` - Debug LLM calls (optional)

## Architecture

**Rails 7.1 MVC application** for language learning partnerships. Ruby 3.3.5, PostgreSQL.

### Core Domain Model

```
User (Devise auth)
  └── Partnership (connects two users: user_one_id, user_two_id)
        └── PartnershipTopic (join with status)
              └── Topic (AI-generated learning content)
                    ├── Challenge (JSONB content/conversation for bilingual tasks)
                    └── TopicGrammarPoint → GrammarPoint
                          └── Journal (user responses with feedback)
```

Users must have a partner to access most features. Authorization scopes everything around partnerships.

### Key Patterns

**Service Objects** (`app/services/`):
```ruby
TopicGenerationService.call(user, topic_title)
```

**Background Jobs** (`app/jobs/`, Solid Queue):
```ruby
GenerateTopicJob.perform_later(user, topic_title)
```

**Authorization** (Pundit policies in `app/policies/`):
- Every controller uses `authorize(record)` and `policy_scope(Model)`
- Skip Pundit on Devise controllers and `PagesController`

**Notifications** (Noticed gem in `app/notifiers/`):
```ruby
JournalSubmittedNotification.with(journal: journal).deliver(recipient)
```

### Frontend Stack

- Bootstrap 5.3 + Simple Form for forms
- Stimulus JS controllers (`app/javascript/controllers/`)
- Turbo Rails for SPA-like updates
- Sprockets asset pipeline with ImportMap

### Real-time & Background

- Solid Queue for job processing (not Sidekiq)
- Solid Cable for WebSockets (not Redis)
- Turbo Streams for live updates

### Content Storage

Challenges and topics use JSONB columns for bilingual content:
```ruby
# challenge.content = { "en" => "...", "jp" => "..." }
```

### File Upload

Active Storage with Cloudinary provider for user photos.
