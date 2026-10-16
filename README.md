# Goldbook

A World of Warcraft addon that scans the auction house, shows prices in item
tooltips and a searchable window, finds deals, advises what to sell, and keeps
a ledger of your gold and trades.

With the Goldbook app, the addon syncs with the
[Goldbook website](https://app.jkc-be.com/goldbook/): a price history for
every item, and your characters' gold, bags, bank and trades. Get the app from
the website's [Download](https://app.jkc-be.com/goldbook/#download) page.

This repository holds the addon only. It is a read-only copy of the addon
folder of a private repository, and every update overwrites it. The Goldbook
desktop app and server are not part of it.

## Requirements

World of Warcraft with the modern auction house API (`C_AuctionHouse`). The
addon declares interface 16001, the 1.60 "Forever" client. On another client
version the game lists it as out of date.

## Install

The easiest way is the Goldbook app from the
[Download](https://app.jkc-be.com/goldbook/#download) page. It installs the
addon, keeps it up to date, and syncs it with the website.

To install the addon by hand:

1. Quit the game. The game only looks for new addons when it starts.
2. Copy the `Goldbook` folder into `Interface/AddOns` of your game flavor, for
   example `World of Warcraft/_classic_/Interface/AddOns/Goldbook`. The folder
   must contain `Goldbook.toc` directly.
3. Start the game.

When you log in, chat says `Goldbook loaded. Type /gb for commands.` and a gold
coin button sits on the edge of the minimap.

## Sync with the website

The addon works on its own, but an addon cannot open network connections. It
queues each scan, and each character's gold, bags and bank, in its
`SavedVariables` file, which the game writes on `/reload` and on logout. The
Goldbook app watches that file and uploads it to the
[Goldbook website](https://app.jkc-be.com/goldbook/).

1. Install the app from the [Download](https://app.jkc-be.com/goldbook/#download)
   page and leave it running.
2. Scan in the auction house, then type `/reload`. The app uploads the scan a
   few seconds later.
3. On the website, **Prices** shows the price history of every item. To see
   your characters, type `/gb web` in game and log in under **Characters** with
   the ID and key it shows.

The app uploads only a hash of the key. Anyone with the ID and the key sees
the gold, bags and bank of your characters, so keep the key to yourself. The
address `/gb web` shows is `X-Website` in `Goldbook.toc`.

## Use

| Action | Result |
|---|---|
| Left click **Goldbook scan**, or `/gb scan` | Quick scan: lowest price and quantity per item |
| Right click **Goldbook scan**, or `/gb scan full` | Full scan: every auction, adds a market value |
| `/gb deals` | What is listed right now below its resale or vendor value |
| `/gb sell` | Your bags: what to auction, at what price, and what to vendor instead |
| `/gb movers` | The prices that rose and fell most since the day before |
| `/gb gold` | Gold per character, gains, a 30 day chart and net worth |
| `/gb trades` | Your auction house sales and purchases and your sales to vendors |
| Alt+click an item, or `/gb item <link or name>` | The item's price history |
| `/gb show [text]`, or left click the minimap button | Price list, filtered by item name |
| `/gb autoscan` | A quick scan each time the auction house opens, at most every 15 minutes |
| `/gb minprofit <gold>` | The profit a resale deal must make |
| `/gb status` | The addon's version, items priced and scans waiting for sync |
| `/gb web` | The website's address, and the ID and key that log you in to its character pages |
| `/gb minimap` | Hides or shows the minimap button |

## Test

The tests run the addon against a simulated client with
[LuaJIT](https://luajit.org):

```sh
luajit tests/run.lua
luajit tests/scanner.lua
luajit tests/sellers.lua
luajit tests/professions.lua
luajit tests/trades.lua
```

## License

Copyright (c) 2026 jkc-be. All rights reserved. See [LICENSE](LICENSE).
