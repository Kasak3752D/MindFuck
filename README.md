<h1 align="center">🃏 MindF*ck – Real-Time Multiplayer Card Game</h1>
<p align="center">
<img src="https://drive.google.com/uc?export=view&id=1_3CLB7N0oC68xpsX_4KQb32kbwBBwOdq" alt="My Image" width="400" >
</p>
</img>
<hr>

<h2>Description / Overview</h2>
<p>
<b>MindF*ck</b> is multiplayer card game where players compete to maintain the <b>lowest sum value of all cards</b> in their hand.
The game combines strategy, memeory retention, and decision-making in a competitive real-time environment. 
</p>

<p>
Players can create or join rooms, and all game actions are synced across devices.The player can make strategic decisions or can just do fun random actions to make the game more interesting.
</p>

<hr>

<h2>Features</h2>
<ul>
  <li>Real-Time Multiplayer Gameplay</li>
  <li>Login and Sign-Up system
  <ul> 
    <li>Email and Password based</li>
    <li>Once an account is made, the user won't have to login again and again</li>
  </ul>
  </li>
  <li>Create Room / Join Room System</li>
  <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1h2C18GGiQPsGL8DxntRMrLqs66h1TjMB" alt="My Image" width="400" >
  </p>
  </img>
    <ul>
      <li>If a player is creating a room the they will get a key which they can share to other players who will have to enter the key to join their room</li>
      <p align="center">
      <img  src="https://drive.google.com/uc?export=view&id=1qHC4iZQwmPBf_MH5hUrYvLXqlEz57AoO" alt="My Image" width="400">
      </p>
      </img>
      <li>If a player is joining an already existing room then they will have to enter a room code for the same</li>
      <p align="center">
      <img src="https://drive.google.com/uc?export=view&id=1CHARz72ZO4hocZypMOKwphfUBl3SbPXK" alt="My Image" width="400">
      </p>
      </img>
      <li>The codes are randomized</li>
    </ul>
  <li>After joining or creating a room you have a waiting area where your user id is at top and you can see the players who are joining</li>
  <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1VFdl3nrF66nYns-QU_cXnLU_K05H1FOo" alt="My Image" width="400">
  </p>
  </img>
  <li>Objective: Maintain the Lowest Card Sum
    <li>When selecting any two cards to see out of the four in hand, a timer starts. One has to select the cards withinthat time only.</li>
  </li>
  <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1oYLgcu0A159dCNX-qNOleXCol4u5qAHm" alt="My Image" width="400">
  </p>
  </img>
  <li>Turn-Based Card Mechanics</li>
  <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=14WtR9Gku_WFUV-0AhSIhnZnL2howj1E_" alt="My Image" width="400">
  </p>
    </img>
  <li>Throwing of cards onto the discard pile and then performing a suitable action</li>
  <li>Power up features for certain cards
    <ul>
    <li>The cards glow when a power up is used</li>
  <li>Only those cards glow on which the power up is to be used on</li>
  </li>
    </ul>
    <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1UrN0qZYD5jakYoUi1e310H6zDJeMjj2Z" alt="My Image" width="400">
</img>
</p>
  <li>Smart Card Swapping System</li>
  <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1sifmlz0jqm5B5PSjOH42-hYUmD8zbYH3" alt="My Image" width="400">
</img>
</p>
  <li>Deck & Discard Pile Logic</li>
  <p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1c6kZT5wn01MSxXPcyLQ7cVMMhSq4JLlb" alt="My Image" width="400">
</img>
</p>
  <li>Timer based game</li>
  <li>End Game System</li>
  <li>Live Game State Synchronization</li>
  <li>Cross-platform Support (Android & iOS)</li>
  <li>Winner screen
    <ul>
  <li>The screen which appears after a player calls end game</li>
<li>It shows the name and sum of the player who won</li>
    </ul>
</li>
</ul>

<hr>

<h2>Instructions</h2>
<ul>
  <li><b>⚠️Just a disclaimer!</b></li>
  <li>Before you start reading the rules, clutch your seats as you might turn out like a blank paper soon</li>
  <li>The main objective:- Keep the sum of the cards in hand lowest</li>
  <li>So let us begin</li>
  <p></p>
  <p>1. Each player will get 4 cards initially</p>
  <p>2. The player can select any two cards which they can see and the other two cards will be unknown to them </p>
  <p>3. The player have to remember the cards they have chosen in the same order that they picked, all within a time period</p>
  <p>4. The cards will be then turned upside down and you can not see them again </p>
  <p>5. Now those cards will be placed with the first card placed at the lowermost left and the second known card at the lowermost right</p>
  <p>6. The game starts with each player getting a turn </p>
  <p>7. During your turn, you have to pick a card from the deck and you have multiple actions to choose from which you can perform with that drawn card</p>
  <p>8. The first thing you can do is throw the picked card onto the pile and use its power (if any)</p>
  <p>9. Okay so hold on, as we are now going to go through the powers of certain cards</><ul>
    <li>- [ ] 7-8 valued cards:- You can see one of your own unknown card if you picked a 7 or 8 values card</li>
    <li>- [ ] 9-10 valued cards:- You can see any one card of your choice of the other player</li>
    <li>- [ ] J(Jake) or Q(Queen):- You can blindly swap any card of your own with any card of the other player. You cannot see which two cards you are swapping.</li>
    <li>- [ ]  K(King):- You can do a seen swap. Yes, you can see your own card and the other player’s card and then swap if you think it will lower down your sum</li>
    <li>- [ ] A,2,3,4,5,6 have no power</li>
    <li>- [ ] All these power ups are optional to use. If you think you will not be benefitted from the powers you can skip it. But the power of that card is only valid for that turn </li>
  </ul>
  <p>10. Now the value that the cards add to the sum is the same as the number on the card but with a few exceptions. Cards from A to Q have the normal value i.e. ace being 1, J being 11       and Q being 12</p>
  <p>11. The value of black king is 13 but the value of the red king is -1</p>
  <p>12. There are also jokers involved (apart from the players...........jk) whose value is 0</p>
  <p>13. You can also throw the card onto the pile if you think that it is not beneficial to you. For example 2 of your cards are 4 and 6 and you drew a 8 valued card</p>
  <p>14. The other thing you can do is swap that card and throw any card which you have in your hands. If you think the card you drew from the deck is more beneficial than a card you               have in your hands, then you can swap them and throw the other card onto the pile. But if you swap cards then you can’t use the power-ups.</p>
  <p>15. During your turn, a button, EndGame Button will get activated a stay activated till your turn gets over. This can be pressed by user if they think they have the lowest sum and             have a chance of winning</p>
  <p>16. But the game doesn’t end there and then. A last round commences and each player gets a last chance to lower their sum or increase someone else’s. As soon as the turn of the                player who called EndGame comes again, the game ends and the person with least sum wins</p>
