# Icon downloader for App Store

Download icon from App Store and add tag for reference

## icon-downloader.rb

For download list of icon. You can add application you want to download in icon-downloader-list.csv and run this command.

| Filename      | Id         | country code | tag        |
| ------------- | ---------- |:------------:| ---------- |
| Facebook      | 1234567    | th           | facebook   |
| Instagram     | 123456789  | us           | instragram |
| Google        | 12345678   | kr           | google     |

Country code and tag is optional. If you don't have tag, the code will user filename as tag for you :-)

Note: Don't forget to change target location before run

## app-id-finder.rb

For search application ID that use in icon-downloader. Add application you want to search in app-id-finder-list.csv and copy output from console to icon-downloader-list.csv

| Filename      | country code |
| ------------- |:------------:| 
| Facebook      | th           |
| Instagram     | us           |
| Google        | kr           |

Country code is optional

## Require

https://github.com/jdberry/tag

     brew install tag

## Reference

[iTunes Search API](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/)