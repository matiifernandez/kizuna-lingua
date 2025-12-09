# 💞 KizunaLingua

Kizuna Lingua is a partner-based language learning app designed for couples or friends studying each other’s languages. Users create shared challenges, write journals, exchange feedback, and practice speaking through real-time recorded conversation tasks. The app automatically adjusts difficulty for each partner, keeps track of progress, and connects writing, speaking, and grammar into one consistent learning flow. It turns language study into a shared, motivating, and relationship-strengthening experience.

<img width="426" height="757" alt="image" src="https://github.com/user-attachments/assets/d36b45aa-c2a1-4a51-b25b-c3968574cfea" />

<img width="425" height="758" alt="image" src="https://github.com/user-attachments/assets/501b1930-a187-4df5-941f-6746e29e0bf4" />

<img width="425" height="761" alt="image" src="https://github.com/user-attachments/assets/bcc59419-bdbc-4633-b8e4-ce5074aad737" />

<img width="422" height="761" alt="image" src="https://github.com/user-attachments/assets/33490b04-a258-4dcb-a0ba-8143e8634f40" />

<br>
App home: (https://www.kizunalingua.com/)
   

## Getting Started
### Setup

Install gems
```
bundle install
```

### ENV Variables
Create `.env` file
```
touch .env
```
Inside `.env`, set these variables. For any APIs, see group Slack channel.
```
CLOUDINARY_URL=your_own_cloudinary_url_key
GOOGLE_AI_STUDIO=your_own_google_ai_studio_key
```

### DB Setup
```
rails db:create
rails db:migrate
rails db:seed
```

### Run a server
```
rails s
```
### Sign in as our test users
- Native English speaker: email: `test@mail.com` password: [123456]
- Native Japanese speaker: email: `testjpn@mail.com` password [123456]

## Built With
- [Rails 7](https://guides.rubyonrails.org/) - Backend / Front-end
- [Stimulus JS](https://stimulus.hotwired.dev/) - Front-end JS
- [Heroku](https://heroku.com/) - Deployment
- [PostgreSQL](https://www.postgresql.org/) - Database
- [Bootstrap](https://getbootstrap.com/) — Styling
- [Figma](https://www.figma.com) — Prototyping

## Team Members
- [Matias Fernandez](https://github.com/matiifernandez)
- [Lorenzo Panneman](https://github.com/lormanzo3)
- [Colton Sikes](https://github.com/sikesc)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License