</ul>

<hr>

<h2>Tech Stack</h2>

<table>
  <tr>
    <th>Layer</th>
    <th>Technology Used</th>
  </tr>
  <tr>
    <td><b>Frontend</b></td>
    <td>Flutter</td>
  </tr>
  <tr>
    <td><b>Programming Language</b></td>
    <td>Dart</td>
  </tr>
  <tr>
    <td><b>Backend</b></td>
    <td>Firebase</td>
  </tr>
  <tr>
    <td><b>Database</b></td>
    <td>Firebase Realtime Database</td>
  </tr>
  <tr>
    <td><b>Version Control</b></td>
    <td>Git & GitHub</td>
  </tr>
</table>

<hr>

<h2>Installation</h2>

<pre>
git clone https://github.com/Kasak3752D/MindFuck.git
cd MindFuck
flutter pub get
flutter run
</pre>

<hr>

<h2>▶ Usage</h2>
<ol>
  <li>Launch the app</li>
  <li>Login or Sign up</li>
  <li>Create a room or join an existing room</li>
  <li>Wait for players to join</li>
  <li>The game starts automatically</li>
  <li>Each player draws a card and makes strategic moves</li>
  <li>The player can use power-ups to minimize their sum</li>
  <li>Press <b>End Game</b> when ready</li>
  <li>Final scores are calculated and the winner is displayed</li>
</ol>

<hr>

<h2>Configuration / Environment Variables</h2>

<p>To run this project, connect it with your Firebase project.</p>

<h3>Steps:</h3>
<ol>
  <li>Create a Firebase project</li>
  <li>Enable <b>Realtime Database</b></li>
  <li>(Optional) Enable <b>Authentication</b></li>
  <li>Add configuration files:</li>
</ol>

<ul>
  <li><code>android/app/google-services.json</code></li>
  <li><code>ios/Runner/GoogleService-Info.plist</code></li>
</ul>


<hr>

<h2>▶ Project Structure</h2>

<pre>
lib/
│
├── main.dart
│
├── models/
│   ├── card.dart
│   ├── deck.dart
│   ├── player.dart
│   ├── pile.dart
│
├── game_logic/
│   ├── game_manager.dart
│   ├── turn.dart
│   ├── end_button.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── lobby_screen.dart
│   ├── game_screen.dart
│   ├── result_screen.dart
│
└── services/
    ├── firebase_service.dart
    ├── room_service.dart
</pre>

<hr>

<h2>Roadmap</h2>
<ul>
  <li>➥ App Logo</li>
  <li>➥ Login / Signup System</li>
  <li>➥ Room Creation or Joining</li>
  <li>➥ Core Game Logic</li>
  <li>➥ Game Play Mode</li>
  <li>➥ Real-time Multiplayer Sync</li>
  <li>➥ Result Screen with Winner's Name and Sum</li>
  <li>➥ Offline Mode</li>
</ul>

<hr>

<h2>Known Issues</h2>
<ul>
  <li>UI responsiveness may vary on larger devices</li>
  <li>Game state recovery if app closes mid-game is limited</li>
</ul>

<hr>

<h2>Scope</h2>
<p><ul>
  <li>A login page with phone number and OTP or with Email and passkey</li>
  <li>Sharing of code is not possible yet.We wanted to at least be able to copy the code and then paste it on the respective messanging platforms.</li>
  <li>We wanted to have a range of 3-8 players with flexible players in the game. The game could start whenever there were sufficient players.</li>
  <li>Timer per player for quick decisions</li>
  <li>End game logic was different. Whenever a player called end game, a last round was to be commenced. After each player gets a last turn and the turn of the end game initiator came again, that;s when the game was to end</li>
  <li>We wanted to add a feature of quick swap and throwing of cards. Which means that whenever a player had the same valued card as on the pile, they can quickly add it to the pile so as to reduce cards and hence their sum. Another interesting feature was that we can throw the card of another player if we know it is the same as that as the last card of the pile and we can give them a bad card of ours</li>
  <li>New deck recycling. Whenever deck got empty, cards from the pile reshuffle and form a new pile</li>
  <li>Power logic issues</li>
  <li>We can't see all cards of every player in the end. Hence, we cannot know our sum as well as the sum of players who did not win</li>
</ul></p>
<h2>⚠︎ Disclaimer</h2>
<p>
The game mechanics are custom-designed and intended for entertainment and experimentation.
</p>

<hr>
