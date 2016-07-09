# fontbot

Choose word, choose font, tweet. 

# log

# 2016-07-09

Interesting changes today:

 * slightly changed tweet search keyword - "a" produces much more random results
 * cleaned up retrieved interesting words
 * chained the tweet-generating functions together:
   * tweet retrieval
   * font preview generation
   * tweeting

Now, when executed, the fontbot grabs the first interesting word out of a batch of retrieved tweets, generates the image (fixed font) and tweets it.

![timeline](https://raw.githubusercontent.com/PiotrJustyna/fontbot/master/images/2016_07_09.PNG)

## 2016-07-07

Playing with (very simple) regular expressions and extracting potentially interesting words:

```bash
search metadata:
- query: "Haskell"
status:
"This must be a canonical choice among isomorphic objects."
first interesting word:
 canonical
```

## 2017-07-06

I added more fonts and think I'm finally happy with the media size and text positioning:

![haskell](https://raw.githubusercontent.com/PiotrJustyna/fontbot/5e8aea2a14ec279bfd47714b0884db4e1ae9a3c7/font_preview.png)

## 2016-07-05

Playing with regular expressions:

```bash
search metadata:
- query: "Haskell"
raw status:
"Win a copy of James Haskell: RugbyFit https://t.co/rh3q5CiXgG"
filtered status:
James
---
raw status:
"The recent watercolor paintings of Ann Jones will be on display at the Hall Haskell House Gallery in Ipswich. .... https://t.co/Vd1E6HG7y6"
filtered status:
paintings
---
raw status:
"RT @joshuaclayton: Three months into learning #haskell with @haskellbook! Wrote up how to refactor to a monad transformer stack: https://t.\8230"
filtered status:
months
---
```

## 2016-07-03

Fontbot can now render text to images.

![Haskell](https://raw.githubusercontent.com/PiotrJustyna/fontbot/d93946282962ddd15813bc6ae4cdf878473e4147/font_preview.png)

![Haskell](https://raw.githubusercontent.com/PiotrJustyna/fontbot/59e51f6a7bf57fef5c788e03f6148b9c056c5970/font_preview.png)

## 2016-07-02

Fontbot can now read and process twitter search results:

```bash
$ stack exec fontbot-exe
search metadata:
- query: "Haskell"
status:
"RT @notsleeeping: @TVG American Freedom looked good! Baffert might have his Haskell horse, going for #9, &amp; for 6 wins in the last 7 Haskell\8230"
---
status:
"RT @Steve_Byk: @DRFHersh @EaSyGoEr53 As of tonight, Baffert leaning American Freedom to Haskell, Arrogate toward Travers."
---
status:
"Vintage Miriam Haskell signed double chain necklace Russian gold gilt pendant  https://t.co/Pxrt595goI https://t.co/q6VyXN9XCW"
---

```

## 2016-07-01

Once the POC tweeting mechanism was ready, I decided not to reinvent the wheel going further and to use the twitter-conduit.

[Sample Tweet](https://twitter.com/HaskellFontbot/status/748962791961296896)

## 2016-06-28

Fontbot can now tweet using manually prepared OAuth signature read from external file.

```yaml
C:\Users\Piotr\Documents\fontbot>stack exec fontbot-exe
is_quote_status: false
in_reply_to_status_id: null
id_str: '747879477645049856'
truncated: false
in_reply_to_screen_name: null
entities:
  symbols: []
  urls: []
  user_mentions: []
  hashtags: []
text: Hello World From Haskell with OAuth header value taken from external file!
in_reply_to_user_id_str: null
favorited: false
coordinates: null
retweeted: false
user:
  screen_name: HaskellFontbot
  is_translation_enabled: false
  default_profile: false
  profile_image_url: http://pbs.twimg.com/profile_images/747072074280243200/QWq406SC_normal.jpg
  default_profile_image: false
  id_str: '747071344764923904'
  profile_background_image_url_https: https://abs.twimg.com/images/themes/theme1/bg.png
  protected: false
  location: Dublin City, Ireland
  entities:
    url:
      urls:
      - expanded_url: https://github.com/PiotrJustyna/fontbot
        url: https://t.co/2tFkSIdL6B
        indices:
        - 0
        - 23
        display_url: github.com/PiotrJustyna/fÔÇª
    description:
      urls: []
  profile_background_color: '000000'
  utc_offset: null
  url: https://t.co/2tFkSIdL6B
  profile_text_color: '000000'
  profile_image_url_https: https://pbs.twimg.com/profile_images/747072074280243200/QWq406SC_normal.jpg
  verified: false
  statuses_count: 3
  profile_background_tile: false
  following: false
  lang: en
  follow_request_sent: false
  profile_sidebar_fill_color: '000000'
  time_zone: null
  name: fontbot
  profile_sidebar_border_color: '000000'
  geo_enabled: false
  listed_count: 0
  contributors_enabled: false
  created_at: Sun Jun 26 14:17:43 +0000 2016
  id: 747071344764923904
  friends_count: 1
  is_translator: false
  favourites_count: 0
  notifications: false
  profile_background_image_url: http://abs.twimg.com/images/themes/theme1/bg.png
  profile_use_background_image: false
  description: Choose word, choose font, tweet.
  has_extended_profile: false
  profile_link_color: '000000'
  followers_count: 1
lang: en
retweet_count: 0
in_reply_to_user_id: null
created_at: Tue Jun 28 19:48:57 +0000 2016
source: <a href="https://github.com/PiotrJustyna/fontbot" rel="nofollow">fontbot</a>
geo: null
id: 747879477645049856
in_reply_to_status_id_str: null
favorite_count: 0
contributors: null
place: null
```
