# Project - *Anonymous Advice App*

**Anon Advice** is an anonymous advice app that lets users ask and recieve advice from people all around the world.

## User Stories

The following **required** functionality is completed:

- [x]  User can Sign up and Sign in with authentication.
- [x]  User authentication persists across restarts.
- [x]   User can logout
- [x]  User can view posts asking for advice from the local area or world.
- [x]  Each user has a unique avatar within a post.
- [X]  User can view advice from multiple users in a post.
- [X]  User can create a new post asking for advice.
- [X]  User can leave advice on another user’s post.
- [x]  User can reply to another user’s advice.
- [x]  User can pull to refresh a list of posts.
- [x]  User can pull to refresh a list of replies.
- [X]  User can view their profile containing open posts.
- [X]  User can close or delete their own posts.

The following **stretch** features are implemented:

- [X]  User can select the subject or type of advice they want to view or ask for.
- [ ]  User can change their location from their profile page.
- [ ]  User receives a notification when their post is given advice.
- [x]  User's profile will require password or fingerprint authentication to access after app restart
- [X]  User can view open threads they have given advice on.
- [X]  User can rate advice good or bad.
- [X]  User can select the best advice on their own post.
- [X]  Users have a total advice score (good or bad advice points)
- [ ]  Posts in the local or global section are sorted by popularity or newest.
- [X]  Advice in a post is sorted by good or bad rating.
- [x]  Views can be switched to night mode.
- [ ]  Admins and moderators can close posts, delete advice, and ban users.

## Firebase Backend

###### Users Table Example: ######

| ID | Username | Password |
| --- | --- | --- |
| 0 | Name | Pass |

###### User Table Example: ######

| ID | Username | Password | Creation Date | Location | Good Points | Bad Points |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Name | Pass | 10/10/18 | California | 10 | 5 |

###### Posts Table Example: ######

| ID | Author | Title | Question | Creation Date | Location | Subject | Reply Count |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | Name | Short Title | Text | 10/10/18 | California | Relationship | 5 |

###### Post Table Example: ######

| ID | UserID | Avatar | Creation Date | Text | Good Points | Bad Points |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | 1111 | Image.jpg | 10/10/18 | Advice | 10 | 5 |

## API Endpoints

- adorable-avatars : {our-server.com}/myAvatars/:size/:id

## Wireframes

<img src='https://i.imgur.com/RSIVa5Z.png' title='Wireframes' width='400' alt='Wireframes' />

## Sprint 1

<img src='https://imgur.com/jr3qrPL.gif' title='Part 1' width='' alt='sprint1' />

## Sprint 2
<img src='https://i.imgur.com/9C1VI15.gif' title='Wireframes' width='' alt='sprint2' />

## Sprint 3
<img src='https://i.imgur.com/43P4YsC.gif' title='Wireframes' width='' alt='sprint2' />

## Optional Sprint 1
<img src='https://imgur.com/qTXBmdO.gif' title='Wireframes' width='' alt='sprint2' />

## Credits

List any 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [Adorable-Avatars](https://github.com/adorableio/avatars-api-middleware) - profile avatar API
- [Google-Place-Picker](https://developers.google.com/places/android-sdk/placepicker) - Places SDK
- [SCLAlertView](https://github.com/vikmeup/SCLAlertView-Swift) - Custom Alert Views
- [NightNight](https://github.com/Draveness/NightNight) - Night mode
- [Firebase](https://firebase.google.com/) - backend database

## License

    Copyright [2018] [Garred Murphey, Raeleen Watson, Devin Hight, Jesus Bernal]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
