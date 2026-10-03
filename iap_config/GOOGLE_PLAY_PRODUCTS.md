# Google Play IAP — SudokuNote

Package: `com.SudokuNoteMNG.SudokuNote`

Remote config: `https://api2.blwsmartware.net/N288.json`  
If JSON field `disable` is `1`, hide Google Play purchase popups. Shop stays open for coin unlocks.

## Consumable coin packs (buy many times)

| Product ID | Coins |
| --- | --- |
| `tt_pack_1` | 50 |
| `tt_pack_2` | 100 |
| `tt_pack_3` | 200 |
| `tt_pack_4` | 350 |
| `tt_pack_5` | 500 |
| `tt_pack_6` | 750 |
| `tt_pack_7` | 1000 |
| `tt_pack_8` | 1500 |
| `tt_pack_9` | 2200 |
| `tt_pack_10` | 3000 |

## One-time

| Product ID | Unlock |
| --- | --- |
| `tt_remove_ads` | Hide shop promo banners |
| `tt_pro` | Longer local history and saved passages |

Create these IDs in Play Console → Monetize → In-app products. Coin packs must be **consumable**. Remove ads and Pro must be **non-consumable**.
