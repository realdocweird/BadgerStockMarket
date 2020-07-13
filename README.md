# BadgerStockMarket
A FiveM Script (that actually utilizes the real stock market, pretty nifty)
## DocWeird#6666 VRP Edit
Converted to VRP Old and restyled by DocWeird#6666
## What is it?
BadgerStockMarket is a stock market that is based on the real stock market! The prices and graphs actually come from the real stock market! I wanted to make a nifty script to interact with the stock market and actually invest it, but without investing real money. You can do that with this script! You use ESX money in-game to invest into the stock market. The stock market updates/refreshes every time you open the phone, so this updates in real live time. Make sure you sell your stocks when you are making money, not when you are losing money!
## Commands
`/stocks` - Opens up the phone menu for the stocks
## Screenshots
![Screen 1](https://cdn.discordapp.com/attachments/730420750661713963/731538155408326756/unknown.png)

![Screen 2](https://cdn.discordapp.com/attachments/730420750661713963/731538391908221008/unknown.png)


## Configuration
```
Config = {
	maxStocksOwned = {
		['permission.whatever1'] = 20,
		['permission.whatever2'] = 100,

	},
	stocks = {
		['Apple Stock'] = {
			link = 'https://money.cnn.com/quote/quote.html?symb=AAPL',
			tags = {'Technology', 'Software'}
		},
		['Citigroup Stock'] = {
			link = 'https://money.cnn.com/quote/quote.html?symb=C',
			tags = {'Bank'}
		},
		['General Electric Stock'] = {
			link = 'https://money.cnn.com/quote/quote.html?symb=GE',
			tags = {'Automobiles', 'Vehicles', 'Cars'}
		}
	}
}
```
You must use https://money.cnn.com website for this to work properly (for each Stock). Add as many stocks as you would like :)

You can use normal VRP groups permission, that a player has to have to have that many stocks. You can set up multiple different permission and allow a certain number of stocks for different groups of people. Maybe donators get more stocks?

## Liability Reasons
For liability reasons, I wanted to include this at the bottom. BadgerStockMarket is in no way affiliated with the Stock Market and/or its proprieters. BadgerStockMarket was created as an educational tool to be used within the GTA V modification known as FiveM. BadgerStockMarket is also not affiliated with the Robinhood application. Although the script used the Robinhood logo. Once again, BadgerStockMarket was created as an educational tool. If anyone has a problem with this, please contact me and we can get the changes adjusted appropriately, thank you.

## Download

https://github.com/realdocweird/BadgerStockMarket
