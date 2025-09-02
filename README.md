# FeedMe Software Engineer Take Home Assignment

## Testout here
https://fancy-truffle-b75ca9.netlify.app/

## Instructions

You are required to:

1. Understand the situation and use case. You may contact the interviewer for further clarification.  
2. Fork this repo and implement the requirement with your most familiar tools.  
3. Complete the requirement and perform your own testing.  
4. Provide documentation for any part that you think is needed.  
5. Commit into your own GitHub and share your repo with the interviewer.  
6. Bring the source code and functioning prototype to the interview session.  

---

## Situation

McDonald’s is transforming their business during COVID-19. They wish to build automated cooking bots to reduce workforce and increase efficiency.  

As one of the software engineers in the project, your task is to create an **order controller** which handles the order control flow.

---

## User Stories

- **As a normal customer**  
  After I submit my order, I want to see my order flow into the **"PENDING"** area.  
  After the cooking bot processes my order, I want to see it flow into the **"COMPLETE"** area.  

- **As a VIP member**  
  After I submit my order, I want my order to be processed **first before all normal customer orders**.  
  However, if there are existing VIP orders, my order should queue **behind them**.  

- **As a manager**  
  I want to increase or decrease the number of cooking bots available in my restaurant.  
  - When I **increase** a bot, it should immediately process any pending order.  
  - When I **decrease** a bot, the processing order should remain unprocessed.  

- **As a cooking bot**  
  - It can only pick up and process **1 order at a time**.  
  - Each order requires **10 seconds** to complete processing.  

---

## Requirements

- When **"New Normal Order"** is clicked, a new order should show up in the **PENDING** area.  
- When **"New VIP Order"** is clicked, a new order should show up in the **PENDING** area.  
  - It should be placed **in front of all existing Normal orders**.  
  - It should be placed **behind all existing VIP orders**.  
- The **order number** should be **unique and increasing**.  
- When **"+ Bot"** is clicked:  
  - A bot should be created and start processing the order inside **PENDING**.  
  - After **10 seconds**, the order should move to **COMPLETE**.  
  - The bot should then process another order if there are any left.  
- If there are no more orders in the **PENDING** area, the bot should become **IDLE** until a new order comes in.  
- When **"- Bot"** is clicked:  
  - The **newest bot** should be destroyed.  
  - If the bot is processing an order, it should also **stop the process**.  
  - The order should be moved back to **PENDING** and ready to be processed by other bots.  
- No data persistence is needed for this prototype.  
  - All processing should be done **in memory**.  

---

## Functioning Prototype

You may demonstrate your final functioning prototype with **one** of the following methods:

1. CLI application  
2. UI application  
3. E2E test case  

---

## UI Overview
- More UI info keeping in ./lib/res

1. home_screen
[Home Screen 1](./lib/res/Screenshot%202025-09-01%20at%2012.37.30 PM.png)
[Home Screen 2](./lib/res/Screenshot%202025-09-01%20at%2012.37.56 PM.png)

2. Orders_screen
[Order screen 1](./lib/res/Screenshot%202025-09-01%20at%2012.39.23 PM.png)

3. Bots_screen
[Order screen 1](./lib/res/Screenshot%202025-09-01%20at%2012.41.53 PM.png)


   
